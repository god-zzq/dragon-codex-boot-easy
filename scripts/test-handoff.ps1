# Interactive Windows integration test. Opens only temporary fixture windows.
$ErrorActionPreference='Stop'
$repo=Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'build.ps1')
$root=Join-Path $repo '.local/handoff-qa'
New-Item -ItemType Directory -Path $root -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repo 'config/launcher.example.json') -Destination (Join-Path $root 'launcher.json') -Force
$framework=Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319'
$refs=@('System.dll','System.Core.dll','System.Xaml.dll','System.Web.Extensions.dll','System.Drawing.dll','System.Windows.Forms.dll')
foreach($name in @('WindowsBase.dll','PresentationCore.dll','PresentationFramework.dll')){$refs+=Join-Path $framework ('WPF/'+$name)}
$exe=Join-Path $root 'HandoffReplacementTest.exe'
$argsList=@('/nologo','/target:exe','/platform:x64','/main:HandoffReplacementTest',('/win32manifest:'+(Join-Path $repo 'src/app.manifest')),('/out:'+$exe))
foreach($ref in $refs){$argsList+='/r:'+$ref}
$argsList+=Join-Path $repo 'src/DragonCodexBoot.cs'
$argsList+=Join-Path $repo 'tests/HandoffReplacementTest.cs'
& (Join-Path $framework 'csc.exe') @argsList
if($LASTEXITCODE -ne 0){throw 'Fixture compilation failed.'}
& $exe (Join-Path $repo 'build/DragonCodexBoot') $root
if($LASTEXITCODE -ne 0){throw 'Window replacement integration test failed.'}