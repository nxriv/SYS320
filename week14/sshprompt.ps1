# Define a function to check connection status
function CheckConnection($serverIP) {
    $connected = Test-NetConnection -ComputerName $serverIP -Port 22
    return $connected.TcpTestSucceeded
}

# Define the server IP
$serverIP = "192.168.4.22"

# Check connection status
if (CheckConnection $serverIP) {
    Write-Host -BackgroundColor Green -ForegroundColor White "Connected"
} else {
    Write-Host "Not connected. Please connect to the host via SSH:"
    Write-Host "ssh user@$serverIP"
    exit
}

# Create a while loop
while ($true) {
    # Create an array of allowed commands
    $allowedCommands = @('ps -ef', 'netstat -apn --inet', 'last -10', 'cat /etc/passwd', 'id', 'dpkg -l')

    # Create a prompt for the user
    $userCommand = Read-Host -Prompt 'Enter a command'

    # Check to see if the user typed exit and break
    if ($userCommand -eq "exit") {
        break
    }

    # Check to see if the command is in the array
    if ($allowedCommands -contains $userCommand) {
        # If so, run the command
        Invoke-Expression $userCommand
    } else {
        # Otherwise, print an error message
        Write-Host -BackgroundColor Red -ForegroundColor White "Invalid command"
        Start-Sleep -Seconds 2
    }
}
