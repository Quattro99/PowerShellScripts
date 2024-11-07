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

Get-ADComputer -Filter "OperatingSystem -like '*Windows 7*'" -Properties * | Sort LastLogon | Select Name, LastLogonDate,@{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}} 