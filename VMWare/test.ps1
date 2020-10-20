# this script iwll create virtual networks. 
$global:wrong="Cmon you know thats not a valid input, use your eyes"

#Global function
function showlist($array){
    for($i=0; $i -lt $array.length; $i++){
        write-host ($i+1)": "$array[$i]
    }
}
#this function is used to test if an input is a number
function funisnum($in){
    $dad = [int][char]$in
    if(48 -lt $dad -and $dad-lt 58){
        return $false
    }else{return $true}}

#connection to the vcenter instance
function funconnect(){
    $askVcenter = read-host -prompt "What is the vcenter hostname or IP address"
    Connect-VIServer -Server $askVcenter
}
$c=funconnect
#tests connectivity to continue.
if($c){
    #this will be where we can run the fucntions to create a virtual network. 
}else{
    write-host "Invalid connection"
}

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
$global:virtualS = New-VirtualSwitch -vmhost $global:esxi -name $global:switch


New-VirtualPortGroup -VirtualSwitch $global:virtualS -name $global:switch