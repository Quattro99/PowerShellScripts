<#
.SYNOPSIS
.DESCRIPTION
.INPUTS
.OUTPUTS
.NOTES
   ===========================================================================
	 Created on:   	
	 Created by:   	Michele Blum
	 Filename:     	Default_header.ps1
	===========================================================================
.COMPONENT
.ROLE
.FUNCTIONALITY
#>

Import-Module ActiveDirectory
Get-ADGroupMember "Domänen-Admins" |
get-aduser -Properties AccountNotDelegated |
Where-Object {
  -not $_.AccountNotDelegated -and
  $_.objectClass -eq "user"
} 
## | Set-ADUser -AccountNotDelegated $true