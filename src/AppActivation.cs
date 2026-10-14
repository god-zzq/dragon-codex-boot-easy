using System;
using System.Runtime.InteropServices;
namespace DragonCodexBoot {
 [ComImport, Guid("2E941141-7F97-4756-BA1D-9DECDE894A3D"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
 internal interface IApplicationActivationManager {
  [PreserveSig] int ActivateApplication([MarshalAs(UnmanagedType.LPWStr)] string appId,
   [MarshalAs(UnmanagedType.LPWStr)] string arguments,uint options,out uint processId);
  [PreserveSig] int ActivateForFile([MarshalAs(UnmanagedType.LPWStr)] string appId,IntPtr items,
   [MarshalAs(UnmanagedType.LPWStr)] string verb,out uint processId);
  [PreserveSig] int ActivateForProtocol([MarshalAs(UnmanagedType.LPWStr)] string appId,IntPtr items,out uint processId);
 }
 public static class AppActivation {
  public static uint Activate(Config cfg) {
   string prefix="shell:AppsFolder\\";
   if(!cfg.AppLaunch.StartsWith(prefix,StringComparison.OrdinalIgnoreCase))
    throw new ArgumentException("Expected packaged application identity.");
   object manager=Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")));
   try {
    uint pid;int hr=((IApplicationActivationManager)manager).ActivateApplication(cfg.AppLaunch.Substring(prefix.Length),"",0,out pid);
    if(hr<0)Marshal.ThrowExceptionForHR(hr);
    if(pid==0)throw new InvalidOperationException("Windows returned no application process.");
    return pid;
   } finally { Marshal.FinalReleaseComObject(manager); }
  }
 }
}