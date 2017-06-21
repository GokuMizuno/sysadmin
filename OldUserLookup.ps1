#  Script name:    OldUserLookup.ps1
#  Created on:     06-09-2013
#  Author:         Richard Horsley
#  Purpose:        Searches Active Directory for inactive user accounts.

# Set this variable to find users that have not logged on to the domain for over this number of days.
# Set this value to 0 to find ALL users in AD.
$age = "90"

# Set the output file location for the CSV generated by this script.
$outputfile = "C:\Scripts\UserLookup.csv"

# Generates a date based on todays date minus the number of days you selected.
$agelimit = (get-date).adddays(-$age)

# Create a directory searcher object to begin searching for users in AD.
# This method is used rather than Get-ADUser to retain compatibility with Server 2003 / 2008.
$userslookup = New-Object DirectoryServices.DirectorySearcher([ADSI]��)
$userslookup.filter = �(&(objectClass=user)(objectCategory=person))�

# For each user found:
$userslookup.Findall().GetEnumerator() | ForEach-Object {

# Convert the user name to a string.
$name = [string]$_.Properties.name

# Convert the ticker style date gethered by the directory searcher for lastlogon in to a readable date.
$lastlogondate = [string]$_.Properties.lastlogontimestamp
$realtime = [DateTime]::FromFileTime($lastlogondate)

# If the last logon date is older than the age (in days) defined by $age:
    if ($agelimit -gt $realtime) {

    # Add the user to the $oldusers array.
    $oldusers += @{"$name" = "$realtime"}
    }
}

# Export the results in to a CSV for easy reading.
$oldusers.getEnumerator() | select name, value | export-csv $outputfile

# Done!
# Rich