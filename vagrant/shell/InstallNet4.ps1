$NetFx4ClientUrl = 'http://download.microsoft.com/download/5/6/2/562A10F9-C9F4-4313-A044-9C94E0A8FAC8/dotNetFx40_Client_x86_x64.exe'
$NetFx4FullUrl = 'http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe'
$NetFx4Url = $NetFx4FullUrl
$NetFx4Path = 'c:\vagrant\resources\NetFx4'
$NetFx4InstallerFile = 'dotNetFx40_Full_x86_x64.exe'
$NetFx4Installer = Join-Path $NetFx4Path $NetFx4InstallerFile
$netFx4InstallTries = 0

function Enable-Net40 {
param(
  $forceFxInstall = $false
)
  if ([IntPtr]::Size -eq 8) {$fx="framework64"} else {$fx="framework"}

  if(!(test-path "$env:windir\Microsoft.Net\$fx\v4.0.30319") -or $forceFxInstall) {
    if (!(Test-Path $NetFx4Path)) {
      Write-Host "Creating folder `'$NetFx4Path`'"
      $null = New-Item -Path "$NetFx4Path" -ItemType Directory
    }

    $netFx4InstallTries += 1

    if (!(Test-Path $NetFx4Installer)) {
      Write-Host "Downloading `'$NetFx4Url`' to `'$NetFx4Installer`' - the installer is 40+ MBs, so this could take awhile on a slow connection."
      (New-Object Net.WebClient).DownloadFile("$NetFx4Url","$NetFx4Installer")
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.WorkingDirectory = "$NetFx4Path"
    $psi.FileName = "$NetFx4InstallerFile"
    # https://msdn.microsoft.com/library/ee942965(v=VS.100).aspx#command_line_options
    # http://blogs.msdn.com/b/astebner/archive/2010/05/12/10011664.aspx
    # For the actual setup.exe (if you want to unpack first) - /repair /x86 /x64 /ia64 /parameterfolder Client /q /norestart
    $psi.Arguments = "/q /norestart /repair"

    Write-Host "Installing `'$NetFx4Installer`' - this may take awhile with no output."
    $s = [System.Diagnostics.Process]::Start($psi);
    $s.WaitForExit();
    if ($s.ExitCode -ne 0 -and $s.ExitCode -ne 3010) {
      if ($netFx4InstallTries -eq 2) {
        Write-Warning ".NET Framework install failed with exit code `'$($s.ExitCode)`'. `n This could cause other things to fail."
        #throw "Error installing .NET Framework 4.0 (exit code $($s.ExitCode)). `n Please install the .NET Framework 4.0 manually and then try to install Chocolatey again. `n Download at `'$NetFx4Url`'"
      } else {
        Write-Warning "First try of .NET framework install failed with exit code `'$($s.ExitCode)`'. Trying again."
        Enable-Net40 $true
      }
    }
  }
}

Enable-Net40
