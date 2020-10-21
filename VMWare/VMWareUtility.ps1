#Captures json file
$configFilePath = "cloner.json"
if(test-path $configFilePath){
    write-host "Using saved json file"
    $Global:configFile = (Get-content -Raw -Path $configFilePath | ConvertFrom-Json)
}else{
    write-host "Using interactive mode"
}
#Connects to server
function funconnect($vserver){
    if($vserver){
        $askVcenter = $vserver
    }else{
        $askVcenter = read-host -prompt "What is the vcenter hostname or IP address"
    }
    Connect-VIServer -Server $askVcenter
}

#creates a new virutla switch based on inputed data
function createSwitch{
    param(
        $switchName,
        $esxiHostName
    )
    $esxiHost = Get-VMHost -name $esxiHostName
    $vswitch = New-VirtualSwitch -vmhost $esxiHost -name $switchName
    New-VirtualPortGroup -VirtualSwitch $vswitch -name $switchName
}
#this function will change the network depending on the params set by the command. 
function setnetwork{
    param(
        $vmName, $InterfaceIndex, $Network
    )
    $vm = get-vm -name $vmName 
    $interfaces = $vm | get-NetworkAdapter
    if($InterfaceIndex){
        $interfaces[$InterfaceIndex] | Set-NetworkAdapter -networkName $network -confirm:$false
    }else{
        $interfaces | Set-NetworkAdapter -networkName $network -confirm:$false
    }
}

function getIP([string] $vmName) {
    $vm = get-vm -name $vmName
    write-host $vm.guest.IPAddress[0] hostname.$vm.Name
}


$c=funconnect($Global:configFile.vcenter_server)
#tests connectivity to continue.
if($c){
    #this will be where we can run the fucntions to create a virtual network. 
    #createSwitch -switchName "BLUE1-LAN" -esxihostname "super9.cyber.local"
    #setNetwork -vmName "fw-blue1" -InterfaceIndex 1 -Network "BLUE1-LAN"
    #Runs through all the powered on VMS and prints the ip address on net adapter 0
    <#
    foreach($vm in get-vm){
        if($vm.PowerState -eq "PoweredOn"){
            getIP($vm.name)
        }
    }#>
}else{
    write-host "Invalid connection"
}
