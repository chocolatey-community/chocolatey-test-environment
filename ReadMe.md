# Package Verifier Vagrant 

A vagrant setup similar to the package-verifier for manually testing packages.


## Setup

To get started, ensure you have the following installed:
 * Vagrant 1.8.1+
 * Virtualbox 4.3.28+
 * vagrant-shara plugin
 
You can also install those two on Windows by running `choco install packages.config`

## Running the tests

 * Run `vagrant up` to prepare the machine for testing. Note that it will take quite awhile the first time you need to donwload the box from Atlas. Once it has downloaded it will import the box and apply the scripts and configurations to the box as listed inside the Vagrantfile.
 
 * Now the box is ready for you to start testing against. Run `vagrant sandbox on`.
 
 * You can uncomment the final string in the vagrant file and update it, then run `vagrant provision`. Otherwise you could interact with the box itself.
 
 * When you are ready to reset to the state just before installing, run `vagrant sandbox rollback`.
 * If you are finished with the vagrant box, you can remove your temporary copy with `vagrant destroy`.
