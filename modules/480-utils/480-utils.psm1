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