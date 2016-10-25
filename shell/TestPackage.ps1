$ErrorActionPreference = "Stop"
$LastExitCode = 0
$env:PATH +=";$($env:SystemDrive)\\ProgramData\\chocolatey\\bin"

# https://github.com/chocolatey/choco/issues/512
$validExitCodes = @(0, 1605, 1614, 1641, 3010)

$package  = ls c:\packages\*.nupkg
if (!$package) { $package = ls c:\packages\remote\*.nupkg; $remote=$true }
if (!$package) { Write-Host 'No packages found in directory packages or packages\remote'; return }

$package_name = ($package | select -First 1) -split '\.' | select -First 1 | Split-Path -Leaf
Write-Host 'Package name: ' $package_name

$choco_args = "install -fdvy $package_name --allow-downgrade"
if (!$remote) { $choco_args += ' --source "''{0}''"' -f 'c:\packages;http://chocolatey.org/api/v2/' }

Write-Host "Choco args: $choco_args"
iex "choco.exe $choco_args"
$exitCode = $LastExitCode

Write-Host "Exit code was $exitCode"
if ($validExitCodes -contains $exitCode) { Exit 0 }
exit $exitCode
