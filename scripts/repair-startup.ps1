[CmdletBinding()]
param([switch]$DiagnoseOnly)
$ErrorActionPreference='Stop'
$package=Get-AppxPackage OpenAI.Codex | Select-Object -First 1
if(!$package){throw '没有找到已安装的 Codex。'}
[xml]$manifest=Get-Content -LiteralPath (Join-Path $package.InstallLocation 'AppxManifest.xml') -Raw
$app=@($manifest.Package.Applications.Application) | Where-Object {$_.Executable -match '(ChatGPT|Codex)\.exe$'} | Select-Object -First 1
if(!$app){throw '无法识别正式 Codex 入口。'}
$expectedExe=[IO.Path]::GetFullPath((Join-Path $package.InstallLocation $app.Executable))
Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class CodexPackageRecovery {
 [DllImport("kernel32.dll")] static extern IntPtr OpenProcess(uint access,bool inherit,int pid);
 [DllImport("kernel32.dll",CharSet=CharSet.Unicode)] static extern int GetPackageFamilyName(IntPtr h,ref uint length,StringBuilder family);
 [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
 public static string Family(int pid){IntPtr h=OpenProcess(0x1000,false,pid);if(h==IntPtr.Zero)throw new InvalidOperationException("Cannot inspect process");try{uint len=256;var name=new StringBuilder((int)len);int rc=GetPackageFamilyName(h,ref len,name);if(rc==15700)return null;if(rc!=0)throw new InvalidOperationException("Package query error "+rc);return name.ToString();}finally{CloseHandle(h);}}
 [ComImport,Guid("2E941141-7F97-4756-BA1D-9DECDE894A3D"),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] interface Activation {
  [PreserveSig] int ActivateApplication([MarshalAs(UnmanagedType.LPWStr)] string id,[MarshalAs(UnmanagedType.LPWStr)] string args,uint options,out uint pid);
 }
 public static uint Start(string id){object manager=Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")));try{uint pid;int rc=((Activation)manager).ActivateApplication(id,"",0,out pid);if(rc<0)Marshal.ThrowExceptionForHR(rc);return pid;}finally{Marshal.FinalReleaseComObject(manager);}}
}
"@
$stale=@(Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($expectedExe)) -ErrorAction SilentlyContinue | Where-Object {
 try {[String]::Equals($_.Path,$expectedExe,[StringComparison]::OrdinalIgnoreCase) -and [CodexPackageRecovery]::Family($_.Id) -eq $null} catch {$false}
})
Write-Output "检测到 $($stale.Count) 个缺少应用包身份的 Codex 进程。"
if($DiagnoseOnly){return}
Write-Output '将关闭异常实例，并通过 Windows 正式入口打开 Codex。保留所有聊天、配置和登录数据。'
foreach($process in ($stale | Sort-Object -Property @{Expression={$_.MainWindowHandle -ne [IntPtr]::Zero};Descending=$true})){
 if($process.MainWindowHandle -ne 0){$null=$process.CloseMainWindow()}
 if(!$process.WaitForExit(4000)){
  # Recheck the exact executable and identity before stopping a stale instance.
  $current=Get-Process -Id $process.Id -ErrorAction SilentlyContinue
  if($current -and [String]::Equals($current.Path,$expectedExe,[StringComparison]::OrdinalIgnoreCase) -and [CodexPackageRecovery]::Family($current.Id) -eq $null){Stop-Process -Id $current.Id -ErrorAction Stop}
 }
}
$activated=[CodexPackageRecovery]::Start($package.PackageFamilyName+'!'+$app.Id)
$family=[CodexPackageRecovery]::Family([int]$activated)
if($family -ne $package.PackageFamilyName){throw 'Windows 返回的进程身份不正确，尚不能确认恢复。'}
Write-Output "已通过正式入口启动 Codex（PID $activated，应用包身份正确）。页面加载情况请在 Codex 中确认。"