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

Get-ADUser -filter { Enabled -eq $True } –Properties pwdLastSet,passwordLastSet,passwordNeverExpires,cannotChangePassword | Select-Object name,passwordLastSet 
