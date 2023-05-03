<#
.Synopsis
   This script moves automatically all AVD hosts to the right OUs
.DESCRIPTION
   This script moves automatically all AVD hosts AD objects to the right organizational unit for the GPOs
.EXAMPLE
   This script can be used as a cronjob to automate the moving of AD objects
.OUTPUTS
   OU move
.NOTES
   ===========================================================================
	 Created on:   	03.05.2023
	 Created by:   	Michele Blum
	 Filename:     	AD_automated_OU_move.ps1
	===========================================================================
.COMPONENT
   AD Module
.ROLE
   Automation with PowerShell and Windows Server
.FUNCTIONALITY
   Moving automatically AD objects into another OU
#>

## Name -like HAS TO BE CHANGED
## Destination OU HAS TO BE CHANGED

# Get all AVD hosts and store them in a variable
$avdhosts = Get-ADObject -Filter 'Name -like "fclavd*"'

# Loop through all hosts in the variable and move them to the right OU
foreach ($avdhost in $avdhosts) {
Move-ADObject $avdhost -TargetPath "OU=AVD Hosts,DC=aadds,DC=fcl,DC=ch"
}
