Import-Module Lync

$terminatedusers = Get-ADUser -Filter {Enabled -eq $true} -SearchBase "OU=Disabled Users,DC=domain,DC=com"

Get-CsAdUser -Identity $terminateduser.samaccountname | Where-Object {$_.Enabled} | Disable-CsUser