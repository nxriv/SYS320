# SYS-320
# Storyline: View all services, running or stopped.

# Function to display services based on user input
function Show-Services ([string]$Filter) {
    switch ($Filter) {
        'all' {
            Get-Service
        }
        'stopped' {
            Get-Service | Where-Object { $_.Status -eq 'Stopped' }
        }
        'running' {
            Get-Service | Where-Object { $_.Status -eq 'Running' }
        }
    }
}

# Main script
do {
    # Prompt for user input
    Write-Host "Please enter 'all', 'stopped', 'running', or 'quit':"
    $UserInput = Read-Host

    # Validate user input and display services
    if (@('all', 'stopped', 'running').Contains($UserInput)) {
        Show-Services -Filter $UserInput
    } elseif ($UserInput -eq 'quit') {
        Write-Host "Exiting the script..."
        break
    } else {
        Write-Host "Invalid input. Please try again."
    }
} while ($true)
