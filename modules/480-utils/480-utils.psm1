function 480Banner() 
{
    $banner = @"
    ____ ____        _________       ___________ 
   /    |    |      /         \     /           \
  /     |    |     /    --     \   /             \
 /      |    |_   |    |__|     | |      ___      |
|               | |             | |     |   |     |
|             __|  \           /  |     |___|     |
 \_______    |     /   ____    \  |               |
        |    |     |   |__|    |   \             /
        |____|     \___________/    \___________/
    ______ ____      ____      _____   _____          ________  
    |     |    \   _|    |_   |     | |     |        /        /
    |     |     \ /        \  |     | |     |       /  ______/
    |     |     /|__      __| |     | |     |____   \       \
    |          /    |    |    |     | |          |  _\------ \
     \________/     |____|    |_____| |__________| /__________\
"@

    Write-Host $banner
}

Function 480Connect([string] $server)
{
    $conn = $global:DefaultVIServer
    # Are we already connected?
    if ($conn){
        $msg = "Already Connected to: {0}" -f $conn

        Write-Host -ForegroundColor Green $msg
    } else 
    {
        $conn = Connect-VIServer -Server $server
        # If this fails, let Connect-VIServer handle the exception
    }
}

Function Get-480Config([string] $config_path)
{
    $config=$null
    if (Test-Path $config_path)
    {
        $config = Get-Content -Raw -Path $config_path | ConvertFrom-Json
        $msg = "Missing Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor "Green" $msg
    } else
    {
        Write-Host -ForegroundColor "Yellow" "No Configuration"
    }
    return $config
}

Function ErrorHandling($index, $maxIndex)
{
    if ($index -ge 1 -and $index -le $maxIndex) {
        return $true
    }
    else {
        Write-Host "Invalid index. Please enter a valid index between 1 and $maxIndex" -ForegroundColor "Yellow"
        return $false
    }
}

Function Select-VM([string] $folder)
{
    # This function will get a list of VMs from the vm_folder specified in 480.json
    # And gets an input from the user to select a VM to be used for a Linked Clone
    Write-Host "Select your VM:"
    $selected_vm = $null
    try
    {
        $vms = Get-VM -Location $folder
        $index = 1

        # Checks if the number of VMs is 0
        if ($vms.Count -eq 0) {
            Write-Host "No VMs found in the specified folder." -ForegroundColor "Red"
            return $null
        }

        foreach ($vm in $vms)
        {
            Write-Host "[$index] $($vm.Name)"
            $index += 1
        }

        do
        {
            $pick_index = Read-Host "Which index number [x] do you wish to pick?"

            # Handle Enter key without providing input
            if ($pick_index -eq "") {
                Write-Host "Please enter a valid index." -ForegroundColor "Yellow"
                continue
            }

            if (ErrorHandling -index $pick_index -maxIndex $vms.Count)
            {
                $selected_vm = $vms[$pick_index - 1]
                Write-Host "You picked $($selected_vm.Name)"
            }
        } while (-not $selected_vm)

        # Note: This is a full VM object that we can interact with
        return $selected_vm
    }
    catch
    {
        Write-Host "Invalid folder: $folder" -ForegroundColor "Red" 
    }
}

Function Select-DB()
{
    # This function will get all the datastores associated with your vcenter
    # And returns the chosen Datastore from user choice
    Write-Host "Select your Datastore:"
    $chosen_db = $null

    $datastores = Get-Datastore
    $index = 1

    # Checks if number of Datastores is 0
    if ($datastores.Count -eq 0) {
        Write-Host "No Datastores found." -ForegroundColor "Red"
        return $null
    }

    foreach ($ds in $datastores) {
        Write-Host [$index] $ds.Name
        $index += 1
    }

    do {
        $choice = Read-Host "Which index number [x] do you wish to pick?"
        if (ErrorHandling -index $choice -maxIndex $datastores.Count) {
            $chosen_db = $datastores[$choice - 1]
            Write-Host "You picked " $chosen_db.Name
        }
    } while ($chosen_db -eq $null)

    # Note this is a full on datastore object that we can interact with
    return $chosen_db
}
Function Select-Network([string] $vm)
{
    # This function gets the network from your vcenter
    # And returns the chosen network for the full clone
    Write-Host "Select your Network Adapter:"
    $chosen_net=$null
    
    $networks = Get-NetworkAdapter -VM $vm
    $index=1

    # Checks if number of Vms is 0
    if ($networks.Count -eq 0) {
        Write-Host "No VMs found in the specified folder." -ForegroundColor "Red"
        return $null
    }

    foreach($net in $networks)
    {
        Write-Host [$index] $net.Name
        $index+=1
    }

    do
    {
        $choice = Read-Host "Which index number [x] do you wish to pick?"
        if (ErrorHandling -index $choice -maxIndex $networks.Count){

            $chosen_net = $networks[$choice - 1]
            Write-Host "You picked " $chosen_net.Name
        }
    } while ($chosen_net -eq $null)
    {
            return $chosen_net
    }  
}

Function FullClone([string] $vm, $snap, $vmhost, $ds, $network)
{
    # This function creates a new linked clone vm temporarily
    # And returns a newly created vm from the linked clone
    $linkedName = "{0}.linked" -f $vm
    # Creates a temp. linked clone
    $linkedVM = New-VM -LinkedClone -Name $linkedName -VM $vm -ReferenceSnapshot $snap -VMHost $vmhost -Datastore $ds
    # Gets name of new Full Clone and creates it from linked clone
    $newvmname = Read-Host -prompt "Enter the name for your New VM"
    $newVM = New-VM -Name $newvmname -VM $linkedVM -VMHost $vmhost -Datastore $ds
    $newVM | Set-NetworkAdapter -NetworkName $network
    # Creates a new snapshot called "Base" and removes the temp.
    $newVM | New-Snapshot -Name "Base"
    $linkedVM | Remove-VM
    # Asks user if they would like to power on their New Clone VM
    $powerOp = Read-Host "Would you like to power on" $newVM.Name "(Y/N)?"
    if ($powerOp -match "^[yY]$")
    {
        Start-VM -VM $newVM
        Write-Host $newVM.Name "has powered on!"
    } else
    {
        break
    }
}