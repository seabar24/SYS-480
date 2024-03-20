Function Get-IP() {
    # This is a function that will print a list of all VMs
    # And return the Name, MAC Address, and IP Address of a chosen VM

    $VM = Read-Host "Enter name for vm"
    $config = Get-480Config -config_path "/home/sbarrick/SYS-480/modules/480-utils/480.json"
    480Connect -server $config.vcenter_server

    $vms = Get-VM -Name $VM

    foreach($vm in $vms){
        $mac=Get-NetworkAdapter -VM $vm | Select-Object -ExpandProperty MacAddress
        $ipaddr=$vm.Guest.IPAddress
        $info="Name: $($VM)`nMAC Address: $($mac)`nIP Address: $($ipaddr)"
        Write-Host $info
    }
}
Get-IP