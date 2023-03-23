# Storyline : Review Security Event Log

# Directory to save the files:
$myDir = "C:\Users\nicholas\Desktop\"

# List all available event logs from Windows
$eventLogs = Get-EventLog -list | Select-Object Log
$eventLogs.Log

# Specify keyword or a phrase to search for
$key = Read-host -Prompt "Enter the keyword or phrase to search for: "

# Create a prompt to allow the user to select the log to view.
$readlog = Read-host -Prompt "Please select a log to review from the list above" 

# Add wildcard characters for better keyword search
$key = "*$key*"

# Print results for the log
Get-EventLog -LogName $readlog -Newest 100 | Where-Object { $_.Message -ilike $key } | Export-Csv -NoTypeInformation -Path "$myDir\securityLogs.csv"
