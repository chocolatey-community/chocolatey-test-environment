$ErrorActionPreference = "Stop"
$env:PATH +=";$env:SystemDrive\ProgramData\chocolatey\bin"

[[Command]]

if ($LASTEXITCODE -ne 0) {
	exit 1
}
