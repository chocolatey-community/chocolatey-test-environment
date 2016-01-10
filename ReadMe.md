# Package Verifier Vagrant

A vagrant setup similar to the package-verifier for manually testing packages.

## Requirements

You need a computer with:

* a 64-bit processor and OS
* Intel VT-x [enabled](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/) (usually not an issue if your computer is newer than 2011).
* Hyper-V may need to be disabled for Virtualbox to work properly if your computer is a Windows box.
* At least 10GB of free space.

## Setup

To get started, ensure you have the following installed:
 * Vagrant 1.8.1+
 * Virtualbox 4.3.28+ (5.x may have issues, so try to stay in 4.3.x series)
 * vagrant sahara plugin (`vagrant plugin install sahara`)

You can also install Vagrant/Virtualbox on Windows by running `choco install packages.config`

## Running Verification Manually

**NOTE**: The CDN for packages on https://chocolatey.org will only update every 30 minutes. This means if you just pushed an updated version, within 30 minutes from the last access time of the package it will be updated. This is why the validator and verifier wait for 31 minutes prior to testing a package.

### Preparing the Testing Environment

 * Ensure setup above is good on your machine.
 * Open a command line and navigate to the `vagrant` subdirectory of this repository.
 * Run `vagrant up` to prepare the machine for testing. Note that it will take quite awhile the first time you need to download the [box from Atlas](https://atlas.hashicorp.com/ferventcoder/boxes/win2012r2-x64-nocm). Once it has downloaded it will import the box and apply the scripts and configurations to the box as listed inside the Vagrantfile.
 * Now the box is ready for you to start testing against. Run `vagrant sandbox on`.

### Testing a Package

For testing a package, you have two avenues. For a locally built package, you can drop the package into the `vagrant/packages` folder - it is shared with the box as `C:\packages`, so you can run a command on the box or with the inline provisioner (recommended as it is a closer match to the verifier) using `--source c:\packages` as an argument for installation. If you are trying to reproduce/investigate a problem with a package already up on the website, you can use `--version number` with your install arguments and that will let you install a package that is not listed (in most cases not yet approved).

 * Uncomment the final string in the vagrant file and update it using one of the methods above, then run `vagrant provision`.
 * Watch the output and go to the box for further inspection if necessary.

### Make Changes and Retest

When you need to investigate making changes and rerunning the tests, remember that we took a snapshot of the vagrant machine (the virtual machine), so we can rollback to the earlier state each time and move forward with testing changes without the possibility of lingering artifacts. This is why we are using the sahara vagrant plugin, it allows us to take a snapshot and then revert the virtual machine back to the previous state.

When you are ready to reset to the state just before installing:

 * Run `vagrant sandbox rollback`.

### Tearing Down the Testing Environment
**NOTE**: At any time you can stop or remove the box with `vagrant suspend`, `vagrant halt` and/or `vagrant destroy`. For more information on vagrant commands, see the [Vagrant Docs](http://docs.vagrantup.com/v2/cli/index.html).

 * If you are finished with the vagrant box, you can remove your temporary copy with `vagrant destroy`.

### Differences Between This and Verifier Service
There are a couple of difference between the verifier service and this environment.

 * The verifier is run without the GUI - meaning it is run in a headless state. There is no box to interact with.
 * The verifier times out on waiting for a command after 12 minutes.
 * Synced folders are different - it syncs the .chocolatey folder to gather the package information files.
 * Specific VM settings are different (for performance):
    * No GUI (as previously mentioned) - `v.gui = false`
    * 6GB RAM - `v.customize ["modifyvm", :id, "--memory", "6144"]`
    * 4 CPUs - `v.customize ["modifyvm", :id, "--cpus", "4"]`
    * Clipboard disabled - `v.customize ["modifyvm", :id, "--clipboard", "disabled"]`
    * Drag and Drop disabled - `v.customize ["modifyvm", :id, "--draganddrop", "disabled"]`
