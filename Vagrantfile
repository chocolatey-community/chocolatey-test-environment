# Vagrant File (Vagrantfile)
# http://docs.vagrantup.com/v2/vagrantfile/index.html

# 2.4.9 is the first version of Vagrant that supports VirtualBox 7.2, which the
# box is built and tested with.
Vagrant.require_version ">= 2.4.9"

# http://docs.vagrantup.com/v2/vagrantfile/machine_settings.html
Vagrant.configure("2") do |config|
  # Build this box from
  # https://github.com/chocolatey-community/chocolatey-test-environment-box
  # and add it with `vagrant box add --name chocolatey/test-environment`; see
  # "Building the Box" in the ReadMe. It is no longer downloaded from the
  # HCP Vagrant Registry.
  config.vm.box = "chocolatey/test-environment"

  # http://docs.vagrantup.com/v2/providers/configuration.html
  # http://docs.vagrantup.com/v2/virtualbox/configuration.html
  config.vm.provider :virtualbox do |v, override|
    # Show the GUI
    v.gui = true
    # 4GB RAM
    v.customize ["modifyvm", :id, "--memory", "4096"]
    # 2 CPUs
    v.customize ["modifyvm", :id, "--cpus", "2"]
    # Video RAM is 32 MB
    v.customize ["modifyvm", :id, "--vram", 32]
    # For better DNS resolution
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # No audio
    v.customize ["modifyvm", :id, "--audio-enabled", "off"]
    # Clipboard enabled
    v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    v.customize ["modifyvm", :id, "--draganddrop", "hosttoguest"]
    # For performance
    v.customize ["modifyvm", :id, "--usb", "off"]
    # Huge performance gain here
    v.linked_clone = true
  end

  # https://www.vagrantup.com/docs/hyperv/configuration.html
  # https://technet.microsoft.com/en-us/library/dn798297(v=ws.11).aspx
  config.vm.provider :hyperv do |v, override|
    # 4GB RAM
    v.memory = 4096
    v.maxmemory = nil
    # 2 CPUs
    v.cpus = 2
    # The time in seconds to wait for the virtual machine to report an IP address
    v.ip_address_timeout = 240
    # Use differencing disk instead of cloning whole VHD
    v.linked_clone = true
    v.vm_integration_services = {
      guest_service_interface: true,
      heartbeat: true,
      key_value_pair_exchange: true,
      shutdown: true,
      time_synchronization: true,
      vss: true
  }
  end

  # username/password for accessing the image
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"
  config.winrm.port = 55985
  # a long boot timeout is needed for slow host systems
  config.vm.boot_timeout = 1800
  # to avoid WinRM errors in the middle of booting, we ensure that (max_tries * retry_delay) > boot_timeout:
  config.winrm.max_tries = 900
  config.winrm.retry_delay = 2
  # explicitly tell Vagrant the guest is Windows
  config.vm.guest = :windows
  config.vm.communicator = "winrm"

  # Synced folders - http://docs.vagrantup.com/v2/synced-folders/
  # A synced folder is a fancy term for shared folders - it takes a folder on
  # the host and shares it with the guest (vagrant) image. The entire folder
  # where the Vagrantfile is located is always shared as `c:\vagrant` (the
  # naming of this directory being `vagrant` is just a coincedence).
  # Share `packages` directory as `C:\packages`
  config.vm.synced_folder "packages", "/packages"
  #config.vm.synced_folder "temp", "/Users/vagrant/AppData/Local/Temp/chocolatey"
  # not recommended for sharing, it may have issues with `vagrant sandbox rollback`
  #config.vm.synced_folder "chocolatey", "/ProgramData/chocolatey"

  # Port forward WinRM / RDP
  # Bound to 127.0.0.1 so only this computer can reach them, because the box's
  # credentials are well known. Without host_ip, Vagrant binds forwarded ports
  # to every network interface on the host.
  config.vm.network :forwarded_port, guest: 5985, host: 55985, id: "winrm", auto_correct: true, host_ip: "127.0.0.1"
  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true, host_ip: "127.0.0.1"
  # Port forward SSH (ssh is forwarded by default in most versions of Vagrant,
  # but be sure). This is not necessary if you are not using SSH, but it doesn't
  # hurt anything to have it
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true, host_ip: "127.0.0.1"

  # Provisioners - http://docs.vagrantup.com/v2/provisioning/
  # In this specific vagrant usage, we are using the shell provisioner
  # http://docs.vagrantup.com/v2/provisioning/shell.html
  config.vm.provision :shell, :path => "shell/PrepareWindows.ps1", :powershell_elevated_interactive => true
  config.vm.provision :shell, :path => "shell/InstallNet4.ps1", :powershell_elevated_interactive => true
  config.vm.provision :shell, :path => "shell/InstallChocolatey.ps1", :powershell_elevated_interactive => true
  config.vm.provision :shell, :path => "shell/NotifyGuiAppsOfEnvironmentChanges.ps1", :powershell_elevated_interactive => true
  config.vm.provision :shell, :path => "shell/PostSetup.ps1", :powershell_elevated_interactive => true

$packageTestScript = <<SCRIPT
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
SCRIPT

  config.vm.provision :shell, :inline => $packageTestScript, :powershell_elevated_interactive => true
end
