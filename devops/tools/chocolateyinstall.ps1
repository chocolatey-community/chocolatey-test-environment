vagrant plugin install sahara

$currentDirectory = Split-Path $MyInvocation.MyCommand.Path
$sourceDir = "chocolatey-test-environment"
$repoUrl = "https://github.com/chocolatey-community/chocolatey-test-environment.git"

# exit if directory already exists
if ($(test-path $sourceDir -pathtype container) -eq $true)
{
	write-error "Cannot clone repo, folder '$sourceDir' already exists."
	exit 1
}

# clone repo
git clone $repoUrl
 
cd $sourceDir
 
# bring up test VM
vagrant up

# create base line snapshot
vagrant sandbox on

# test run of package install
vagrant provision