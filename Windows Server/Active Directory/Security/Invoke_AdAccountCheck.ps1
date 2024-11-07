<#
.SYNOPSIS
   This script performs a comprehensive check on Active Directory accounts.
.DESCRIPTION
   The script checks for various account conditions such as empty passwords, 
   accounts with passwords that do not expire, outdated passwords, and other 
   important account statuses in Active Directory.
.INPUTS
   - InactiveAccountInDay: Number of days for considering an account inactive.
   - UnusedAccountInDay: Number of days for considering an account unused.
   - OutdatedPasswordInDay: Number of days for considering a password outdated.
.OUTPUTS
   Displays a list of accounts matching each condition in separate Out-GridView.
.NOTES
   ===========================================================================
   Created on:    07.11.2024
   Created by:    Michele Blum
   Filename:      Invoke_ADAccountCheck.ps1
   ===========================================================================
.COMPONENT
   Active Directory
.ROLE
   System Administration
.FUNCTIONALITY
   Identifies various account states in an Active Directory environment.
#>

Param (
    [int]$InactiveAccountInDay = 180,
    [int]$UnusedAccountInDay = 360,
    [int]$OutdatedPasswordInDay = 180
)

Function New-AdAccountCheckItem {
    Param (
        [string]$Name,
        [Object[]]$Data
    )

    [pscustomobject]@{
        Name = $Name
        Count = $Data.Count
        SamAccountName = $Data | Select-Object -ExpandProperty SamAccountName
        Data = $Data
    }
}

# Logging configuration
$logFilePath = "C:\Temp\Invoke_AdAccountCheck_Transcript.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Starting Active Directory Account Check..." -ForegroundColor Green

# Define domain and root domain SID
$DomainSID = Get-ADDomain | Select -ExpandProperty DomainSID | Select -ExpandProperty Value
$RootDomainSID = Get-ADDomain (Get-ADForest | Select -ExpandProperty RootDomain) | Select -ExpandProperty DomainSID | Select -ExpandProperty Value

# Define critical groups
$CriticalGroups = @(
    "S-1-5-32-548","S-1-5-32-544","S-1-5-32-551","S-1-5-32-569",
    "$DomainSID-517","$DomainSID-512","$RootDomainSID-519",
    "$DomainSID-527","$DomainSID-526","S-1-5-32-550",
    "S-1-5-32-552","$DomainSID-518","S-1-5-32-549"
)

# Define dates for checks
$InactiveAccountDate = (Get-Date).AddDays(-$InactiveAccountInDay)
$UnusedAccountDate = (Get-Date).AddDays(-$UnusedAccountInDay)
$OutdatedPasswordDate = (Get-Date).AddDays(-$OutdatedPasswordInDay)

# Retrieve accounts from Active Directory
$User = Get-ADUser -Filter * -Properties *
$Computer = Get-ADComputer -Filter * -Properties *
$Admin = $User | Where-Object { $_.AdminCount -ge 1 }
$LegacySA = $User | Where-Object { $_.Name -like "sa-*" -or $_.ServicePrincipalNames -ne $null }
$gMSA = Get-ADServiceAccount -Filter *
$CriticalGroupMember = $CriticalGroups | ForEach-Object {
    $CriticalGroupName = (Get-ADGroup $_ | Select -ExpandProperty SamAccountName)
    Get-ADGroupMember $_ -Recursive | ForEach-Object {
        [pscustomobject]@{
            Groupname = $CriticalGroupName
            SamAccountName = $_.SamAccountName
            DistinguishedName = $_.DistinguishedName
        }
    }
}

# Initialize output array
$Output = @()

# Check conditions and populate output
Write-Host "Checking for Empty Passwords..."
$Output += New-AdAccountCheckItem -Name "Empty Password" -Data $($User | Where-Object { $_.Enabled -eq $true -and $_.PasswordLastSet -eq $null } | Select SamAccountName, DistinguishedName)

Write-Host "Checking for Password Not Required..."
$Output += New-AdAccountCheckItem -Name "Password Not Required" -Data $($User | Where-Object { $_.PasswordNotRequired -eq $true -and $_.Enabled -eq $true } | Select SamAccountName, DistinguishedName)

Write-Host "Checking for Passwords that Never Expire..."
$Output += New-AdAccountCheckItem -Name "Password Never Expires" -Data $($User | Where-Object { $_.Enabled -eq $true -and $_.PasswordNeverExpires -eq $true } | Select SamAccountName, DistinguishedName)

Write-Host "Checking for Outdated Passwords..."
$Output += New-AdAccountCheckItem -Name "Outdated Password" -Data $($LegacySA + $Admin | Where-Object { $_.Enabled -eq $true -and $_.PasswordLastSet -le $OutdatedPasswordDate } | Select SamAccountName, PasswordLastSet, DistinguishedName)

Write-Host "Checking for Inactive Users..."
$Output += New-AdAccountCheckItem -Name "Inactive User" -Data $($User | Where-Object { $_.Enabled -eq $true -and $_.isCriticalSystemObject -ne $true -and $_.LastLogonDate -le $InactiveAccountDate } | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Checking for Unused Users..."
$Output += New-AdAccountCheckItem -Name "Unused User" -Data $($User | Where-Object { $_.Enabled -eq $false -and $_.isCriticalSystemObject -ne $true -and $_.LastLogonDate -le $UnusedAccountDate } | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Checking for Inactive Computers..."
$Output += New-AdAccountCheckItem -Name "Inactive Computer" -Data $($Computer | Where-Object { $_.Enabled -eq $true -and $_.isCriticalSystemObject -ne $true -and $_.LastLogonDate -le $InactiveAccountDate } | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Checking for Unused Computers..."
$Output += New-AdAccountCheckItem -Name "Unused Computer" -Data $($Computer | Where-Object { $_.Enabled -eq $false -and $_.isCriticalSystemObject -ne $true -and $_.LastLogonDate -le $UnusedAccountDate } | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Checking for Suspicious Admin Accounts..."
$Output += New-AdAccountCheckItem -Name "Suspicious Admin" -Data $($Admin | Where-Object { $CriticalGroupMember.SamAccountName -notcontains $_.SamAccountName } | Select SamAccountName, DistinguishedName)

Write-Host "Checking for High Privileged Service Accounts..."
$Output += New-AdAccountCheckItem -Name "High Privileged Service Accounts" -Data $($CriticalGroupMember | Where-Object { ($LegacySA + $gMSA).SamAccountName -notcontains $_.SamAccountName } | Select SamAccountName, Groupname, DistinguishedName)

Write-Host "Checking for High Privileged User Accounts..."
$Output += New-AdAccountCheckItem -Name "High Privileged User Accounts" -Data $($CriticalGroupMember | Where-Object { ($LegacySA + $gMSA).SamAccountName -notcontains $_.SamAccountName } | Select SamAccountName, Groupname, DistinguishedName)

# Display results in Out-GridView
$Output | ForEach-Object {
    $_.Data | Out-GridView -Title $_.Name
}

# Log completion message
Write-Host "Active Directory account check completed." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript