<#
.SYNOPSIS
   This script retrieves users in Active Directory and their password last set date.
.DESCRIPTION
   The script fetches all enabled AD users and their password last set information,
   helping administrators track password policies and user account statuses.
.INPUTS
   None. This script does not require any input parameters.
.OUTPUTS
   Displays a list of enabled users along with their password last set date.
.NOTES
   ===========================================================================
   Created on:    07.11.2024
   Created by:    Michele Blum
   Filename:      Get_PW_LastSet.ps1
   ===========================================================================
.COMPONENT
   Active Directory
.ROLE
   System Administration
.FUNCTIONALITY
   Fetches password last set details for enabled Active Directory users.
#>

# Logging configuration
$logFilePath = "C:\Temp\Get_PW_LastSet_Transcript.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Retrieving enabled users and their password last set information..." -ForegroundColor Green

# Get all enabled AD users and select relevant properties
$users = Get-ADUser -Filter { Enabled -eq $True } -Properties pwdLastSet, passwordLastSet, passwordNeverExpires, cannotChangePassword |
    Select-Object Name, pwdLastSet

# Check if any users were found
if ($users) {
    Write-Host "The following enabled users and their password last set information were found:" -ForegroundColor Yellow
    foreach ($user in $users) {
        Write-Host "- User: $($user.Name), Password Last Set: $($user.pwdLastSet)" -ForegroundColor Green
    }
} else {
    Write-Host "No enabled users found." -ForegroundColor Red
}

# Log completion message
Write-Host "Password last set information retrieval completed." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript