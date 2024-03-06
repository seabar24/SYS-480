Import-Module "480-utils" -Force
# Call the Banner Function
480Banner 
$config = Get-480Config -config_path "/home/sbarrick/SYS-480/modules/480-utils/480.json"

480Connect -server $config.vcenter_server

$vm = Select-VM -folder $config.vm_folder

$db = Select-DB

$snapshot = Get-Snapshot -VM $vm.Name | Select-Object -First 1

$network = Select-Network -esxi $config.esxi_host

FullClone -vm $vm.Name -snap $snapshot -vmhost $config.esxi_host -ds $db -network $network

New-Network

