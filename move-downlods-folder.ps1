# Get all user profiles
$userProfiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($profile in $userProfiles) {
    $userName = Split-Path $profile.LocalPath -Leaf
    echo "Processing user: $userName"

    # Define the new path for the Downloads folder
    $newDownloadsPath = Join-Path "D:" -ChildPath $userName | Join-Path -ChildPath "Downloads"

    # Create the new Downloads directory if it doesn't exist
    if (-not (Test-Path $newDownloadsPath)) {
        echo "Creating new Downloads directory: $newDownloadsPath"
        New-Item -Path $newDownloadsPath -ItemType Directory
    }

    $downloadsPath = Join-Path $profile.LocalPath -ChildPath "Downloads"

    # Check if the Downloads folder exists for the user
    if (Test-Path $downloadsPath) {
        # Move the content to the new location
        echo "Moving content from $downloadsPath to $newDownloadsPath"
        Move-Item -Path $downloadsPath\* -Destination $newDownloadsPath -Force
    }

    # Update the registry to point to the new location
    echo "Updating registry for user: $userName"
    $userRegistry = "HKU\" + $profile.SID
    $baseRegistry = "Registry::HKEY_USERS\" + $profile.SID
    $needsUnload = $false
    if (-not (Test-Path $baseRegistry)) {
        $userRegistry = "HKU\$userName"
        $baseRegistry = "Registry::HKEY_USERS\$userName"
        echo "Loading user registry: $userRegistry"
        & reg load $userRegistry "$env:systemdrive\users\$userName\ntuser.dat"
        $needsUnload = $true
    }
    $regPath = "$baseRegistry\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
    Set-ItemProperty -Path $regPath -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value $newDownloadsPath
    [gc]::Collect()
    if ($needsUnload) {
        echo "Unloading user registry: $userRegistry"
        & reg unload $userRegistry
    }
}
