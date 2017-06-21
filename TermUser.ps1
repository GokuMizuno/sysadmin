    #Import Active Directory Module
Import-Module ActiveDirectory 


#Variables for Script
$_Name=Read-Host "Input sAMAccountname you wish to disable"
$_Date=Get-Date -Format "MM/dd/yyyy"
$_Creds=Get-Credential

#Disable the Account by Input in $_Name Variable
Disable-ADAccount -Identity $_Name -Credential $_Creds
write-host "Disabling $_Name" -ForegroundColor Green

#Pulls the Name by Input and Moves the Account to Disabled Users
GEt-AdUser $_Name | Move-ADObject -TargetPath "OU=wherever,OU=your,OU=disabled,OU=user,DC=ou,DC=is" -Credential $_Creds
write-host "Moving $_Name to Disabled Users" -ForegroundColor Green

#Sets the Description to Date the Script was ran and scrubs Office and Department to clear up Dynamic Distribution Lists
Set-ADUser $_Name -Description "Disabled on $_Date" -Office $null -Department $null -Credential $_Creds
write-host "Changing Description to Disabled on $_Date" -ForegroundColor Green

#Removes All Group Membership except for Domain Users from User
$group = get-adgroup "Domain Users"
$groupSid = $group.sid
$groupSid
[int]$GroupID = $groupSid.Value.Substring($groupSid.Value.LastIndexOf("-")+1)
Get-ADUser $_Name | Set-ADObject -Replace @{primaryGroupID="$GroupID"} -Credential $_Creds
Remove-ADPrincipalGroupMembership -Identity $_Name -MemberOf $(Get-ADPrincipalGroupMembership -Identity $_Name -Credential $_Creds| Where-Object {$_.Name -ne "Domain Users"}) -Confirm:$false 
Write-Host "Removing All Group Membership for $_Name" -ForegroundColor Green

#Creates a variable that configures a remote session to our Exchange Servers to allow Exchange commands through powershell 
$s=New-PSSession -ConfigurationName microsoft.exchange -ConnectionUri http://yourexchangeserver.yourdomain.local/powershell -Credential $_Creds -AllowRedirection 
Write-Host "Creating New Exchange Session" -ForegroundColor Green

#Imports the configured remote session
Import-PSSession $s -DisableNameChecking
Write-Host "Importing New Exchange Session" -ForegroundColor Green

#Hides User from GAL
Set-Mailbox -Identity $_Name -HiddenFromAddressListsEnabled $false
Set-Mailbox -Identity $_Name -HiddenFromAddressListsEnabled $true
Write-Host "Hiding $_Name from the GAL" -ForegroundColor Green

#Disables ActiveSync for the mailbox
Set-CASMailbox -Identity $_Name -ActiveSyncEnabled $false 
write-host "ActiveSync has been Disabled for $_Name" -ForegroundColor Green

#Removes Calendar Meeting Items in Exchange
Search-Mailbox –identity $_Name –SearchQuery kind:meetings –DeleteContent
Write-Host "Removing Calendar Items for $_Name" -ForegroundColor Green

#AssignManagertheMailbox
$_manager=(get-aduser (get-aduser $_Name -Properties manager).manager).samaccountName
Add-MailboxPermission -Identity $_Name -User $_Manager -AccessRights FullAccess -InheritanceType All 
Write-Host "Assigning mailbox for $_Name to $_Manager" -ForegroundColor Green

#closes the remote session
Remove-PSSession $s  
Write-Host "Closing Exchange Session" -ForegroundColor Green


#Hard Stop for Script to keep window open
Read-Host "Press any key to close!" 