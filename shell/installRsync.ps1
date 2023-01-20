choco install cygwin -y

& C:\tools\cygwin\cygwinsetup.exe --quiet-mode --packages rsync

New-Item -ItemType Directory -Force C:\vagrant
& C:\tools\cygwin\bin\ln -sT /cygdrive/c/vagrant /vagrant

New-Item -ItemType Directory -Force C:\packages
& C:\tools\cygwin\bin\ln -sT /cygdrive/c/packages /packages

If (!($Env:PATH | Select-String -SimpleMatch "C:\tools\cygwin\bin")) {
    $Env:PATH += ";C:\tools\cygwin\bin"
    [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";C:\tools\cygwin\bin", [EnvironmentVariableTarget]::Machine)
}