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

Function Select-VM([string] $folder)
{
    # This function will get a list of VMs from the vm_folder specified in 480.json
    # And gets an input from the user to select a VM to be used for a Linked Clone
    Write-Host "Select your VM:"
    $selected_vm=$null
    try
    {
        $vms = Get-VM -Location $folder
        $index = 1
        foreach($vm in $vms)
        {
            Write-Host [$index] $vm.Name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        # 480 TODO need to deal with an invalid index (consider making this check a function)
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.Name
        # Note this is a full on vm object that we can interact with
        return $selected_vm
    }
    catch
    {
        Write-Host "invalid folder: $folder" -ForegroundColor "Red" 
    }
}

Function Select-DB()
{
   # This function will get all the datastores associated with your vcenter
   # And returns the chosen Datastore from user choice
   Write-Host "Select your Datastore:"
   $chosen_db=$null
   try 
   {
        $datastores = Get-Datastore
        $index = 1
        foreach($ds in $datastores)
        {
            Write-Host [$index] $ds.Name
            $index+=1
        }
        $choice = Read-Host "Which index number [x] do you wish to pick?"
        $chosen_db = $datastores[$choice -1]
        Write-Host "You picked " $chosen_db.Name
        return $chosen_db
   }
   catch 
   {
    # Fix this/don't need this anymore
        Write-Host "Invalid datastore: $database" -ForegroundColor "Red"
   }
}
Function Select-Network($vm)
{
    # This function gets the network from your vcenter
    # And returns the chosen network for the full clone
    Write-Host "Select your Network Adapter:"
    $chosen_net=$null
    
    $networks = Get-NetworkAdapter -VM $vm
    $index=1
    foreach($net in $networks)
    {
        Write-Host [$index] $net.Name
        $index+=1
    }
    $choice = Read-Host "Which index number [x] do you wish to pick?"
    $chosen_net = $networks | Select-Object -Index ($choice - 1) | Select-Object -ExpandProperty Name
    Write-Host "You picked " $chosen_net.Name
    return $chosen_net  
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
}