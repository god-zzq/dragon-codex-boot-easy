using System;
using System.Diagnostics;
using System.Reflection;
using System.Windows;
using System.Windows.Threading;
using DragonCodexBoot;
namespace DragonCodexBoot {
 public static class AppActivation { public static uint Activate(Config cfg) { return (uint)Process.GetCurrentProcess().Id; } }
}
class HandoffReplacementTest {
 [STAThread] static int Main(string[] args) {
  Config cfg=Entry.ReadConfig(args[0]);
  cfg.Video=System.IO.Path.Combine(args[0],cfg.Video);
  cfg.ProcessNames=new[]{Process.GetCurrentProcess().ProcessName};
  cfg.ProcessPathContains="HandoffReplacementTest";
  cfg.AppLaunch="test-fixture"; // Fixture windows are intentionally outside an MSIX package.
  Application app=new Application();app.ShutdownMode=ShutdownMode.OnExplicitShutdown;
  Window first=new Window {Width=950,Height=720,Title="Launcher test fixture"};first.Show();
  BootWindow boot=new BootWindow(cfg,args[1]);
  bool replaced=false,premature=false;Window second=null;
  Stopwatch clock=Stopwatch.StartNew();
  boot.Loaded+=delegate {
   typeof(BootWindow).GetMethod("HandOff",BindingFlags.Instance|BindingFlags.NonPublic).Invoke(boot,null);
  };
  boot.Closed+=delegate {
   premature=clock.Elapsed.TotalSeconds<7.5||!replaced;
   Console.WriteLine("closed elapsed="+clock.Elapsed.TotalSeconds.ToString("F1")+" replacement="+replaced+" premature="+premature);
   if(second!=null)second.Close();app.Shutdown(premature?1:0);
  };
  DispatcherTimer timer=new DispatcherTimer();timer.Interval=TimeSpan.FromMilliseconds(100);
  timer.Tick+=delegate {
   if(!replaced&&clock.Elapsed.TotalSeconds>1) {
    first.Close();second=new Window {Width=1050,Height=760,Title="Replacement launcher test fixture"};second.Show();second.Activate();
    replaced=true;Console.WriteLine("fixture replaced");
   }
   if(clock.Elapsed.TotalSeconds>12){Console.WriteLine("FAIL: handoff monitor did not complete");app.Shutdown(2);}
  };
  timer.Start();boot.Show();return app.Run();
 }
}
