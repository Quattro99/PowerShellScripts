<#
.SYNOPSIS
   This script checks Active Directory users to see if they have the Account Not Delegated property set.
.DESCRIPTION
   This script retrieves members of the "Domänen-Admins" group, checks if their interfaces have the Account Not Delegated property set to false,
   and lists those users. This can help identify users who may need to have this property updated to increase security.
.INPUTS
   None. This script does not require any input parameters.
.OUTPUTS
   Displays a list of users who do not have the Account Not Delegated property set.
.NOTES
   ===========================================================================
   Created on:    07.11.2024
   Created by:    Michele Blum
   Filename:      Check_AccountNotDelegated.ps1
   ===========================================================================
.COMPONENT
   Active Directory
.ROLE
   System Administration
.FUNCTIONALITY
   Checks user permissions related to delegation in Active Directory.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Logging configuration
$logFilePath = "C:\Temp\Check_AccountNotDelegated_Transcript.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Starting check for Account Not Delegated property..." -ForegroundColor Green

# Retrieve members of the "Domänen-Admins" group and check the Account Not Delegated property
$usersWithoutDelegation = Get-ADGroupMember "Domänen-Admins" |
    Get-ADUser -Properties AccountNotDelegated |
    Where-Object {
        -not $_.AccountNotDelegated -and
        $_.objectClass -eq "user"
    }

# Check if any users were found
if ($usersWithoutDelegation) {
    Write-Host "The following users do not have the Account Not Delegated property set:" -ForegroundColor Yellow
    foreach ($user in $usersWithoutDelegation) {
        Write-Host "- User: $($user.SamAccountName)" -ForegroundColor Green
        # Optionally, update the property:
        # Set-ADUser -Identity $user -AccountNotDelegated $true
    }
} else {
    Write-Host "All users in the Domänen-Admins group have the Account Not Delegated property set." -ForegroundColor Green
}

# Log completion message
Write-Host "Account Not Delegated check completed." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript