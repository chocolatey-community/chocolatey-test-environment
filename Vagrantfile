Vagrant.require_version ">= 1.8"

# http://docs.vagrantup.com/v2/vagrantfile/machine_settings.html
Vagrant.configure("2") do |config|
    # This setting will download the atlas box at https://atlas.hashicorp.com/ferventcoder/boxes/win2012r2-x64-nocm
    config.vm.box = "ferventcoder/win2012r2-x64-nocm"

    # http://docs.vagrantup.com/v2/virtualbox/configuration.html
    config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.linked_clone = true

        v.customize ["modifyvm", :id, "--memory", "4096"]
        v.customize ["modifyvm", :id, "--cpus", "2"]
        v.customize ["modifyvm", :id, "--vram", 32]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--audio", "none"]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["modifyvm", :id, "--draganddrop", "hosttoguest"]
        v.customize ["modifyvm", :id, "--usb", "off"]
    end

    config.windows.halt_timeout = 20            # timeout of waiting for image to stop running - may be a deprecated setting
    config.winrm.username       = "vagrant"
    config.winrm.password       = "vagrant"
    config.vm.guest             = :windows
    config.vm.communicator      = "winrm"

    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"

    # Synced folders - http://docs.vagrantup.com/v2/synced-folders/
    config.vm.synced_folder "packages", "/packages"
    config.vm.synced_folder "shell", "/scripts"
    #config.vm.synced_folder "temp", "/Users/vagrant/AppData/Local/Temp/chocolatey"
    # not recommended for sharing, it may have issues with `vagrant sandbox rollback`
    #config.vm.synced_folder "chocolatey", "/ProgramData/chocolatey"

    # Port forward WinRM / RDP
    config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true

    # http://docs.vagrantup.com/v2/provisioning/shell.html
    scripts = [
                { :path => "shell/PrepareWindows.ps1" },
                { :path => "shell/InstallNet4.ps1" },
                { :path => "shell/InstallChocolatey.ps1" },
                { :path => "shell/NotifyGuiAppsOfEnvironmentChanges.ps1"},
                { :path => "shell/InstallTools.ps1" },
                { :path => "shell/TestPackages.ps1", :args => ENV['PACKAGES'], :run => "always" },
                { :path => "User.ps1", :run => "always" }
              ]
    scripts.each do |s|
        s[:powershell_elevated_interactive] = true if Vagrant::VERSION >= '1.8.0'
        config.vm.provision :shell, s
    end
end
