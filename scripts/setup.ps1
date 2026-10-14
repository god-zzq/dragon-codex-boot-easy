[CmdletBinding()]
param(
 [ValidateSet('Install','Uninstall','Verify')][string]$Action='Install',
 [string]$SourceRoot,
 [string]$InstallRoot=(Join-Path $env:LOCALAPPDATA 'DragonCodexBootEasy'),
 [string]$DesktopRoot=[Environment]::GetFolderPath('Desktop'),
 [string]$ProgramsRoot=[Environment]::GetFolderPath('Programs'),
 [string]$AppIdentity,
 [switch]$NoLaunch
)
$ErrorActionPreference='Stop'
if(!$SourceRoot){$SourceRoot=Split-Path -Parent $PSScriptRoot}
$InstallRoot=[IO.Path]::GetFullPath($InstallRoot)
$statePath=Join-Path $InstallRoot 'installation.json'
$exe=Join-Path $InstallRoot 'DragonCodexBoot.exe'
$state=$null
if(Test-Path -LiteralPath $statePath){$state=Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json}
if($state -and ($state.Product -ne 'DragonCodexBootEasy' -or $state.Root -ne $InstallRoot)){throw 'Installation record does not match this directory.'}
$shell=New-Object -ComObject WScript.Shell
function OwnedShortcut($path){
 if(!(Test-Path -LiteralPath $path)){return $false}
 return $shell.CreateShortcut($path).TargetPath -eq $exe
}
function SafeChild($relative){
 $path=[IO.Path]::GetFullPath((Join-Path $InstallRoot $relative))
 if(!$path.StartsWith($InstallRoot.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Invalid installation path.'}
 return $path
}
if($Action -eq 'Verify'){
 if(!$state){throw 'Installation record missing.'}
 foreach($relative in $state.Files){if(!(Test-Path -LiteralPath (SafeChild $relative))){throw "Missing installed file: $relative"}}
 foreach($path in $state.Shortcuts){if(!(OwnedShortcut $path)){throw "Shortcut differs: $path"}}
 Write-Output 'PASS: installed files and shortcuts verified.'
 return
}
if($Action -eq 'Uninstall'){
 if(!$state){Write-Output 'No easy edition installation found.';return}
 foreach($path in $state.Shortcuts){if(OwnedShortcut $path){Remove-Item -LiteralPath $path}}
 # Only files listed by this installer are removed. Custom videos and logs remain.
 foreach($relative in $state.Files){$path=SafeChild $relative;if(Test-Path -LiteralPath $path -PathType Leaf){Remove-Item -LiteralPath $path}}
 Remove-Item -LiteralPath $statePath
 Write-Output 'Uninstalled. The official Codex client and custom files are preserved.'
 return
}
if(!$AppIdentity){
 $package=Get-AppxPackage -Name 'OpenAI.Codex' | Select-Object -First 1
 if(!$package){throw '请先安装 Windows 版 Codex，再重新双击 Install.cmd。'}
 [xml]$manifest=Get-Content -LiteralPath (Join-Path $package.InstallLocation 'AppxManifest.xml') -Raw
 $application=@($manifest.Package.Applications.Application) | Where-Object { $_.Executable -match '(ChatGPT|Codex)\.exe$' } | Select-Object -First 1
 if(!$application){throw '无法识别 Codex 应用入口，请使用官方入口确认客户端已安装。'}
 $AppIdentity=$package.PackageFamilyName+'!'+$application.Id
}
if(!(Test-Path -LiteralPath (Join-Path $SourceRoot 'DragonCodexBoot.exe'))){throw '请先完整解压 Release ZIP，再运行 Install.cmd；源码需要先执行 scripts/build.ps1。'}
foreach($relative in @('DragonCodexBoot.exe','launcher.json','media/startup.mp4','scripts/setup.ps1','Uninstall.cmd')){
 if(!(Test-Path -LiteralPath (Join-Path $SourceRoot $relative))){throw "程序包不完整：$relative"}
}
if((Test-Path -LiteralPath $InstallRoot) -and !$state -and @(Get-ChildItem -LiteralPath $InstallRoot -Force).Count){throw 'Installation folder already contains unrelated files. No files changed.'}
$links=@((Join-Path $DesktopRoot 'Codex 龙娘启动（简易版）.lnk'),(Join-Path $ProgramsRoot 'Codex 龙娘启动（简易版）.lnk'))
foreach($path in $links){if((Test-Path -LiteralPath $path) -and !(OwnedShortcut $path)){throw "已有同名快捷方式，已保留：$path"}}
if(@(Get-Process -Name 'DragonCodexBoot' -ErrorAction SilentlyContinue).Count){throw '请先等启动动画结束，再安装或更新。'}
New-Item -ItemType Directory -Path $InstallRoot,$DesktopRoot,$ProgramsRoot -Force | Out-Null
$files=New-Object 'System.Collections.Generic.List[string]'
foreach($name in @('DragonCodexBoot.exe','launcher.json','README.md','LICENSE','THIRD_PARTY_NOTICES.md','VERSION','Start.cmd','Uninstall.cmd')){
 if(Test-Path -LiteralPath (Join-Path $SourceRoot $name)){$files.Add($name)}
}
foreach($folder in @('media','scripts','docs')){
 foreach($item in Get-ChildItem -LiteralPath (Join-Path $SourceRoot $folder) -File -Recurse){
  $files.Add($item.FullName.Substring([IO.Path]::GetFullPath($SourceRoot).TrimEnd('\').Length+1))
 }
}
foreach($relative in $files){
 $destination=SafeChild $relative
 New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
 Copy-Item -LiteralPath (Join-Path $SourceRoot $relative) -Destination $destination -Force
 if((Get-FileHash -LiteralPath $destination).Hash -ne (Get-FileHash -LiteralPath (Join-Path $SourceRoot $relative)).Hash){throw "复制校验失败：$relative"}
}
$configPath=Join-Path $InstallRoot 'launcher.json'
$config=Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$config.AppLaunch='shell:AppsFolder\'+$AppIdentity
$config.ProcessPathContains=$AppIdentity.Split('!')[0].Split('_')[0]+'_'
$config.ProcessNames=@('ChatGPT','Codex')
$config.AutoReplaceEntrypoints=$false;$config.ScanAllLocalDrives=$false
$config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $configPath -Encoding UTF8
foreach($path in $links){
 $link=$shell.CreateShortcut($path);$link.TargetPath=$exe;$link.WorkingDirectory=$InstallRoot
 $link.Arguments='';$link.IconLocation=$exe+',0';$link.Description='Codex 龙娘启动动画（简易版）';$link.Save()
 if(!(OwnedShortcut $path)){throw 'Shortcut verification failed.'}
}
@{Product='DragonCodexBootEasy';Root=$InstallRoot;Files=@($files);Shortcuts=$links;Version=(Get-Content -LiteralPath (Join-Path $InstallRoot 'VERSION') -Raw).Trim()} |
 ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statePath -Encoding UTF8
Write-Output "安装完成！以后双击桌面的「Codex 龙娘启动（简易版）」即可。安装位置：$InstallRoot"
if(!$NoLaunch){Start-Process -FilePath $exe -WorkingDirectory $InstallRoot -WindowStyle Hidden}
