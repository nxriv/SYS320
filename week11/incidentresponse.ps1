# Storyline: Create files and zip those files up for different types of logs in windows for an incident response.

function Get-FileHashes {
    param ([string]$OutputDirectory)

    Get-ChildItem -Path $OutputDirectory -Filter *.csv | ForEach-Object {
        $hash = Get-FileHash -Path $_.FullName -Algorithm SHA1
        "$($hash.Hash)  $($_.Name)"
    }
}

function Save-Results {
    param ([string]$OutputDirectory)

    # Get running processes and their paths
    Write-Host "Creating processes file..."
    Get-Process | Select-Object ProcessName, Path | Export-Csv -Path "$OutputDirectory\processes.csv" -NoTypeInformation

    # Get registered services and their executable paths
    Write-Host "Creating services file..."
    Get-WmiObject -Query "SELECT * FROM Win32_Service" | Select-Object DisplayName, PathName | Export-Csv -Path "$OutputDirectory\services.csv" -NoTypeInformation

    # Get all TCP network sockets
    Write-Host "Creating tcp sockets file..."
    Get-NetTCPConnection | Export-Csv -Path "$OutputDirectory\tcpSockets.csv" -NoTypeInformation

    # Get all user account information
    Write-Host "Creating User Accounts file..."
    Get-WmiObject -Class Win32_UserAccount | Export-Csv -Path "$OutputDirectory\userAccounts.csv" -NoTypeInformation

    # Get NetworkAdapterConfiguration information
    Write-Host "Creating Network Adapter Configurations file..."
    Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Export-Csv -Path "$OutputDirectory\networkAdapterConfiguration.csv" -NoTypeInformation

    # Additional student artifacts
    # Get-EventLog: Retrieves event log information, which can be useful for tracking user activity and system events
    Write-Host "Creating system events file..."
    Get-EventLog -LogName System -Newest 100 | Export-Csv -Path "$OutputDirectory\systemEvents.csv" -NoTypeInformation

    # Get-LocalGroup: Retrieves local group information, which can be useful for determining user permissions and access
    Write-Host "Creating local groups file..."
    Get-LocalGroup | Export-Csv -Path "$OutputDirectory\localGroups.csv" -NoTypeInformation

    # Get-ScheduledTask: Retrieves scheduled tasks, which can be useful for finding potentially malicious tasks created by an attacker
    Write-Host "Creating scheduled tasks file..."
    Get-ScheduledTask | Export-Csv -Path "$OutputDirectory\scheduledTasks.csv" -NoTypeInformation

    # Get-Hotfix: Retrieves installed updates, which can help determine if a system is missing critical security patches
    Write-Host "Creating hotfixes/patches file..."
    Get-Hotfix | Export-Csv -Path "$OutputDirectory\hotfixes.csv" -NoTypeInformation
}

Write-Host "Please enter the directory where you'd like to save the files:"
$outputDirectory = Read-Host

# Create output directory if it does not exist
if (!(Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory
}

Save-Results -OutputDirectory $outputDirectory

$fileHashes = Get-FileHashes -OutputDirectory $outputDirectory
$fileHashes | Out-File -FilePath "$outputDirectory\checksums.txt"

# Compress the output directory
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$zipFileName = "results-$timestamp.zip"
Write-Host "Compressing the output directory..."
Compress-Archive -Path "$outputDirectory\*" -DestinationPath "$outputDirectory\$zipFileName"
Write-Host "Compressed zip file created at: $outputDirectory\$zipFileName"

# Create a checksum of the zip file and save it to a file
$zipHash = Get-FileHash -Path "$outputDirectory\$zipFileName" -Algorithm SHA1
"$($zipHash.Hash)  $zipFileName" | Out-File -FilePath "$outputDirectory\$zipFileName-checksum.txt"
Write-Host "Checksum file created at: $outputDirectory\$zipFileName-checksum.txt"
