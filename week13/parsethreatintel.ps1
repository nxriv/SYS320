# Storyline: Pull a list of IPs to block from a threat intel website and generate a file with IP blocklists for Linux and Windows.
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules', 'https://rules.emergingthreats.net/blockrules/compromised-ips.txt')
Clear-Host
Write-Host "Your operating system is: $env:OS`n1. Windows`n2. Linux"
$inp = Read-Host "Select an option (1 or 2) to generate a ruleset for that operating system"

# Download the rules list if it does not exist
foreach ($u in $drop_urls) {
    $file_name = ($u -split '/')[-1]
    if (-not (Test-Path $file_name)) {
        Invoke-WebRequest -Uri $u -OutFile $file_name
    }
}

$input_paths = @('.\compromised-ips.txt', '.\emerging-botcc.rules')
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
$temp_file = "ips-bad.tmp"

# Extract and save the unique IP addresses to a temporary file
(Get-Content -Path $input_paths | Select-String -Pattern $regex_drop).Matches.Value | Sort-Object -Unique | Out-File -FilePath $temp_file

# Generate the ruleset for the selected operating system
switch ($inp) {
    "1" {
        # Add Windows firewall syntax and save results to a file
        (Get-Content -Path $temp_file) | ForEach-Object {
            "netsh advfirewall firewall add rule name=`"BLOCK IP ADDRESS - $_`""
        } | Out-File -FilePath ".\msfirewall.netsh"
    }
    "2" {
        # Add IPTables syntax and save results to a file
        (Get-Content -Path $temp_file) | ForEach-Object {
            "iptables -A INPUT -s $_ -j DROP"
        } | Out-File -FilePath ".\iptables.bash"
    }
}

# Remove the temporary file
Remove-Item -Path $temp_file
