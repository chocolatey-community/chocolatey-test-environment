cinst au
cinst conemu
cinst everything
cinst copyq
cinst myuninst

mkdir (Split-Path $Profile) -ea 0

@"
import-module `$Env:ChocolateyInstall\helpers\chocolateyInstaller.psm1 -ea ignore
cd c:\packages -ea ignore
"@ | Out-File -Append $Profile

