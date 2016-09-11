$validExitCodes = @(0, 1605, 1614, 1641, 3010)

choco install ketarin -y

$exitCode = $LASTEXITCODE
Write-Host "Exit code was $exitCode"
if (!($validExitCodes -contains $exitCode)) {
  Exit $exitCode
}


