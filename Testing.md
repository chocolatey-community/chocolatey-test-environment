# Test examples


Installing latest version of a package from Chocolatey.org
~~~ruby
choco.exe install -fdvy nodejs.install
~~~

Retesting failing package from Chocolatey.org
~~~ruby
choco.exe install -fdvy github --version 3.0.11.0
~~~


After dropping badpackage.1.0.0.nupkg into the packages directory:
~~~ruby
choco.exe install -fdvy badpackage --source "'c:\\packages;http://chocolatey.org/api/v2/'"
~~~


For interactive testing of Chocolatey itself - please ignore if you are not doing so. Otherwise you need to share a folder with this box named code and have a temp folder in it where you drop the `code_drop\chocolatey\console\choco.exe` file to after building it from source.
~~~ruby
  config.vm.synced_folder "code", "ABSOLUTE PATH TO CODE FOLDER"

  config.vm.provision :shell, :powershell_elevated_interactive => true, :inline => <<SCRIPT
Copy-Item 'c:\\code\\temp\\choco.exe' 'c:\\ProgramData\\chocolatey\\choco.exe' -Force
choco.exe unpackself -f
SCRIPT
~~~
