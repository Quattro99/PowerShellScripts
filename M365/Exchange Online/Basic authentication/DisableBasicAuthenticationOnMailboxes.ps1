<#
.SYNOPSIS
   This script disables Basic Authentication for all mailboxes in an Exchange Online environment.

.DESCRIPTION
   The script connects to Exchange Online using an admin account and retrieves a list of all user mailboxes with Basic Authentication enabled. 
   It then loops through each mailbox and disables Basic Authentication while ensuring all other mailbox features such as POP, IMAP, MAPI, and ActiveSync are enabled.

.INPUTS
   - $AdminUPN: User Principal Name (UPN) of the Exchange Online admin.
   - $Identity: The identity of each mailbox to process.

.OUTPUTS
   - Confirmation of mailbox settings applied, specifically with respect to Basic Authentication.

.NOTES
   ===========================================================================
   Created on:    16.12.2024
   Created by:    Michele Blum
   Filename:      DisableBasicAuthenticationOnAllMailboxes.ps1
   ===========================================================================
.COMPONENT
   Exchange Online Management

.ROLE
   Exchange Administrator

.FUNCTIONALITY
   Automates the process of disabling Basic Authentication across all user mailboxes in Exchange Online, enhancing security by enforcing Modern Authentication methods.
#>

$AdminUPN = "xxx"
$Identity = "xxx"

Connect-ExchangeOnline -UserPrincipalName $AdminUPN

$Users = Get-CASMailbox -ResultSize unlimited
$Users | where {$_.SmtpClientAuthenticationDisabled -eq $false}

foreach ($user in $users)
{
    Set-CASMailbox -Identity $Identity -PopEnabled $True -ImapEnabled $True -MAPIEnabled $True -ActiveSyncEnabled $True -EWSEnabled $True -SmtpClientAuthenticationDisabled $false
}