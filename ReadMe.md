# Chocolatey Testing Environment

A testing environment setup similar to the [package-verifier](https://docs.chocolatey.org/en-us/community-repository/moderation/package-verifier) for testing packages. Over time this will add more Windows platforms for testing.

When creating packages or testing other parts of Chocolatey, this environment provides a good base for an independent testing minus any dependencies you may already have installed. It also allows you to completely destroy an environment and then just tear it down without worry about messing up something on your own system.

When creating packages, please review https://github.com/chocolatey/choco/wiki/CreatePackages

## Table of Contents

- [Requirements](#requirements)
- [Setup](#setup)
- [Running Verification Manually](#running-verification-manually)
  - [Preparing the Testing Environment](#preparing-the-testing-environment)
  - [Testing a Package](#testing-a-package)
  - [Make Changes and Retest](#make-changes-and-retest)
  - [Tearing Down the Testing Environment](#tearing-down-the-testing-environment)
  - [Upgrading the Testing Environment](#upgrading-the-testing-environment)
  - [Using a Specific Vagrant Box Version](#using-a-specific-vagrant-box-version)
  - [Using Hyper-V instead of VirtualBox](#using-hyper-v-instead-of-virtualbox)
- [Differences Between This and Package Verifier Service](#differences-between-this-and-package-verifier-service)
- [Troubleshooting](#troubleshooting)

## Requirements

You need a computer with:

* a 64-bit processor and OS
* Intel VT-x [enabled](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/) (usually not an issue if your computer is newer than 2011). This is necessary because we are using 64bit VMs.
* Hyper-V may need to be disabled for Virtualbox to work properly if your computer is a Windows box. **NOTE:** This may actually not be required.
* At least 50GB of free space.

## Setup

To get started, ensure you have the following installed:

 * Vagrant 2.1+ - linked clones is the huge reason here. You can technically use any version of Vagrant 1.3.5+. But you will get the best performance with 2.1.x.
 * VirtualBox 5.2+

**NOTE:** If you decide to run with version 1.8.1 of Vagrant, you are going to need to set the `VAGRANT_SERVER_URL` environment variable as described in this [forum post](https://groups.google.com/forum/#!msg/vagrant-up/H8C68UTkosU/qz4YUmAgBAAJ), otherwise, you will get an HTTP 404 error when attempting to download the base vagrant box used here.

## Running Verification Manually

**NOTE**: The CDN for packages on https://chocolatey.org will only update every 30 minutes. This means if you just pushed an updated version, within 30 minutes from the last access time of the package it will be updated. This is why the validator and verifier wait for 31 minutes prior to testing a package.

### Preparing the Testing Environment

 1. Ensure setup above is good on your machine.
 1. Fork and Clone this repository
 1. Open a command line (`PowerShell.exe`/`cmd.exe` on Windows, `bash` everywhere else) and navigate to the root folder of the repository.  You know you are in the right place when you do a `dir` or `ls` and `Vagrantfile` is in your path.
     * No idea if bash on Windows (through Git/CygWin) is supported. If you run into issues, it is better to just use `PowerShell.exe` or `cmd.exe`. Please do not file issues stating it doesn't work.
 1. Run `vagrant up` to prepare the machine for testing.
     * **Note** due to the way that vagrant works, the first time that you run this command, the vagrant box named __chocolatey/test-environment__ needs to be downloaded from the [HCP Vagrant Registry](https://portal.cloud.hashicorp.com/vagrant/discover/chocolatey/test-environment).  This will take quite a while, and should only be attempted on a reasonably fast connection, that doesn't have any download limit restrictions. Once it has downloaded it will import the box and apply the scripts and configurations to the box as listed inside the `Vagrantfile`.  You can find the downloaded box in the `~/.vagrant.d` or `c:\users\username\.vagrant.d` folder.
 1. Now the box is ready for you to start testing against.
 1. Run the following command: `vagrant snapshot save good`.  This takes a snapshot of the VM using the built-in snapshot functionality. This means that after testing packages, the VM can be returned to this known "good" state.

### Testing a Package

For testing a package, you have two avenues. For a locally built package, you can drop the package into the `packages` folder in the root of the cloned repository - it is shared with the box as `C:\packages`, so you can run a command on the box or with the inline provisioner (recommended as it is a closer match to the verifier) using `--source c:\packages` as an argument for installation. If you are trying to reproduce/investigate a problem with a package already up on the website, you can use `--version number` with your install arguments and that will let you install a package that is not listed (in most cases not yet approved).

 1. Search the Vagrantfile for `# THIS IS WHAT YOU CHANGE`.  Uncomment and edit the line which best meets the current situation that you are testing.
 1. Run `vagrant provision`.
 1. Watch the output and go to the box for further inspection if necessary.
 1. If you need to change output or try something else, read the next section.

### Make Changes and Retest

When you need to investigate making changes and rerunning the tests, remember that we took a snapshot of the vagrant machine (the virtual machine), so we can rollback to the earlier state each time and move forward with testing changes without the possibility of lingering artifacts. This is why we are using the `vagrant snapshot` command, it allows us to take a snapshot and then revert the virtual machine back to the previous state.

When you are ready to reset to the state just before installing:

 1. Run `vagrant snapshot restore good --no-provision`
 1. Follow the steps in testing a package (previous section).

### Tearing Down the Testing Environment

**NOTE**: At any time you can:

* stop the box with `vagrant suspend`, `vagrant halt`
* delete the box with `vagrant destroy`

### Upgrading the Testing Environment

When bringing up your testing environment Vagrant may report that the box being used is out of date. You can also manually check to see if a newer box is available using the `vagrant box outdated` command.

To upgrade the vagrant box used by your testing environment:

 1. Download the new box with `vagrant box update`
     * **Note** as with the initial setup, this is a large download so please be patient
 1. Delete the existing testing environment with `vagrant destroy`
 1. Restore the `Vagrantfile` back to it's default, i.e. there should not be any uncommented lines from testing packages
     * **Note** you may wish to take this opportunity to fetch the latest changes from this repository
 1. Run `vagrant up` to prepare the testing environment with the new box
 1. Snapshot the updated testing environment with `vagrant snapshot save good`

### Using a Specific Vagrant Box Version

If you don't want to use the latest available Vagrant box, you can select a specific box version or otherwise constrain the valid versions used in your testing environment. To do so, edit the `Vagrantfile` and uncomment the `config.vm.box_version` line.

By default this will set the desired box version to "2.0.0" which is the last Windows Server 2012 R2 version available.

You can adjust this setting to meet your needs, for more information on the options available see the documentation on [Version Constraints](https://developer.hashicorp.com/vagrant/docs/boxes/versioning#version-constraints).

For more information on vagrant commands, see the [Vagrant Docs](http://docs.vagrantup.com/v2/cli/index.html)

## Using Hyper-V instead of VirtualBox

> [!CAUTION]
> It is recommended to favor running the Chocolatey Test Environment under VirtualBox.

> Hyper-V support is intended to lower the barrier to entry for those using Windows features which force the usage of Hyper-V,
> such as the Windows Subsystem for Linux (WSL 2), Windows Sandbox, Device Guard, and Credential Guard.
>
> Please be sure that you're aware of the [limitations](https://developer.hashicorp.com/vagrant/docs/providers/hyperv/limitations) of using the Vagrant Hyper-V provider.

> [!NOTE]
> The Hyper-V role requires Windows 10 or 11 Enterprise, Pro, or Education.
> It **cannot** be installed on Home editions of Windows.

 1. Ensure setup above is complete, ignoring the need for VirtualBox.
 1. Enable the Hyper-V feature:
     * Open a PowerShell console as Administrator.
     * Run `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All`.
     * Restart Windows.
 1. Follow the general instructions to [prepare the testing environment](#preparing-the-testing-environment), swapping the default `vagrant up` command with `vagrant up --provider=hyperv`.
     * The Hyper-V image, downloaded the first time you run command is very large (> 5GB) and specific to Hyper-V.

## Differences Between This and Package Verifier Service

There are a couple of difference between the [Package Verifier service](https://docs.chocolatey.org/en-us/community-repository/moderation/package-verifier) and this environment.


 * The verifier is run without the GUI - meaning it is run in a headless state. There is no box to interact with.
 * Package Verifier only runs against Windows Server 2019, currently.

 * Package Verifier times out on waiting for a command after 12 minutes.

 * Synced folders are different - Package Verifier syncs the `.chocolatey` folder to gather the package information files.

 * Specific VM settings are different (for performance):
    * No GUI (as previously mentioned) - `v.gui = false`
    * 6GB RAM - `v.customize ["modifyvm", :id, "--memory", "6144"]`
    * 4 CPUs - `v.customize ["modifyvm", :id, "--cpus", "4"]`
    * Clipboard disabled - `v.customize ["modifyvm", :id, "--clipboard", "disabled"]`
    * Drag and Drop disabled - `v.customize ["modifyvm", :id, "--draganddrop", "disabled"]`

## Troubleshooting

### Error: "A Vagrant environment or target machine is required to run this command."

Run `vagrant init` to create a new Vagrant environment. Or, get an ID of a target machine from `vagrant global-status` to run this command on. A final option is to change to a directory with a Vagrantfile and to try again." - please ensure you are on the correct working directory (where this ReadMe and `Vagrantfile` is) of this repo and try again.

### Error: "WinRM: Warning: Authentication failure. Retrying..." and when the machine boots the C:\packages" folder is not present (and other configuration has not occurred).

Edit Vagrantfile and find the `# Port forward WinRM / RDP` section. uncomment `#, host_ip: "127.0.0.1"` (remove the `#`). Run `vagrant up` again.

  config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true , host_ip: "127.0.0.1"
