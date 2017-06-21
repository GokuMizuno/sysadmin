#  Script name:    FileSearch.ps1
#  Created on:     31-07-2013
#  Author:         Richard Horsley
#  Purpose:        Searches drive for files with specific strings in the filename (usually the file extension) and creates a report.

# Define paths for the output .csv file and the path you wish to search recursively.
$outputfile = "C:\Scripts\Located-Files.csv"
$searchpath = "E:\"

# Do the search!
Get-ChildItem -Force $searchpath -include *.mp3,*.wma,*.wmv,*.aac,*.avi,*.mp4,*.3gp,*.mkv -Recurse | Where-Object { ($_.PSIsContainer -eq $false) } | Select-Object Name,Directory,Length | Export-Csv $outputfile

# Done!
# Rich