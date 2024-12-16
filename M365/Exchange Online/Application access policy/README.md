# CreateAccessPolicy.ps1

## Overview
`CreateAccessPolicy.ps1` is a PowerShell script designed to restrict access to an Azure Enterprise Application for a specific set of mailboxes. It allows control over which users can access the application through various APIs, including Outlook REST, Microsoft Graph, and Exchange Web Services (EWS).

## Features
- Creates Application Access Policies to restrict or deny access based on defined scopes.
- Utilizes the `New-ApplicationAccessPolicy` cmdlet from the Exchange Online Management Module.
- Supports testing of access policies for specific mailboxes.
- You need administrative privileges in Exchange Online to run this script.

Installation Steps
------------------

1.  Install the Exchange Online Management Module (if not already installed):

    powershellCode kopieren

    `Install-Module -Name ExchangeOnlineManagement`

2.  Import the Module:

    powershellCode kopieren

    `Import-Module ExchangeOnlineManagement`

3.  Set Execution Policy (if not already set):

    powershellCode kopieren

    `Set-ExecutionPolicy RemoteSigned`

4.  Set Required Variables in the script:

    powershellCode kopieren

    `$adm = "upn of an Exchange Online Admin"
    $appid = "App ID from the enterprise application that the access has to be restricted"
    $groupid = "Group that should have access to the enterprise application"
    $testmail = "E-mail address to test the access to the enterprise application"`

5.  Connect to Exchange Online: Execute the following command to establish a connection:

    powershellCode kopieren

    `Connect-ExchangeOnline -UserPrincipalName $adm`

6.  Check Current Application Access Policies: Fetch and display existing application access policies:

    powershellCode kopieren

    `Get-ApplicationAccessPolicy | Format-List`

7.  Add a New Application Access Policy: Use the following command to restrict access:

    powershellCode kopieren

    `New-ApplicationAccessPolicy -AppId $appid -PolicyScopeGroupId $groupid -AccessRight RestrictAccess -Description "Restrict this app to mail only via xyz"`

8.  Verify Current Application Access Policies: Re-fetch policies to confirm the new one was added:

    powershellCode kopieren

    `Get-ApplicationAccessPolicy | Format-List`

9.  Test the Application Access Policy: Ensure the policy is working correctly with:

    powershellCode kopieren

    `Test-ApplicationAccessPolicy -Identity $testmail -AppId $appid`

## Inputs
-   Ensure you have the following documentation links available for guidance:
    -   [Microsoft Graph Email Sending Guide](https://medium.com/medialesson/how-to-send-emails-in-net-with-the-microsoft-graph-a97b57430bbd)
    -   [New Application Access Policy Documentation](https://learn.microsoft.com/en-us/powershell/module/exchange/new-applicationaccesspolicy?view=exchange-ps#-policyscopegroupid)

## Output
- This script modifies access restrictions for the specified Azure Enterprise Application and can output current policy status.

## Notes
- The policies created by the script are complementary to the permission scopes declared by the application.