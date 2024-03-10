Import-Module "480-utils" -Force

$quit = $false

while ($quit -eq $false){

    480Banner 
    $config = Get-480Config -config_path "/home/sbarrick/SYS-480/modules/480-utils/480.json"

    480Connect -server $config.vcenter_server

    $vm = Select-VM -folder $config.vm_folder

    $powerOpt = Read-Host "Would you like to power on or off a VM (On/Off)"

    if ($powerOpt -match "^[oO]n$"){
        
        powerOn 
    } elseif ($powerOpt -match "^[oO]ff$"){

        powerOff
    }

    $db = Select-DB

    $snapshot = Get-Snapshot -VM $vm.Name | Select-Object -First 1

    $switch = New-Network

    $network = Select-Network -esxi $config.esxi_host

    $clone = FullClone -vm $vm.Name -snap $snapshot -vmhost $config.esxi_host -ds $db -network $network

    if ($clone -eq $null){
        $ans = Read-Host "Would you like to continue? (Y/N)"

        if ($ans -match "^[yY]$"){
            $quit = $false
        } else {
            $quit = $true
        }
    } else {
        $ans = Read-Host "Would you like to continue? (Y/N)"

        if ($ans -match "^[yY]$"){
            $quit = $false
        } else {
            $quit = $true
        }
    }
}
