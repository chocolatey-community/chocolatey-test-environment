# Adapted from http://stackoverflow.com/a/29571064/18475
Write-Host "IE Enhanced Security Configuration (ESC) has been disabled."
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey  = "HKCU:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
New-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force | Out-Null
New-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force | Out-Null

# http://techrena.net/disable-ie-set-up-first-run-welcome-screen/
Write-Host "IE first run welcome screen has been disabled."
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 1 -PropertyType "DWord" -Force | Out-Null

Write-Host 'Setting Windows Update service to Manual startup type.'
Set-Service -Name wuauserv -StartupType Manual

Write-Host 'Setting tray icons to always show'
sp HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer EnableAutoTray 0

Write-Host "Restarting Explorer"
Stop-Process -Name Explorer -Force
