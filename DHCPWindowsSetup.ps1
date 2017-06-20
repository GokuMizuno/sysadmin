$DNSDomain="ctxlab.local"
$DNSServerIP="192.168.1.10"
$DHCPServerIP="192.168.1.10"
$StartRange="192.168.1.150"
$EndRange="192.168.1.200"
$Subnet="255.255.255.0"
$Router="192.168.1.1"
 
Install-WindowsFeature -Name 'DHCP' –IncludeManagementTools
cmd.exe /c "netsh dhcp add securitygroups"
Restart-service dhcpserver
Add-DhcpServerInDC -DnsName $Env:COMPUTERNAME
Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2
Add-DhcpServerV4Scope -Name "DHCP Scope" -StartRange $StartRange -EndRange $EndRange -SubnetMask $Subnet
Set-DhcpServerV4OptionValue -DnsDomain $DNSDomain -DnsServer $DNSServerIP -Router $Router 
Set-DhcpServerv4Scope -ScopeId $DHCPServerIP -LeaseDuration 1.00:00:00