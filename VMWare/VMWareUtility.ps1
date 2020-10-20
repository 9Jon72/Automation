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
    $interfaces[$InterfaceIndex] | Set-NetworkAdapter -networkName $network -confirm:$false
}

function getIP {
    
}


$c=funconnect($Global:configFile.vcenter_server)
#tests connectivity to continue.
if($c){
    #this will be where we can run the fucntions to create a virtual network. 
    #createSwitch -switchName "BLUE1-LAN" -esxihostname "super9.cyber.local"
    setNetwork -vmName "fw-blue1" -InterfaceIndex 1 -Network "BLUE1-LAN"
}else{
    write-host "Invalid connection"
}
<#
function funswitch(){
    
    $askswitch = read-host -Prompt "What would you like to call your switch"
    #error handling
    
    $global:switch = $askswitch
    return $global:switch
}
#captures where to put the virtual host
function funesxi(){
    $storeesxi = Get-VMHost
    showlist($storeesxi)
    $askesxi = read-host -Prompt "Please pick the number corresponding to you esxi server"
    #error handling
    if(funisnum($askesxi[0])){
        write-host $global:wrong
        $askesxi=$null
        funesxi
    }
    if([int]$askesxi -gt [int]$storeesxi.length){
        write-host $global:wrong
        $askesxi=$null
        funesxi
    }
    $global:esxi = Get-VMHost -Name $storeesxi[$askesxi-1]
    return $esxi
}
#Creates a virtual host
funswitch
funesxi
#$global:virtualS = New-VirtualSwitch -vmhost $global:esxi -name $global:switch


#New-VirtualPortGroup -VirtualSwitch $global:virtualS -name $global:switch#>