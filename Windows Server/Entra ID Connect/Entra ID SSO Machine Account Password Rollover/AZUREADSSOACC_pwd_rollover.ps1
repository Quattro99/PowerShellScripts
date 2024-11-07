<#
.SYNOPSIS
   This script performs a password rollover for the Entra ID SSO account in an on-premises Active Directory environment.
.DESCRIPTION
   This script updates the password for the Entra ID SSO account used in seamless single sign-on (SSO) and checks the current SSO status.
.INPUTS
   None. This script does not require any input parameters, but domain admin credentials will be prompted.
.OUTPUTS
   Displays the updated status of the SSO account and logs the results.
.NOTES
   ===========================================================================
   Created on:    07.11.2024
   Created by:    Michele Blum
   Filename:      AZUREADSSOACC_pwd_rollover.ps1
   ===========================================================================
.COMPONENT
   Azure Active Directory
.ROLE
   System Administration
.FUNCTIONALITY
   Updates the Entra ID SSO account password and checks its status.
#>

# Change to the Microsoft Azure Active Directory Connect installation directory
cd 'C:\Program Files\Microsoft Azure Active Directory Connect\'

# Logging configuration
$logFilePath = "C:\Temp\AZUREADSSOACC_pwd_rollover_Transcript.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Starting Entra ID SSO account password rollover..." -ForegroundColor Green

# Import the Seamless SSO PowerShell module
Write-Host "Importing the AzureADSSO module..." -ForegroundColor Yellow
Import-Module .\AzureADSSO.psd1

# Authenticate with Entra ID using the AAD credentials
Write-Host "Authenticating with Entra ID..." -ForegroundColor Yellow
New-AzureADSSOAuthenticationContext

# Check and view the current SSO status of the Active Directory forest
Write-Host "Getting current SSO status of the AD forest..." -ForegroundColor Yellow
$SSOStatus = Get-AzureADSSOStatus | ConvertFrom-Json
Write-Host "Current SSO Status:" -ForegroundColor Green
$SSOStatus

# Update the SSO account; user will be prompted for domain admin credentials
Write-Host "Updating SSO account. Please provide AD domain admin credentials..." -ForegroundColor Yellow
Update-AzureADSSOForest

# Log success or failure of the update
if ($?) {
    Write-Host "SSO account successfully updated." -ForegroundColor Green
} else {
    Write-Host "There was an error while updating the SSO account. Please check the details." -ForegroundColor Red
}

# Check if the password of the account has been successfully changed
Write-Host "Checking if the password of the AZUREADSSOACC account has been successfully changed..." -ForegroundColor Yellow
$ADAccount = Get-ADComputer AZUREADSSOACC -Properties *
Write-Host "Account Name: $($ADAccount.Name)" -ForegroundColor Green
Write-Host "Password Last Set: $($ADAccount.PasswordLastSet)" -ForegroundColor Green

# Log completion message
Write-Host "Password rollover process completed." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript