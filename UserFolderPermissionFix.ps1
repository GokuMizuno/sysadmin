#  Script name:    UserFolderPermissionFix.ps1
#  Created on:     04-12-2013
#  Author:         Richard Horsley
#  Purpose:        Repairs ownership on profile or user home folders to which the administrator has no access.

# Define the output file for this script.
$outputfile = "C:\Scripts\UserFolderPermissionFix.txt"

# Define location of profile or home folders that needs to be repaired.
$FolderLocation = "\\server\Profiles\"

# Create some arrays to throw objects in to later.
$users = new-object 'System.Collections.Generic.List[string]'
$folders = new-object 'System.Collections.Generic.List[string]'

# Create a directory searcher to find user objects in Active Directory.
# This method is used rather than Get-ADUser to retain compatibility with Server 2003 / 2008.
$userslookup = New-Object DirectoryServices.DirectorySearcher([ADSI]“”)
$userslookup.filter = “(&(objectClass=user)(objectCategory=person))”
$userslookup.Findall().GetEnumerator() | ForEach-Object {

# Add the located username to the $users array we created earlier.
$users.Add($_.Properties.samaccountname)
}

# Gather a list of all subfolders in the target location.
$folderlookup = get-childitem $FolderLocation

# Empty (or create) the output file.
echo "Fixed permissions on the following folders:" > $outputfile
echo " " >> $outputfile

# For each located folder.
foreach ($folder in $folderlookup) {

# Clean off the .V2 is there is one to help the folder name match the username.
$associateduser = (Split-Path $folder -leaf).ToString().Replace(".V2", "")

# Check to make sure that there is a user in Active Directory to match the folder.
if ($users -contains $associateduser) {

# If there is a user for this folder, take ownership of it with the currently logged in user account (must be an admin).
takeown /f "$FolderLocation$folder" /a /r /d y

# Now we need to create a new Access Control List for the folder that includes the original user.
$Acl = Get-Acl "$FolderLocation$folder"

# Define an access rule that gives the user access to their own folder.
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("$associateduser","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)

# Set this new Access Control List to the folder.
Set-Acl "$FolderLocation$folder" $Acl

# Let the log file know what we have done.
echo "Taken ownership of $FolderLocation$folder and granted $associateduser access." >> $outputfile 
    }

# Otherwise, if there is no user, you can't grant anyone access to the folder, so it just leaves the folder under your owndership with no additional users on the ACL.
else { echo "No AD user for folder $FolderLocation$folder" >> $outputfile }
}

# Done!
# Rich