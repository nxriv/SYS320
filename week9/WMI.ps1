# Storyline: Grab network adapter information using WMI

$Net = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'"

foreach ($Adapter in $Net) {
    $IPAddress = $Adapter.IPAddress -join ', '
    $DefaultGateway = $Adapter.DefaultIPGateway -join ', '
    $DNSServers = $Adapter.DNSServerSearchOrder -join ', '
    $DHCPServer = $Adapter.DHCPServer

	# Output the information
	Write-Host "----------------------------------------"
	Write-Host "Adapter Description: $($Adapter.Description)"
	Write-Host "IP Address: $IPAddress"
	Write-Host "Default Gateway: $DefaultGateway"
	Write-Host "DNS Servers: $DNSServers"
	Write-Host "----------------------------------------"
	Write-Host "DHCP Server: $DHCPServer"
	Write-Host "----------------------------------------"
}
