#cinst au # AU Requires 5.0 now which isn't in the machine and requires manual powershell update: `cinst powershell`
cinst conemu
cinst notepadplusplus
cinst everything
cinst myuninst
cinst rapidee
cinst copyq

mkdir (Split-Path $Profile) -ea 0

@'
function c() {
    import-module $Env:ChocolateyInstall\helpers\chocolateyInstaller.psm1 -ea ignore
    cd c:\packages -ea ignore
}
'@ -replace "`n", "`r`n" | Out-File -Append $Profile

. $PSScriptRoot\Register-LoginTask.ps1
Register-LoginTask "$Env:PROGRAMFILES\Everything\Everything.exe" -Arguments '-startup' -RunElevated
Register-LoginTask "${env:ProgramFiles(x86)}\Copyq\copyq.exe" -RunElevated

