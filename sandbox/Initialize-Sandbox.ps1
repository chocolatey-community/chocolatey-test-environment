# Runs inside Windows Sandbox, started by chocolatey-test-environment.wsb. Installs
# Chocolatey CLI the same way the Vagrant environment does, then leaves this window
# open for testing.

& (Join-Path $PSScriptRoot '..\shell\InstallChocolatey.ps1')

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  Write-Error 'Chocolatey CLI did not install. Check the output above.'
  return
}

Write-Host ''
Write-Host 'Chocolatey CLI is ready. The packages folder is available as C:\packages.' -ForegroundColor Green
Write-Host @"

Test a package (replace <package-id>):
  choco install <package-id> --source="'C:\packages;https://community.chocolatey.org/api/v2/'" --verbose --debug
  choco uninstall <package-id> --verbose --debug

Close Windows Sandbox when you're done. Everything in it is discarded.
"@
