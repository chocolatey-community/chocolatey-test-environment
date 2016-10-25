Everything in here is ignored.

- Drop your nupkg files here to test them all out
- Use environment variable $Env:PACKAGES to pass names and versions of community packages to install:
    $Env:PACKAGES = 'copyq dbeaver:2.7.1'; vagrant up --provision
