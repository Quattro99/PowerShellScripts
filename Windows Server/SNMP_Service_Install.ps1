<#
.Synopsis
   This script isntalls the SNMP Service with all its components
.DESCRIPTION
   This script installs the SNMP Service  with all its components and takes the conifguration automatically via GPOs.
.EXAMPLE
   This script can be used as a cronjob to automate the installation of the SNMP Service
.OUTPUTS
   PDF files
.NOTES
   ===========================================================================
	 Created on:   	20.01.2023
	 Created by:   	Michele Blum
	 Filename:     	SNMP_Service_Install.ps1
	===========================================================================
.COMPONENT
   ServerManager 
.ROLE
   Automation with PowerShell and Windows Server
.FUNCTIONALITY
   Automatic SNMP installation with all components
#>

##############################################
# Installing SNMP Services #
##############################################

Import-Module ServerManager
write-host ” ” -ForegroundColor Green
Write-host “Enabling ServerManager to check SNMP” -ForegroundColor Green
write-host “=====================================” -ForegroundColor Green

# Check if SNMP-Service is already installed
write-host ” ” -ForegroundColor Green
Write-host “Checking to see if SNMP service is installed…” -ForegroundColor Green
$SNMPCheck = Get-WindowsFeature -Name SNMP-Service


If ($SNMPCheck.Installed -ne “True”)
{
#Install/Enable SNMP-Service
Write-host “SNMP is NOT installed…”
Write-Host “SNMP Service Installing…”
Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools | Out-Null
}
Else
{
Write-Host “SNMP Services already Installed” -ForegroundColor Green
}

if ($SNMPCheck.Installed -eq “True”)
{
Write-Host “SNMP installed on” $server”, proceeding with configuration…” -ForegroundColor Green
gpupdate /force
}

#Logging
Start-Transcript -Path C:\Temp -Append
