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
    write-host "Auto logging in"
    Connect-VIServer -Server $askVcenter -user $Global:configFile.username `
    -password $Global:configFile.password
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
        $interfaces[$InterfaceIndex] | Set-NetworkAdapter -networkName $network `
        -confirm:$false
    }else{
        $interfaces | Set-NetworkAdapter -networkName $network -confirm:$false
    }
}

function getIP([string] $vmName) {
    $a = get-vm -name $vmName
    foreach($vm in $a){
            $vmObject = get-vm -name $vm.name
            $vmObjectName = $vmObject.name
            write-host $vmObject.guest.IPAddress[0] "hostname=$vmObjectName"
    }
}

#function used to create a VM
function createvm{
    param(
        $cloneType, $sourceVM, $VMName
    )
    write-host "Make sure the config file specified at the top of Utility function right"
    $basevm = get-vm -name $sourceVM
    $snapshot = Get-Snapshot -VM $basevm -name $Global:configFile.snapshot
    $vmhost = get-vmhost -name $Global:configFile.esxi_server
    $dstore = get-Datastore -name $Global:configFile.preferred_datastore
    $folder = get-folder -name $Global:configFile.preferred_folder
    if($cloneType -eq "F"){
        $newvm = new-vm -name $VMName -vm $basevm -VMhost $vmhost -datastore $dstore -location `
        $folder
    }elseif($cloneType -eq "L"){
        $newvm = new-vm -name $VMName -vm $basevm -LinkedClone -ReferenceSnapshot $snapshot -VMhost $vmhost -datastore $dstore -location `
        $folder
    }else{
        write-host "please enter a correct linked type"
    }
    sleep 5
    setNetwork -vmName $VMName -Network $Global:configFile.preferred_network
    start-vm -vm $VMName
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
