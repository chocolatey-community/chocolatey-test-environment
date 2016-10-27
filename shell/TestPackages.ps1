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
Write-Host ("{0}`n{1}`n{0}`n" -f ('='*60), "TESTING FOLLOWING PACKAGES: $packages")

foreach ($package in $packages) {
    $p = $package -split ':'; $name = $p[0]; $ver = $p[1]
    Write-Host ("{0}`n{1}`n" -f ('-'*60), "PACKAGE: $package")

    $options_path = "c:\packages\$($package -replace ':', '.').xml"
    $options = gi $options_path -ea 0
    if ($options) {
        $options = Import-CliXml $options_path
        Write-Host 'OPTIONS:' $options_path
        $options
    }
    Write-Host ('-'*60) "`n"

    $do_install = if ($options) { $options.Install } else { $true }

    if ($do_install) {
        Write-Host 'TESTING INSTALL FOR' $package
        $choco_cmd = "choco install -fy $name --allow-downgrade"
        $choco_cmd += if ($ver) { " --version $ver" }
        $choco_cmd += ' --source "''{0}''"' -f 'c:\packages;http://chocolatey.org/api/v2/'
        $choco_cmd += if ($options.Parameters) { "  --params $options.Parameters" }

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

    if ($options.Uninstall) {
        Write-Host 'TESTING UNINSTALL FOR' $package
        $choco_cmd = "choco uninstall -fy $name"
        Write-Host "Choco cmd: $choco_cmd"
        iex $choco_cmd
    }
}
