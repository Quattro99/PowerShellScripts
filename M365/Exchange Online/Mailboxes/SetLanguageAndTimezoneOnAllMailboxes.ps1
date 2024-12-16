<#
.SYNOPSIS
   This script sets the language and timezone settings for all user mailboxes in an Exchange Online environment.

.DESCRIPTION
   The script connects to Exchange Online and retrieves all user mailboxes. It modifies the regional configuration settings for each mailbox, including language, date format, time format, and timezone. Finally, it retrieves the updated regional configuration settings for verification.

.INPUTS
   - This script does not require direct input parameters. It automatically processes all user mailboxes in the environment.

.OUTPUTS
   - Displays the regional configuration settings for all updated user mailboxes, including properties such as Language, DateFormat, TimeFormat, and TimeZone.

.NOTES
   ===========================================================================
   Created on:    16.12.2024
   Created by:    Michele Blum
   Filename:      SetLanguageAndTimezoneOnAllMailboxes.ps1
   ===========================================================================
.COMPONENT
   Exchange Online Management

.ROLE
   Exchange Administrator

.FUNCTIONALITY
   Automates the process of configuring regional settings for user mailboxes in Exchange Online, ensuring consistency across the organization in terms of language and time formats.
#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Set the regional configuration for all user mailboxes
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -eq "UserMailbox"} | 
ForEach-Object {
    Set-MailboxRegionalConfiguration -Identity $_.Identity -Language "de-CH" `
    -DateFormat "dd.MM.yyyy" -TimeFormat "HH:mm" -TimeZone "W. Europe Standard Time" -LocalizeDefaultFolderName
}

# Retrieve and display the updated regional configuration for all mailboxes
Get-Mailbox -ResultSize Unlimited | 
Where-Object {$_.RecipientTypeDetails -eq "UserMailbox"} | 
ForEach-Object {
    Get-MailboxRegionalConfiguration -Identity $_.Identity
}