function Export-CSVFiles {
    # Export running processes to a CSV file
    Get-Process | Select-Object ProcessName, Path, ID | Export-Csv -Path "C:\Users\Desu\Desktop\Processes.csv" -NoTypeInformation

    # Export running services to a CSV file
    Get-Service | Export-Csv -Path "C:\Users\Desu\Desktop\Services.csv" -NoTypeInformation

    Write-Host "CSV files for processes and services have been saved to the Desktop."
}

function Start-Calculator {
    # WINDOWS 10 DOES NOT RUN THE CALCULATOR AS A NORMAL PROCESS
    $calcApp = "Microsoft.WindowsCalculator"
    $appPackage = Get-AppxPackage -Name $calcApp
    if ($appPackage) {
        $appFamilyName = $appPackage.PackageFamilyName
        $appID = "App"
        $AUMID = "$appFamilyName!$appID"
        Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder\$AUMID"
        Write-Host "Windows Calculator started. Press any key to stop it."
    } else {
        Write-Host "Windows Calculator not found."
    }
}

function Stop-Calculator {
    $calcApp = "ApplicationFrameHost"
    # Since it is not a process, you must grab the Window named "Calculator" and stop it this way.
    $calcProcess = Get-Process $calcApp -ErrorAction SilentlyContinue | Where-Object MainWindowTitle -Match "Calculator"
    if ($calcProcess) {
        $calcProcess | Stop-Process -Force
        Write-Host "Windows Calculator stopped."
    } else {
        Write-Host "Windows Calculator is not running."
    }
}

function WaitForAnyKey {
    $key = $null
    while (-not $key) {
        $key = [System.Console]::ReadKey($true)
    }
}

function Show-Menu {
    Write-Host "1: Export CSV files for processes and services"
    Write-Host "2: Start and stop the Calculator"
    Write-Host "3: Exit"
}

function Get-UserChoice {
    $choice = Read-Host "Please enter the number of your choice"
    return $choice
}

$exit = $false
do {
    Show-Menu
    $choice = Get-UserChoice

    switch ($choice) {
        '1' {
            Export-CSVFiles
        }
        '2' {
            Start-Calculator
            WaitForAnyKey
            Stop-Calculator
        }
        '3' {
            $exit = $true
        }
        default {
            Write-Host "Invalid choice, please try again."
        }
    }
    if (-not $exit) {
        Write-Host "Press any key to return to the menu..."
        WaitForAnyKey
        Clear-Host
    }
} while (-not $exit)
