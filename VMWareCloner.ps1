#Global functions
#showlist function gives a numbered list of an array.
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

#Resets all varibles to null to avoid conflicts. 
$global:basevm=$null
$global:snap=$null
$global:vmhost=$null
$global:dstore=$null
$global:folder=$null
$global:askBaseFolder=$null
$global:wrong="Cmon you know thats not a valid input, use your eyes"
#Engine functions
#Function for connecting to the vecnter instnace.
function funconnect(){
    $askVcenter = read-host -prompt "What is the vcenter hostname or IP address"
    Connect-VIServer -Server $askVcenter
}

#this function selects the base folder
function funbasefolder(){
    $folder = get-folder | select-object name
    $global:askBaseFolder = read-host -prompt "Where is the folder of VM you want to clone?"
    #error handling for inputting a base folder.
    if(get-folder -name $global:askBaseFolder -erroraction SilentlyContinue){}else{
        write-host "That is not a folder try again"
        funbasefolder
    }
}

#Function that colllects and displays a vm folder that will than be used to select a 
#vm to clone. 
function funbase(){
    $storebase = get-vm -location $global:askBaseFolder
    showlist($storebase)
    $askbase = read-host -Prompt "Pick a base host to copy (type the number)"
    #error handling
    if(funisnum($askbase[0])){
        write-host $global:wrong
        $askbase=$null
        funbase 
    }
    if([int]$askbase -gt [int]$storebase.length){
        write-host $global:wrong
        $askbase=$null
        funbase
    }
    $global:basevm = Get-VM -Name $storebase[$askbase-1]
}

#Function that captures the snapshot going to be used.
function funsnap(){
    $storesnap = get-snapshot -VM $global:basevm
    showlist($storesnap)
    $asksnap = read-host -Prompt "Pick a snaphot to use"
    if(funisnum($asksnap[0])){
        write-host $global:wrong
        $asksnap=$null
        funsnap 
    }
    if([int]$asksnap -gt [int]$storesnap.length){
        write-host $global:wrong
        $asksnap=$null
        funsnap
    }
    $global:snap = get-snapshot -VM $global:basevm -Name $storesnap[$asksnap-1]
}

#Function to assign the vmware host that will be used. 
function funhost(){
    $storehost = get-vmhost
    showlist($storehost)
    $askhost = read-host "Pick a host for the vm to sit on"
    #error handling
    if(funisnum($askhost[0])){
        write-host $global:wrong
        $askhost=$null
        funhost
    }
    if([int]$askhost -gt [int]$storehost.length){
        write-host $global:wrong
        $askhost=$null
        funhost
    }
    
    $global:vmhost = get-vmhost -Name $storehost[$askhost-1]
    
}

#Function to assign th datastore for the vm
function fundstore(){
    $storedstore = get-datastore -refresh
    showlist($storedstore)
    $askdstore = read-host -Prompt "Input the number for the datastore you want to use"
    #error handling
    if(funisnum($askdstore[0])){
        write-host $global:wrong
        $askdstore=$null
        fundstore
    }
    if([int]$askdstore -gt [int]$storedstore.length){
        write-host $global:wrong
        $askdstore=$null
        fundstore
    }
    
    $global:dstore = get-datastore -name $storedstore[$askdstore-1]
}

#function to assign the folder.
function funfolder(){
    $storefolder = get-folder -Type VM
    showlist($storefolder)
    $askfolder = read-host -Prompt "Input the folders number you want to use: "
    #error handling
    if(funisnum($askfolder[0])){
        write-host $global:wrong
        $askfolder=$null
        funfolder 
    }
    if([int]$askfolder -gt [int]$storefolder.length){
        write-host $global:wrong
        $askfolder=$null
        funfolder
    }
    $global:folder = get-folder -name $storefolder[$askfolder-1]
}

#this function runs all the function to make a linked vm
function funlink(){
    funbasefolder
    funbase
    funsnap
    funhost
    fundstore
    funfolder
    $newvm = New-VM -Name "$name.linked" -VM $global:basevm -linkedclone -ReferenceSnapshot `
    $global:snap -VMHost $global:vmhost -Datastore $global:dstore -Location $global:folder
}
#This function runs through the commands to 
function funfull(){
    funbasefolder
    funbase
    funhost
    fundstore
    funfolder
    $newvm = New-VM -Name $name -VM $global:basevm `
    -VMHost $global:vmhost -Datastore $global:dstore -Location $global:folder
}
#Creates the VM asking the user for a name and if they want a linked or Full clone. 
function funfinish(){
    $asklink = read-host -prompt "Would you like a linked [L] or Full [F] clone"
    $name = read-host -prompt "What would you like to name the host?: "
    if ($asklink -eq "L"){
        funlink
    }elseif($asklink -eq "F"){
        funfull
    }else{
        write-host "Not an option please try again"
        funfinish
    }
}

#all the functions running
funconnect
funfinish