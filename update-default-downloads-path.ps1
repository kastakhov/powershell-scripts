$regName = "HKU\Default"
$regPath = "Registry::HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$drive = "UPDATE_ME"
& reg load $regName "$env:systemdrive\users\default\ntuser.dat"
Set-ItemProperty -Path $regPath -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value "$drive:\%USERNAME%\Downloads"
& reg unload $regName
