<#
.SYNOPSIS
   This script creates user accounts in Microsoft Online Services (O365) based on a CSV template and exports the results, including the newly created account details.

.DESCRIPTION
   The script imports user data from a specified CSV file containing user attributes and creates new user accounts in O365. It then exports the results of the account creation process, including any generated passwords, to a CSV file for review.

.INPUTS
   - CSV file path (example: "C:\Temp\O365\MailboxesTemplate.csv") containing user details with the following headers:
     - DisplayName
     - FirstName
     - LastName
     - UserPrincipalName
     - AccountSkuId
     - UsageLocation

.OUTPUTS
   - CSV file (example: "C:\Temp\O365\NewAccountResults.csv") containing the results of the account creation process.

.NOTES
   ===========================================================================
   Created on:    16.12.2024
   Created by:    Michele Blum
   Filename:      BulkCreateNewMailboxes.ps1
   ===========================================================================
.COMPONENT
   Microsoft Online Services Module (MSOnline)

.ROLE
   Azure / O365 Administrator

.FUNCTIONALITY
   Automates the process of creating user accounts in O365 from a CSV template and exporting the results for auditing and verification purposes.
#>

# Install module MSOnline (uncomment the next line if the module is not already installed)
# Install-Module MSOnline -Force

# Import module MSOnline
Import-Module MSOnline

# Connect to the MsolService
Connect-MsolService

# Import CSV and create User accounts, then export results
$inputCsvPath = "C:\Temp\O365\MailboxesTemplate.csv"
$outputCsvPath = "C:\Temp\O365\NewAccountResults.csv"

# Read CSV file and create accounts
$results = Import-Csv -Path $inputCsvPath | ForEach-Object {
    # Create a new user account
    $newUser = New-MsolUser -DisplayName $_.DisplayName `
                              -FirstName $_.FirstName `
                              -LastName $_.LastName `
                              -UserPrincipalName $_.UserPrincipalName `
                              -UsageLocation $_.UsageLocation `
                              -LicenseAssignment $_.AccountSkuId

    # Return user details for output
    [PSCustomObject]@{
        DisplayName = $newUser.DisplayName
        UserPrincipalName = $newUser.UserPrincipalName
        LicenseAssigned = $_.AccountSkuId
        UsageLocation = $_.UsageLocation
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation -Verbose