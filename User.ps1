Write-Host 'User script can be added in User.ps1'


setx.exe trigger 1  # run arbitrary win32 application so LASTEXITCODE is 0
$ErrorActionPreference = "Stop"
$env:PATH +=";$($env:SystemDrive)\\ProgramData\\chocolatey\\bin"

# https://github.com/chocolatey/choco/issues/512
$validExitCodes = @(0, 1605, 1614, 1641, 3010)
Write-Output "Testing package if a line is uncommented."

# THIS IS WHAT YOU CHANGE
# - uncomment one of the two and edit it appropriately
# - See the README for details
#choco.exe install -fdvy INSERT_NAME --version INSERT_VERSION  --allow-downgrade
#choco.exe install -fdvy INSERT_NAME  --allow-downgrade --source "'c:\\packages;http://chocolatey.org/api/v2/'"

$exitCode = $LASTEXITCODE
Write-Host "Exit code was $exitCode"
if ($validExitCodes -contains $exitCode) {
  Exit 0
}
Exit $exitCode
