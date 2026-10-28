# Chocolatey Testing Environment

> [!IMPORTANT]
> **The `chocolatey/test-environment` Vagrant box is moving.** HashiCorp is shutting down the [HCP Vagrant Registry](https://developer.hashicorp.com/hcp/docs/vagrant/hcp-vagrant-eol), which is where this environment used to download the box from. The existing box can still be downloaded until December 31, 2026, but no new versions will be published there.
>
> The Packer build for the box is now public in [chocolatey-test-environment-box](https://github.com/chocolatey-community/chocolatey-test-environment-box), so you can build the box yourself. See [Building the Box](#building-the-box).
>
> For quick package testing that doesn't need the full testing environment, see [Quick Testing With Windows Sandbox](#quick-testing-with-windows-sandbox).

A testing environment setup similar to the [package-verifier](https://docs.chocolatey.org/en-us/community-repository/moderation/package-verifier) for testing packages. Over time this will add more Windows platforms for testing.

When creating packages or testing other parts of Chocolatey, this environment provides a good base for an independent testing minus any dependencies you may already have installed. It also allows you to completely destroy an environment and then just tear it down without worry about messing up something on your own system.

When creating packages, please review https://github.com/chocolatey/choco/wiki/CreatePackages

## Table of Contents

- [Requirements](#requirements)
- [Setup](#setup)
  - [Building the Box](#building-the-box)
- [Running Verification Manually](#running-verification-manually)
  - [Preparing the Testing Environment](#preparing-the-testing-environment)
  - [Testing a Package](#testing-a-package)
  - [Make Changes and Retest](#make-changes-and-retest)
  - [Tearing Down the Testing Environment](#tearing-down-the-testing-environment)
  - [Upgrading the Testing Environment](#upgrading-the-testing-environment)
  - [Using a Specific Vagrant Box Version](#using-a-specific-vagrant-box-version)
  - [Using Hyper-V instead of VirtualBox](#using-hyper-v-instead-of-virtualbox)
- [Quick Testing With Windows Sandbox](#quick-testing-with-windows-sandbox)
- [Differences Between This and Package Verifier Service](#differences-between-this-and-package-verifier-service)
- [Troubleshooting](#troubleshooting)

## Requirements

You need a computer with:

* a 64-bit processor and OS
* Intel VT-x [enabled](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/) (usually not an issue if your computer is newer than 2011). This is necessary because we are using 64bit VMs.
* Hyper-V may need to be disabled for Virtualbox to work properly if your computer is a Windows box. **NOTE:** This may actually not be required.
* At least 50GB of free space, plus about 60GB more while you [build the box](#building-the-box).

## Setup

To get started, ensure you have the following installed:

 * Vagrant 2.4.9+ - the first version that supports VirtualBox 7.2.
 * VirtualBox 7.2 - the version the box is built and tested with.

### Building the Box

This environment uses a Vagrant box named `chocolatey/test-environment`. Microsoft's license terms for the Windows Server evaluation don't allow the box to be redistributed, so instead of downloading it, you build it yourself from [chocolatey-test-environment-box](https://github.com/chocolatey-community/chocolatey-test-environment-box). It's the same build the Package Verifier uses. You only need to do this once for each version of the box.

 1. Build the box by following the [Building](https://github.com/chocolatey-community/chocolatey-test-environment-box#building) instructions in chocolatey-test-environment-box. Build it for VirtualBox, or for Hyper-V if you're [using Hyper-V](#using-hyper-v-instead-of-virtualbox). A build takes 1.5–3 hours, and is tested on Windows hosts.
 1. If you previously downloaded the box from the HCP Vagrant Registry, remove it so that Vagrant doesn't keep using it:
    ```powershell
    vagrant box remove chocolatey/test-environment --all --provider virtualbox
    ```
 1. Add the box you built under the name this environment's `Vagrantfile` expects:
    ```powershell
    vagrant box add --name chocolatey/test-environment <path to chocolatey-test-environment-box>\output\chocolatey-test-environment_3.4.0_virtualbox.box --provider virtualbox
    ```

For Hyper-V, use `--provider hyperv` and the `_hyperv.box` file instead.

## Running Verification Manually

**NOTE**: The CDN for packages on https://chocolatey.org will only update every 30 minutes. This means if you just pushed an updated version, within 30 minutes from the last access time of the package it will be updated. This is why the validator and verifier wait for 31 minutes prior to testing a package.

### Preparing the Testing Environment

 1. Ensure setup above is good on your machine.
 1. Fork and Clone this repository
 1. Open a command line (`PowerShell.exe`/`cmd.exe` on Windows, `bash` everywhere else) and navigate to the root folder of the repository.  You know you are in the right place when you do a `dir` or `ls` and `Vagrantfile` is in your path.
     * No idea if bash on Windows (through Git/CygWin) is supported. If you run into issues, it is better to just use `PowerShell.exe` or `cmd.exe`. Please do not file issues stating it doesn't work.
 1. Run `vagrant up` to prepare the machine for testing.
     * **Note** you need to have [built and added the box](#building-the-box) first. The first time that you run this command, Vagrant imports the box and applies the scripts and configurations listed inside the `Vagrantfile`, which will take quite a while.
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

Boxes you add from a file don't have a version, so Vagrant can't tell you when a newer one is available, and `vagrant box outdated` and `vagrant box update` don't work for them. Watch [chocolatey-test-environment-box](https://github.com/chocolatey-community/chocolatey-test-environment-box) on GitHub for new versions.

To upgrade the vagrant box used by your testing environment:

 1. Build the new version of the box (see [Building the Box](#building-the-box)).
 1. Delete the existing testing environment with `vagrant destroy`
 1. Remove the old box with `vagrant box remove chocolatey/test-environment --provider virtualbox`, then add the new one as described in [Building the Box](#building-the-box).
 1. Restore the `Vagrantfile` back to it's default, i.e. there should not be any uncommented lines from testing packages
     * **Note** you may wish to take this opportunity to fetch the latest changes from this repository
 1. Run `vagrant up` to prepare the testing environment with the new box
 1. Snapshot the updated testing environment with `vagrant snapshot save good`

### Using a Specific Vagrant Box Version

Boxes you build and add yourself don't have a version, so `config.vm.box_version` doesn't apply to them. To test against a specific version of the box, check out that version's tag in chocolatey-test-environment-box (for example, `git checkout 3.4.0`) and build the box from it. Version 3.4.0 is the first that can be built from that repository.

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
     * You need a box built for Hyper-V. Build it with `-Provider hyperv`, and add it with `--provider hyperv` (see [Building the Box](#building-the-box)).

## Quick Testing With Windows Sandbox

For a quick check that a package installs and uninstalls, you don't need the full testing environment. [Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/) starts a clean, disposable copy of Windows in a few seconds, and everything in it is discarded when you close it.

It doesn't replace the full testing environment. The sandbox runs Windows 10 or 11, based on your computer's own copy of Windows, rather than Windows Server 2019 like the Package Verifier. It also doesn't have the box's preinstalled software or settings. Test in the full environment before you submit a package.

> [!NOTE]
> Windows Sandbox requires Windows 10 or 11 Pro, Enterprise, or Education, with virtualization enabled in the BIOS.
> It isn't available on Home editions of Windows.

 1. Enable Windows Sandbox (you only need to do this once):
     * Open a PowerShell console as Administrator.
     * Run `Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All`.
     * Restart Windows.
 1. To test a package you've built, copy its `.nupkg` file into the `packages` folder in the root of this repository.
 1. Open `sandbox\chocolatey-test-environment.wsb`, either by double-clicking it or by running this from the root of this repository:
    ```powershell
    .\sandbox\chocolatey-test-environment.wsb
    ```
    Windows Sandbox opens, and a PowerShell window in it installs Chocolatey CLI. The `packages` folder is available in the sandbox as `C:\packages`, read-only.
 1. In that PowerShell window, install the package:
    ```powershell
    choco install <package-id> --source="'C:\packages;https://community.chocolatey.org/api/v2/'" --verbose --debug
    ```
    To test a version that's already on the Chocolatey Community Repository instead, use `--version <version>` in place of the `--source` option.
 1. Check that the software works, then uninstall the package:
    ```powershell
    choco uninstall <package-id> --verbose --debug
    ```
 1. Close Windows Sandbox. Only one sandbox can run at a time, so to test again, close it and open `chocolatey-test-environment.wsb` again for a fresh one.

## Differences Between This and Package Verifier Service

There are a couple of difference between the [Package Verifier service](https://docs.chocolatey.org/en-us/community-repository/moderation/package-verifier) and this environment.


 * The verifier is run without the GUI - meaning it is run in a headless state. There is no box to interact with.
 * Package Verifier only runs against Windows Server 2019, currently.

 * Package Verifier times out on waiting for a command after 12 minutes.

 * Synced folders are different - Package Verifier syncs the `.chocolatey` and `logs` folders to gather the package information files and Chocolatey CLI logs.

 * Package Verifier connects to the VM over SSH rather than WinRM.

 * Specific VM settings are different (for performance):
    * No GUI (as previously mentioned) - `v.gui = false`
    * 8GB RAM - `v.customize ["modifyvm", :id, "--memory", "8192"]`
    * 6 CPUs - `v.customize ["modifyvm", :id, "--cpus", "6"]`
    * Clipboard disabled - `v.customize ["modifyvm", :id, "--clipboard-mode", "disabled"]`
    * Drag and Drop disabled - `v.customize ["modifyvm", :id, "--draganddrop", "disabled"]`

## Troubleshooting

### Error: "A Vagrant environment or target machine is required to run this command."

Run `vagrant init` to create a new Vagrant environment. Or, get an ID of a target machine from `vagrant global-status` to run this command on. A final option is to change to a directory with a Vagrantfile and to try again." - please ensure you are on the correct working directory (where this ReadMe and `Vagrantfile` is) of this repo and try again.
