# Variables for Domain, Zone, and Admin names
$name = Read-Host "Enter the name for Domain and Zone"
$admin = Read-Host "Enter the name for the Admin User"
# AD Install
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "$name.local"
# Wait for reboot, SSH back in as deployer, then make accounts (might want to switch to new account after creation)
$password = Read-Host "Please enter a password for the $name user" -AsSecureString
New-ADUser -Name $admin -AccountPassword $password -Passwordneverexpires $true -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members $admin
Add-ADGroupMember -Identity "Enterprise Admins" -Members $admin
# Setup DNS and make records (A/PTR)
Install-WindowsFeature DNS -IncludeManagementTools
Add-DnsServerPrimaryZone -NetworkID 10.0.17.0/24 -ZoneFile “17.0.10.in-addr.arpa.dns”
Add-DnsServerResourceRecordA -CreatePtr -Name "vcenter" -ZoneName "$name.local -AllowUpdateAny -IPv4Address "10.0.17.3"
Add-DnsServerResourceRecordA -CreatePtr -Name "480-fw" -ZoneName "$name.local" -AllowUpdateAny -IPv4Address "10.0.17.2"
Add-DnsServerResourceRecordA -CreatePtr -Name "xubuntu-wan" -ZoneName "$name.local" -AllowUpdateAny -IPv4Address "10.0.17.100"
Add-DnsServerResourceRecordPtr -Name "4" -ZoneName “17.0.10.in-addr.arpa” -AllowUpdateAny -AgeRecord -PtrDomainName "dc1.$name.local."
# Setup DHCP
Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-Service dhcpserver
Add-DHCPServerv4Scope -Name “$name-scope” -StartRange 10.0.17.101 -EndRange 10.0.17.150 -SubnetMask 255.255.255.0 -State Active
# In theory, lease-time flag could be added to the above command, but I did not set it first time. To ensure future running, just added below
Set-DHCPServerv4Scope -ScopeID 10.0.17.0 -Name “$name-scope” -State Active -LeaseDuration 1.00:00:00
Set-DHCPServerv4OptionValue -ScopeID 10.0.17.0 -DnsDomain dc1.$name.local -DnsServer 10.0.17.4 -Router 10.0.17.2
# Following must be run as the new adm user
Add-DhcpServerInDC -DnsName "dc1.$name.local" -IPAddress 10.0.17.4
Restart-service dhcpserver
