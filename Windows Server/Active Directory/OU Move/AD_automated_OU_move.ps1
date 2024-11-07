<#
.SYNOPSIS
   This script moves all Azure Virtual Desktop (AVD) hosts to the appropriate Organizational Units (OUs).
.DESCRIPTION
   This script automatically organizes AVD host Active Directory (AD) objects into the specified 
   organizational unit for the associated Group Policy Objects (GPOs).
.EXAMPLE
   This script can be scheduled as a cron job or task to automate the moving of AD objects.
.OUTPUTS
   Moves the specified AVD host AD objects to the designated OU.
.NOTES
   ===========================================================================
   Created on:   	03.05.2023
   Created by:   	Michele Blum
   Filename:     	AD_automated_OU_move.ps1
   ===========================================================================
.COMPONENT
   Active Directory Module
.ROLE
   Automation with PowerShell and Windows Server
.FUNCTIONALITY
   Automatically moves AD objects into an specified OU.
#>

# Logging configuration
$logFilePath = "C:\Temp\AD_automated_OU_move_Transcript.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Starting the automated OU move for AVD hosts..." -ForegroundColor Green

# Get all AVD hosts that match the specified naming convention
$avdhosts = Get-ADObject -Filter 'Name -like "contosoavd*"'

# Check if any AVD hosts were found
if ($avdhosts.Count -eq 0) {
    Write-Host "No AVD hosts found matching the specified pattern." -ForegroundColor Red
} else {
    # Loop through all hosts and move them to the specified OU
    foreach ($avdhost in $avdhosts) {
        Move-ADObject -Identity $avdhost -TargetPath "OU=AVD Hosts,DC=aadds,DC=contoso,DC=ch"
        Write-Host "Moved AVD host: $($avdhost.Name) to OU: OU=AVD Hosts,DC=aadds,DC=contoso,DC=ch" -ForegroundColor Green
    }
}

# Log completion message
Write-Host "Completed moving AVD hosts to the designated OU." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript