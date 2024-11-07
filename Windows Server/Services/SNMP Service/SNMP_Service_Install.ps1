<#
.SYNOPSIS
   This script installs the SNMP Service with all its components.
.DESCRIPTION
   This script installs the SNMP Service and its components, taking the configuration automatically via Group Policies (GPOs).
.EXAMPLE
   This script can be used as a scheduled task or cron job to automate the installation of the SNMP Service.
.OUTPUTS
   PDF files (this section may not accurately reflect actual outputs).
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
   Automatically installs SNMP with all components.
#>

# Begin logging the installation process to a transcript
# Change path to a suitable location if necessary
Start-Transcript -Path "C:\Temp\SNMP_Service_Install_Transcript.txt" -Append

# Import the ServerManager module to manage Windows features
Import-Module ServerManager

# Inform the user about the current process
Write-Host " " -ForegroundColor Green
Write-Host "Enabling ServerManager to check SNMP..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if the SNMP Service is already installed
Write-Host " " -ForegroundColor Green
Write-Host "Checking to see if SNMP service is installed..." -ForegroundColor Green

# Retrieve information about SNMP Service feature
$SNMPCheck = Get-WindowsFeature -Name SNMP-Service

# If SNMP Service is not installed, proceed with the installation
if ($SNMPCheck.Installed -ne "True") {
    Write-Host "SNMP is NOT installed..." -ForegroundColor Yellow
    Write-Host "Installing SNMP Service..." -ForegroundColor Yellow
    
    # Install SNMP Service with all sub-features and management tools
    Get-WindowsFeature -Name SNMP* | Add-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools | Out-Null
} else {
    # If SNMP Service is already installed
    Write-Host "SNMP Services already installed." -ForegroundColor Green
}

# If SNMP Service is installed, proceed with configuration
if ($SNMPCheck.Installed -eq "True") {
    Write-Host "SNMP installed on server, proceeding with configuration..." -ForegroundColor Green
    
    # Update Group Policy settings immediately
    gpupdate /force
}

# Log completion
Write-Host "SNMP Service installation process completed." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript