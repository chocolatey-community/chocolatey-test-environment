# Chocolatey Testing Environment

A testing environment setup similar to the [package-verifier](https://github.com/chocolatey/package-verifier/wiki) for testing packages.

When creating packages, please review https://github.com/chocolatey/choco/wiki/CreatePackages

## Requirements

You need a computer with:

* a 64-bit processor and OS
* Intel VT-x [enabled](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/) (usually not an issue if your computer is newer than 2011). This is necessary because we are using 64bit VMs.
* Hyper-V may need to be disabled for Virtualbox to work properly if your computer is a Windows box. **NOTE:** This may actually not be required. If required, run `bcdedit /set hypervisorlaunchtype off` then reboot.
* At least 10GB of free space.

## Setup

To install prerequisites:

```ps1
# Only if you use VirtualBox
choco install virtualbox 

# Only if you use Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
choco install vagrant
refreshenv
vagrant plugin install sahara
```

Now run one of the:

```ps1
vagrant up                       # uses vbox by default
vagrant up --provider hyperv     # uses hyper-v
```

Details:

* **VirtualBox 4.3.28+** [ `choco install virtualbox` ]
* **Vagrant 1.8.1+**  [ `choco install vagrant` ]
Linked clones is the huge reason here. You can technically use any version of Vagrant 1.3.5+, but you will get the best performance with 1.8.x.
  * **Vagrant Sahara plugin** [`vagrant plugin install sahara`]


## Running Verification Manually

**NOTE**: The CDN for packages on https://chocolatey.org will only update every 30 minutes. This means if you just pushed an updated version, within 30 minutes from the last access time of the package it will be updated. This is why the validator and verifier wait for 31 minutes prior to testing a package.

### Preparing the Testing Environment

 1. Ensure setup above is good on your machine.
 2. Fork and Clone this repository
 3. Open a command line (`PowerShell.exe`/`cmd.exe` on Windows, `bash` everywhere else) and navigate to the root folder of the repository.  You know you are in the right place when you do a `dir` or `ls` and `Vagrantfile` is in your path.
   * No idea if bash on Windows (through Git/CygWin) is supported. If you run into issues, it is better to just use `PowerShell.exe` or `cmd.exe`. Please do not file issues stating it doesn't work.
 4. Run `vagrant up` to prepare the machine for testing.
   * **Note** due to the way that vagrant works, the first time that you run this command, the vagrant box named __ferventcoder/win2012r2-x64-nocm__ needs to be downloaded from the [Atlas website](https://atlas.hashicorp.com/ferventcoder/boxes/win2012r2-x64-nocm).  This will take quite a while, and should only be attempted on a reasonably fast connection, that doesn't have any download limit restrictions. Once it has downloaded it will import the box and apply the scripts and configurations to the box as listed inside the `Vagrantfile`.  You can find the downloaded box in the `~/.vagrant.d` or `c:\users\username\.vagrant.d` folder.
 5. Now the box is ready for you to start testing against.
 1. Run the following command: `vagrant sandbox on`.  This takes a snapshot of the VM using the [vagrant plugin](https://github.com/jedi4ever/sahara) that was installed earlier. This means that after testing packages, the VM can be returned to this known "good" state.

### Testing a Package

Testing can be manual or fully automatic. 

#### Manual testing

For testing a package, you have two avenues. For a locally built package, you can drop the package into the `packages` folder in the root of the cloned repository - it is shared with the box as `C:\packages`, so you can run a command on the box or with the inline provisioner (recommended as it is a closer match to the verifier) using `--source c:\packages` as an argument for installation. If you are trying to reproduce/investigate a problem with a package already up on the website, you can use `--version number` with your install arguments and that will let you install a package that is not listed (in most cases not yet approved).

 1. Search the `User.ps1` script for `# THIS IS WHAT YOU CHANGE`.  Uncomment and edit the line which best meets the current situation that you are testing.
 1. Run `vagrant provision`.
 1. Watch the output and go to the box for further inspection if necessary.


#### Automatic testing

You can just copy your packages to the `packages` directory and automatic install will run during provision.  
Use environment variable `$Env:PACKAGES` to pass names and versions of community packages to install:

    $Env:PACKAGES = 'copyq dbeaver:2.7.1'; vagrant up --provision

For best experience use [AU](https://github.com/majkinetor/au) PowerShell module and its function `Test-Package` that can test install and/or uninstall both locally and using vagrant. 

The following example will run both install and uninstall for the package 'yed' and pass it custom parameter.

```powershell
C:\au-packages\yed> $au_Vagrant = 'c:\chocolatey\chocolatey-test-environment' #you can also add this to your profile
C:\au-packages\yed> Test-Package -VagrantClear -Parameters '/Shortcut'

Package info
  Path:         C:\au-packages\yed\yed.3.16.2.1.nupkg
  Name:         yed
  Version:      3.16.2.1
  Parameters:   /Shortcut
  Vagrant:      c:\chocolatey\chocolatey-test-environment

Testing package using vagrant
Removing existing vagrant packages

<STARTS VAGRANT IN ANOTHER SHELL>

==> default: Running provisioner: shell...
    default: Running: shell/TestPackages.ps1 as c:\tmp\vagrant-shell.ps1
==> default: ============================================================
==> default: TESTING FOLLOWING PACKAGES: yed:3.16.2.1
==> default: ============================================================
==> default:
==> default: ------------------------------------------------------------
==> default: PACKAGE: yed:3.16.2.1
==> default:
==> default: OPTIONS: c:\packages\yed.3.16.2.1.xml
==> default:
==> default: Name                           Value
==> default: ----                           -----
==> default: Install                        True
==> default: Uninstall                      True
==> default: Parameters                     /Shortcut
==> default: ------------------------------------------------------------
==> default:
==> default: TESTING INSTALL FOR yed:3.16.2.1
==> default: Choco cmd: choco install -fy yed --allow-downgrade --version 3.16.2.1 --source "'c:\packages;http://chocolatey.org/api/v2/'"  --params '/Shortcut'
==> default: Chocolatey v0.10.3
==> default: Installing the following packages:
==> default: yed
...
...
```

### Make Changes and Retest

When you need to investigate making changes and rerunning the tests, remember that we took a snapshot of the vagrant machine (the virtual machine), so we can rollback to the earlier state each time and move forward with testing changes without the possibility of lingering artifacts. This is why we are using the sahara vagrant plugin, it allows us to take a snapshot and then revert the virtual machine back to the previous state.

When you are ready to reset to the state just before installing:

 1. Run `vagrant sandbox rollback`
 1. Follow the steps in testing a package (previous section).

### Tearing Down the Testing Environment

**NOTE**: At any time you can:

* stop the box with `vagrant suspend`, `vagrant halt`
* delete the box with `vagrant destroy`

For more information on vagrant commands, see the [Vagrant Docs](http://docs.vagrantup.com/v2/cli/index.html)

## Differences Between This and Package Verifier Service

There are a couple of difference between the [verifier service]() and this environment.

 * The verifier is run without the GUI - meaning it is run in a headless state. There is no box to interact with.
 * The verifier only runs against Windows 2012 R2 currently. This repo is adding more boxes as they become available.
 * The verifier times out on waiting for a command after 12 minutes.
 * Synced folders are different - the verifier syncs the .chocolatey folder to gather the package information files.
 * Specific VM settings are different (for performance):
    * No GUI (as previously mentioned) - `v.gui = false`
    * 6GB RAM - `v.customize ["modifyvm", :id, "--memory", "6144"]`
    * 4 CPUs - `v.customize ["modifyvm", :id, "--cpus", "4"]`
    * Clipboard disabled - `v.customize ["modifyvm", :id, "--clipboard", "disabled"]`
    * Drag and Drop disabled - `v.customize ["modifyvm", :id, "--draganddrop", "disabled"]`

## Troubleshooting

### An authorization error occurred while connecting to WinRM.

Install latest VBox Guest Additions

### A Vagrant environment or target machine is required to run this command

Run `vagrant init` to create a new Vagrant environment. Or, get an ID of a target machine from `vagrant global-status` to run this command on. A final option is to change to a directory with a Vagrantfile and to try again." - please ensure you are on the correct working directory (where this ReadMe and `Vagrantfile` is) of this repo and try again.
