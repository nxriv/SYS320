# Storyline: Login to a remote SSH server

# Get user input for server address, port, and credentials
Write-Host "Please enter the SSH server address:"
$serverAddress = Read-Host

Write-Host "Please enter the SSH server port (default is 22):"
$serverPort = Read-Host
$serverPort = ([string]::IsNullOrEmpty($serverPort)) ? 22 : $serverPort

# Get the credentials
$credential = Get-Credential -Message "Please enter your SSH credentials"

# Create an SSH session
$session = New-SSHSession -ComputerName $serverAddress -Port $serverPort -Credential $credential

# Check if the session is established
if ($session.Connected) {
    Write-Host "SSH session established! Commands can now be executed on the remote server."

    while ($true) {
        Write-Host "Enter a command to execute on the server (type 'exit' to end the session):"
        $command = Read-Host
        if ($command -eq "exit") {
            break
        }

        $result = Invoke-SSHCommand -SSHSession $session -Command $command
        Write-Host $result.Output -ForegroundColor Green
    }

    Write-Host "Enter the path of the local file you'd like to upload:"
    $localFile = Read-Host

    Write-Host "Enter the remote path where you'd like to upload the file:"
    $remotePath = Read-Host

    Set-SCPFile -ComputerName $serverAddress -Credential $credential -RemotePath $remotePath -LocalFile $localFile

    # Close the SSH session
    Remove-SSHSession -SSHSession $session
    Write-Host "SSH session closed."
} else {
    Write-Host "Failed to establish an SSH session. Please check the server address, port, and credentials, then try again."
}
