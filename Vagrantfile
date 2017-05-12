﻿# Vagrant File (Vagrantfile)
# http://docs.vagrantup.com/v2/vagrantfile/index.html

# Windows guests can't even be used with Vagrant versions less than 1.3.5.
Vagrant.require_version ">= 1.3.5"
if Vagrant::VERSION < '1.6.0'
  # Vagrant versions less than 1.6.x do not have a built-in way to
  # communicate with Windows guest images.For versions less than 1.6.x
  # the vagrant-windows plugin is required.
  Vagrant.require_plugin "vagrant-windows"
end

# http://docs.vagrantup.com/v2/vagrantfile/machine_settings.html
Vagrant.configure("2") do |config|
  # This setting will download the atlas box at
  # https://atlas.hashicorp.com/ferventcoder/boxes/win2012r2-x64-nocm
  config.vm.box = "ferventcoder/win2012r2-x64-nocm"

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
    # No audo
    v.customize ["modifyvm", :id, "--audio", "none"]
    # Clipboard enabled
    v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    v.customize ["modifyvm", :id, "--draganddrop", "hosttoguest"]
    # For performance
    v.customize ["modifyvm", :id, "--usb", "off"]
    # Huge performance gain here
    v.linked_clone = true if Vagrant::VERSION >= '1.8.0'
  end

  # timeout of waiting for image to stop running - may be a deprecated setting
  config.windows.halt_timeout = 20
  # username/password for accessing the image
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"
  # explicitly tell Vagrant the guest is Windows
  config.vm.guest = :windows

  if Vagrant::VERSION >= '1.6.0'
    # If we are on greater than v1.6.x, we are using the built-in version
    # of communicating with Windows. For versions less than 1.6 the
    # `vagrant-windows` plugin would need to be installed and uses monkey
    # patching to override the communicator.
    config.vm.communicator = "winrm"
  end

  # Synced folders - http://docs.vagrantup.com/v2/synced-folders/
  # A synced folder is a fancy term for shared folders - it takes a folder on
  # the host and shares it with the guest (vagrant) image. The entire folder
  # where the Vagrantfile is located is always shared as `c:\vagrant` (the
  # naming of this directory being `vagrant` is just a coincedence).
  # Share `packages` directory as `C:\packages`
  config.vm.synced_folder "packages", "/packages"
  config.vm.synced_folder "shell", "/shell"
  #config.vm.synced_folder "temp", "/Users/vagrant/AppData/Local/Temp/chocolatey"
  # not recommended for sharing, it may have issues with `vagrant sandbox rollback`
  #config.vm.synced_folder "chocolatey", "/ProgramData/chocolatey"

  # Port forward WinRM / RDP
  # Vagrant 1.9.3 - if you run into Errno::EADDRNOTAVAIL (https://github.com/mitchellh/vagrant/issues/8395), 
  #  add host_ip: "127.0.0.1" for it to work
  config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true #, host_ip: "127.0.0.1"
  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true #, host_ip: "127.0.0.1"
  # Port forward SSH (ssh is forwarded by default in most versions of Vagrant,
  # but be sure). This is not necessary if you are not using SSH, but it doesn't
  # hurt anything to have it
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true #, host_ip: "127.0.0.1"

  # Provisioners - http://docs.vagrantup.com/v2/provisioning/
  # In this specific vagrant usage, we are using the shell provisioner
  # http://docs.vagrantup.com/v2/provisioning/shell.html

  scripts = [
                { :path => "shell/PrepareWindows.ps1" },
                { :path => "shell/InstallNet4.ps1" },
                { :path => "shell/InstallChocolatey.ps1" },
                { :path => "shell/NotifyGuiAppsOfEnvironmentChanges.ps1"},
                { :path => "shell/TestPackages.ps1", :args => ENV['PACKAGES'] },
                { :path => "User.ps1"} ]

  scripts.each do |s|
      s[:powershell_elevated_interactive] = true if Vagrant::VERSION >= '1.8.0'
      config.vm.provision :shell, s
  end
end
