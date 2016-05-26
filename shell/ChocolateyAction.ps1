$ErrorActionPreference = "Stop"
$env:PATH +=";$($env:SystemDrive)\ProgramData\chocolatey\bin"
# https://github.com/chocolatey/choco/issues/512
$validExitCodes = @(0, 1605, 1614, 1641, 3010)

[[Command]]

$exitCode = $LASTEXITCODE

Write-Host "Exit code was $exitCode"
if ($validExitCodes -contains $exitCode) {
  Exit 0
}

Exit $exitCode
