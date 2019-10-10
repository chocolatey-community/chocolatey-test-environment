param ([switch]$Uninstall)

#Params: String "pkg1:ver1 pkg2:ver2 ...". Version is optional.

$Env:PATH +=";$($env:SystemDrive)\\ProgramData\\chocolatey\\bin"

# https://github.com/chocolatey/choco/issues/512
$validExitCodes = @(0, 1605, 1614, 1641, 3010)

$packages = @()
if ($CommunityPackages = $args) {
    Write-Host "Community packages:" $CommunityPackages
    $packages += $CommunityPackages
}

#Add local packages to provided list of remote packages
$packages += ls c:\packages\*.nupkg | Split-Path -Leaf | % { ($_ -replace '((\.\d+)+(-[^-\.]+)?).nupkg', ':$1').Replace(':.', ':') }
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

    if (!$Uninstall) {
        $do_install = if ($options) { $options.Install } else { $true }

        if ($do_install) { Write-Host 'TESTING INSTALL FOR' $package }

        $choco_cmd = "choco install -fy $name --allow-downgrade"
        $choco_cmd += if ($ver) { " --version $ver" }
        $choco_cmd += ' --source "''{0}''"' -f 'c:\packages;http://chocolatey.org/api/v2/'
        $choco_cmd += if ($options.Parameters) { "  --params '{0}'" -f $options.Parameters }
        if (!$do_install) {
            Write-Host 'TESTING INSTALL DISABLED, REGISTERING PACKAGE'
            $choco_cmd += ' --skip-powershell'
        }

        Write-Host "CMD: $choco_cmd"
        $LastExitCode = 0
        iex $choco_cmd
        $exitCode = $LastExitCode

        if ($validExitCodes -contains $exitCode) {
            Write-Host "Exit code for $package was $exitCode"
        } else {
            Write-Error "Exit code for package $name is $exitCode"
        }
    }

    if ($Uninstall -or $options.Uninstall) {
        Write-Host 'TESTING UNINSTALL FOR' $package
        $choco_cmd = "choco uninstall -fy $name"
        Write-Host "Choco cmd: $choco_cmd"
        iex $choco_cmd
    }
}
