#This program will run a one time script that will access an existing csv file or 
#download one online, parse through the file and get important security information 
#that the admin decides.  
 
#this will stop the funciton in order let the user look at information. 
function allDone{read-host -prompt "Press [Enter] when done."} 
 
#MAIN function that will do everything in this program see top comment for details.  
function security_options_menu {          
    #clear the screen and sleep     
    #clear     
    sleep 1     
    #asks the user if they should download the file or use a local one.     
    $csv_entry = read-Host -prompt "Would you like to download a csv file from online or use the local one 'cve-test.csv' [D]Download, [L]Local: " 
 
    #define not found     
    $not_found = ''     
    #if statements seperating the options in the csv_entry command.     
    if ($csv_entry -eq 'D'){ 
 
        # asks if thefile is donwloaded and will not dowload if it has not been         
        if(Test-Path "C:\Users\Jonathan A Hanyok\fa19-sys320-jonathanhanyok\final\csv_dir\allitems.csv"){             
        write-host "The file is already downloaded"             
        $csv_file = import-csv "C:\Users\Jonathan A Hanyok\fa19-sys320-jonathanhanyok\final\csv_dir\allitems.csv" -Header Name,Status,Description         
        } else {             
            # Doanload the remote csv and save it plus prepare it to be processesed.    
            Invoke-WebRequest "https://cve.mitre.org/data/downloads/allitems.csv" OutFile "C:\Users\Jonathan A Hanyok\fa19-sys320-jonathanhanyok\final\csv_dir\allitems.csv"             
            $csv_file = import-csv "C:\Users\Jonathan A Hanyok\fa19-sys320-jonathanhanyok\final\csv_dir\allitems.csv" -Header Name,Status,Description         } # end of if test path if statement 
 
    } elseif ($csv_entry -eq 'L'){         
        # Use the local csv and prepare it to be processesd         
        write-host "You can now search through the cvs file located at 'C:\Users\Jonathan A Hanyok\fa19-sys320-jonathan-hanyok\final\csv_dir\cve-test.csv'"         
        sleep 1         
        $csv_file = import-csv "C:\Users\Jonathan A Hanyok\fa19-sys320-jonathanhanyok\final\csv_dir\cve-test.csv" -header Name,Status,Description     
    } else {         
        write-host "Please select a propper options, try again..."         
        security_options_menu     
    }     
    #the email attachments array     
    $csv_attach = @()     
    # asks the user if they would like to search by name or description.     
    $user_input = Read-Host -Prompt "1. Search for a CVE Entry Name in the 'Name' field 
    2. Search within the 'Description' field 
    3. Exit" 
 
    # if statement to run if the user requests a name search.     
        if ($user_input -eq "1"){         
            # asks the user to put in a specific name and helps them along the way      
            $name = Read-Host -Prompt "Please input the CVE entry name specifically, keep in mind it starts with 'CVE-####-####'." 
 
            # for loop that runs through the cve file finding the name given by the user and returning cve file that exists.         
            foreach ($entry in $cve_file) {                      
                # checks each entry to see f the name matches. 
                if ($entry.Name -eq $name){                              
                    # Prints out the name the Status and Description of the CVE entry.       
                    Write-Host "CVE Entry" $name "has been found."                 
                    Write-Host "The Status of" $name "is" $entry.Status ","              
                    Write-Host "The Description is" $entry.Description 
 
                    #attaches the entry to the cve_attach varible to be emailed later    
                    $csv_attach += $entry                                 
                    # tells the program that there is a matching name.                  
                    $not_found = "false" 
 
                } else {                                  
                    # if/else statement asking if the data was found, will set variable not_found to true if the program did not find any matching entries.                 
                    if ($not_found -eq "false"){ 
 
                        # continues if there is an entry matching                     
                        continue 
 
                    } else {                                          
                        # sets not_found to true in order to tell the user that the data was not found.       
                        $not_found = "true" 
 
                    } # end of else in else statment             
                }# end of else statement         
            } # end of for loop for N          
        
        # Asking if the user inputed asking to search CVE Entries via Description.   
        } elseif ($user_input -eq "2") { 
 
            # asks the user to provide part of the description to search the CVE file for.         
            $description = Read-Host -Prompt "Please input part of the description, the program will than search the CVE file for the coresponding entry."              
            
            # for loop that will run through the descriptions of the CVE entries looking for any comparisons.         
            foreach ($entry in $cve_file) {                      
                # if statement asking if the desciption given matches ant in the CVE file.              
                if ($entry.Description -ilike "*$description*") {                              
                    
                    # prints out the name, status and description if the desciption given by the user is somewhere in the CVE file.                  
                    Write-Host "Your Discption matched the CVE file" $entry.Name     
                    Write-Host "The status of" $entry.Name "is" $entry.Status        
                    Write-Host "The full description is" $entry.description 
 
                    #attaches the entry to the cve_attach varible to be emailed later   
                    $csv_attach += $entry                   
                    
                    # set a not found varialb eot false if the program found the entry          
                    $not_found = "false" 
 
            } else {                                  
                # if/else statement asking if the data was found, will set variable not_found to true if the program did not find any matching entries.    
                if ($not_found -eq "false"){ 
 
                    # continues if there is an entry matching              
                    continue              
                    } else {                                          
                        # sets not_found to true in order to tell the user that the data was not found.      
                        $not_found = "true" 

                    } # end of else in else statment              
                } # end of else statement in D                      
            } # end of for loop for D              
                 
        # elseif that exits the script     
        } elseif ($user_input -eq "3"){ 
 
        # tells user goodbye and leaves         
        write-host "Goodbye have a nice day" 
 
        exit 
 
    } # elseif for exit bracked 
 
    #if statement asking the user to try again if nothing was found because of their entry.      
    if ($not_found -eq "true"){ 
 
            #writes telling host that entry was not found.          
            write-host "Sorry that entry was not found, please run the script again"    
            sleep 5         
            exit     
    } else {         
        # emails the entries that were succesfully added. THIS WILL NOT WORK BECAUSE WE DONT HAVE A SMTP SERVER.         
        $email = read-host -Prompt "Would you like to email your findings to test@test.com, it will send all the found cve files based on your entry. (y/n)"         
        if ($email -eq "y"){             
            $from = "jonathan.hanyok@mymail.champlain.edu"             
            $to = "test@test.com"             
            $body = Read-Host -prompt "What special message would you like to give them"          
            $body = $body + $cve_attach 
 
                   #sends the email             
                   Send-MailMessage -From $from -to $to -Subject "CVEEntry" -SmtpServer "192.168.1.32" -Body $body         
             } # end of email if statement  
 
        #asks the user if they want to save the file         
        $save? = read-host -prompt "Would you like to save the found cve entries or print them(S/P)?"         
        if($save? -eq 'S'){             
            write-host "The file fill be saved to 'C:\Users\Jonathan A Hanyok\fa19sys320-jonathan-hanyok\final\csv_dump\' plus your file name"             
            $loc = read-host -prompt "please select a file name: "             
            $loc = "C:\Users\Jonathan A Hanyok\fa19-sys320-jonathanhanyok\final\csv_dump\" + $loc             
            $csv_attach = Export-Csv -NoTypeInformation -Path $loc | out-host         
            } elseif ($save? -eq 'P'){             
                write-host "here are your cve entries:"             
                $csv_attach | out-host         
            }                  
                #Send the user back to the security menu and sleeps         
                write-host "Please come again, after looking at what you have found"    
                alldone         
                exit     
        }# end not found if statement 
 
     
 
}# end security options menu. 
security_options_menu  
 