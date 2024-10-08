Get-ADUser -filter { Enabled -eq $True } –Properties pwdLastSet,passwordLastSet,passwordNeverExpires,cannotChangePassword | Select-Object name,passwordLastSet 
