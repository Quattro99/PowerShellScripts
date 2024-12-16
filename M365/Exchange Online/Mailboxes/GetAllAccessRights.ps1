<#
.SYNOPSIS
   This script retrieves mailbox permissions for all user mailboxes in an Exchange Online environment and exports the permissions to a CSV file.

.DESCRIPTION
   The script connects to Exchange Online and retrieves all mailboxes. For each mailbox, it retrieves the permissions granted to users and exports the details, including the identity of the mailbox, the user, and their access rights, to a specified CSV file.

.INPUTS
   - This script does not require direct input parameters. It automatically retrieves all user mailboxes in the environment.

.OUTPUTS
   - A CSV file (e.g., "C:\temp\permissions.csv") containing mailbox permission details for all user mailboxes. The CSV columns include:
     - Identity: The mailbox identity.
     - User: The user with permissions on the mailbox.
     - AccessRights: The level of access granted to the user.

.NOTES
   ===========================================================================
   Created on:    16.12.2024
   Created by:    Michele Blum
   Filename:      GetAllAccessRights.ps1
   ===========================================================================
.COMPONENT
   Exchange Online Management

.ROLE
   Exchange Administrator

.FUNCTIONALITY
   Automates the process of retrieving mailbox permissions for all mailboxes and exporting the information for auditing and reporting purposes.
#>

## Connect to Exchange Online
Connect-ExchangeOnline

# Ensure the output directory exists
$outputPath = "C:\temp\permissions.csv"
if (-Not (Test-Path -Path $outputPath)) {
    New-Item -ItemType File -Path $outputPath -Force
}

# Retrieve all mailboxes
$identities = Get-Mailbox -ResultSize Unlimited

# Get mailbox permissions for each mailbox and export to CSV
foreach ($identity in $identities) {
    Get-MailboxPermission -Identity $identity.Identity | 
    Select-Object Identity, User, AccessRights | 
    Export-Csv -Path $outputPath -NoTypeInformation -Append
}