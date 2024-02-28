Import-Module "480-utils" -Force
# Call the Banner Function
480Banner 
$config = Get-480Config -config_path "/home/sbarrick/modules/480-utils/480.json"
480Connect -server $config.vcenter_server
Write-Host "Selecting you VM"
Select-VM -folder "BASEVM"