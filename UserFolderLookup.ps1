#  Script name:    UserFolderLookup.ps1
#  Created on:     02-09-2013
#  Author:         Richard Horsley
#  Purpose:        Compares current AD users with user / profile folders on server.

# Define path to the output file for this script.
$outputfile = "C:\Scripts\UserFolderLookup\UserFolderLookup-Results.txt"

# Erase the contents of the output file.
echo $null > $outputfile

# Define folder locations to check against user accounts.
$userfolderlocations = "\\server\User Profiles\","\\server\User Home\","\\server\TS Profiles\"

# Create some empty arrays to collect data in to later.
$users = new-object 'System.Collections.Generic.List[string]'
$profilefolders = new-object 'System.Collections.Generic.List[string]'
$homefolders = new-object 'System.Collections.Generic.List[string]'
$tsprofilefolders = new-object 'System.Collections.Generic.List[string]'

# Create a directory searcher to perform a user lookup from AD.
# This method is used rather than Get-ADUser to make this script backwards compatible with Server 2003.
$userslookup = New-Object DirectoryServices.DirectorySearcher([ADSI]“”)
$userslookup.filter = “(&(objectClass=user)(objectCategory=person))”
$userslookup.Findall().GetEnumerator() | ForEach-Object {

# Add located users to the array created earlier.
$users.Add($_.Properties.samaccountname)
}

foreach ($location in $userfolderlocations) {
# Do a lookup in the profile / home folder locations to collect a list of subfolders and place thsoe in an array.
    $subfolderlookup = get-childitem $location

# First entry in the output file.
    echo "Folders in $location without corresponding AD accounts:" >> $outputfile

# For each subfolder in the location:
    foreach ($subfolder in $subfolderlookup) {

# Firstly, remove the .V2 from strings stored in the array to help match the folder to the correct AD account.
    $folderclean = (Split-Path $subfolder -leaf).ToString().Replace(".V2", "")

# Compare the list of users gathered from AD earlier with the list of subfolders and write a line to the
# output file if there is no corresponding user.
    if ($users -notcontains $folderclean) {
    echo $subfolder.Name >> $outputfile
       }
    }
}

# Done!
# Rich