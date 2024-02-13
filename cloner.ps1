#Connect
$vserver=Read-Host -prompt "Enter your vCenter Server (i.e vcenter.yourname.local)"
Connect-VIServer($vserver)
#Source VM
Get-VM
$vmname = Read-Host -prompt "Enter the name of the VM you wish to make a Linked Clone of"
$vm=Get-VM -Name $vmname
$snapshot = Get-Snapshot -VM $vm -Name "Base"
$hostsname = Read-Host -prompt "Enter the name of your VM Host Server"
$vmhost = Get-VMHost -Name $hostsname
$dsname = "Enter the name of the Datastore you want to use"
$ds=Get-DataStore -Name $dsname
$linkedName = "{0}.linked" -f $vm.name
#Create the tempory VM
$linkedvm = New-VM -LinkedClone -Name $linkedName -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
#Create the Full VM
$newvm = New-VM -Name "server.2019.base.v2" -VM $linkedvm -VMHost $vmhost -Datastore $ds
#A new Snap Shot
$newvm | New-Snapshot -Name "Base"
#Cleanup the temporary linked clone
$linkedvm | Remove-VM
