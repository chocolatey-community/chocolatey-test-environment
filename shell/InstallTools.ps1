cinst au
cinst conemu
cinst notepadplusplus
cinst everything
cinst myuninst
cinst copyq

mkdir (Split-Path $Profile) -ea 0

@'
function c() {
    import-module $Env:ChocolateyInstall\helpers\chocolateyInstaller.psm1 -ea ignore
    cd c:\packages -ea ignore
}
'@ -replace "`n", "`r`n" | Out-File -Append $Profile

Register-LoginTask "$Env:PROGRAMFILES\Everything\Everything.exe" -Arguments '-startup' -RunElevated
Register-LoginTask "${env:ProgramFiles(x86)}\Copyq\copyq.exe" -RunElevated

