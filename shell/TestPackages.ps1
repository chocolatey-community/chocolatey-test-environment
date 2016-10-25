#Params: String "pkg1:ver1 pkg2:ver2 ...". Version is optional.

$Env:PATH +=";$($env:SystemDrive)\\ProgramData\\chocolatey\\bin"

# https://github.com/chocolatey/choco/issues/512
$validExitCodes = @(0, 1605, 1614, 1641, 3010)

$packages = @()
if ($CommunityPackages = $args) {
    Write-Host "Community packages:" $CommunityPackages
    $packages += $CommunityPackages
}

$packages += ls c:\packages\*.nupkg | Split-Path -Leaf | % {(($_ -split '\.',2) -join ':') -replace '.nupkg' }
Write-Host ('-'*60) "`n" 'PACKAGES: ' "$packages" "`n" ('-'*60)

foreach ($package in $packages) {
    $p = $package -split ':'; $name = $p[0]; $ver = $p[1]

    $choco_cmd = "choco install -fy $name --allow-downgrade"
    $choco_cmd += if ($ver) { " --version $ver" }
    $choco_cmd += ' --source "''{0}''"' -f 'c:\packages;http://chocolatey.org/api/v2/'

    Write-Host "Choco cmd: $choco_cmd"
    $LastExitCode = 0
    iex $choco_cmd
    $exitCode = $LastExitCode

    if ($validExitCodes -contains $exitCode) {
        Write-Host "Exit code for $package was $exitCode"
    } else {
        Write-Error "Exit code for package $name is $exitCode"
    }
}
