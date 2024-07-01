Import-Module ActiveDirectory
Get-ADGroupMember "Domänen-Admins" |
get-aduser -Properties AccountNotDelegated |
Where-Object {
  -not $_.AccountNotDelegated -and
  $_.objectClass -eq "user"
} 
## | Set-ADUser -AccountNotDelegated $true