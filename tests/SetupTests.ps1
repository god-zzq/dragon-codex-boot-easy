$ErrorActionPreference='Stop'
$repo=Split-Path -Parent $PSScriptRoot
$fixture=Join-Path $repo ('.local/setup-test-'+[Guid]::NewGuid().ToString('N'))
$root=Join-Path $fixture 'installed'
$desktop=Join-Path $fixture 'Desktop'
$programs=Join-Path $fixture 'Programs'
$common=@{SourceRoot=(Join-Path $repo 'build/DragonCodexBoot');InstallRoot=$root;DesktopRoot=$desktop;ProgramsRoot=$programs;AppIdentity='OpenAI.Codex_test!App';NoLaunch=$true}
$setup=Join-Path $repo 'scripts/setup.ps1'
& $setup @common
& $setup @common -Action Verify
$config=Get-Content -LiteralPath (Join-Path $root 'launcher.json') -Raw | ConvertFrom-Json
if($config.AppLaunch -ne 'shell:AppsFolder\OpenAI.Codex_test!App' -or $config.AutoReplaceEntrypoints -or $config.ScanAllLocalDrives){throw 'Detection/configuration failure.'}
& $setup @common
& $setup @common -Action Verify
$custom=Join-Path $root 'media/custom.txt'
Set-Content -LiteralPath $custom -Value 'preserve me'
$shortcutName='Codex 龙娘启动（简易版）.lnk'
if([Text.Encoding]::Default.GetString([Text.Encoding]::Default.GetBytes($shortcutName)) -ne $shortcutName){$shortcutName='Dragon Codex Boot Easy.lnk'}
$linkPath=Join-Path $desktop $shortcutName
$shell=New-Object -ComObject WScript.Shell
$link=$shell.CreateShortcut($linkPath);$link.TargetPath=Join-Path $env:WINDIR 'explorer.exe';$link.Save()
& $setup @common -Action Uninstall
if(!(Test-Path -LiteralPath $custom) -or !(Test-Path -LiteralPath $linkPath)){throw 'Uninstall removed custom files or a changed shortcut.'}
if(Test-Path -LiteralPath (Join-Path $root 'DragonCodexBoot.exe')){throw 'Uninstall left the installed launcher.'}
if(Test-Path -LiteralPath (Join-Path $programs $shortcutName)){throw 'Uninstall left its owned shortcut.'}
& $setup @common -Action Uninstall
Write-Output 'PASS: install, application ID configuration, verification, reinstall, uninstall, repeated uninstall and preservation of custom files/changed shortcuts.'
