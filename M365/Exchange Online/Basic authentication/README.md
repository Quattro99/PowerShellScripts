# DisableBasicAuthenticationOnAllMailboxes.ps1

## Overview
`DisableBasicAuthenticationOnAllMailboxes.ps1` is a PowerShell script designed to disable Basic Authentication for all mailboxes in an Exchange Online environment. This script enhances security by ensuring that only Modern Authentication methods are allowed for mailbox access.

## Features
- Connects to Exchange Online using an admin account.
- Retrieves a list of all user mailboxes with Basic Authentication currently enabled.
- Disables Basic Authentication while ensuring that other protocols such as POP, IMAP, MAPI, and ActiveSync remain enabled.

## Prerequisites
- PowerShell must be installed on your machine.
- The user running this script must have appropriate **Exchange Administrator** privileges.
- You must be connected to the Exchange Online Management Module.

## Installation Steps
1. **Open PowerShell** as an administrator.
2. **Connect to Exchange Online:**
   Execute the following command to connect with your admin UPN:
   ```powershell
   Connect-ExchangeOnline -UserPrincipalName <your_admin_upn>
   ```
3. **Run the Script**: To disable Basic Authentication for all mailboxes, run:
   ```powershell
    .\DisableBasicAuthenticationOnAllMailboxes.ps1
    ```
    Ensure you provide the correct `$Identity` for the mailboxes being processed.

## Input Variables
-   $AdminUPN: User Principal Name (UPN) of the admin account used to connect to Exchange Online.
-   $Identity: The identity of each mailbox to be processed within the `foreach` loop.

## Output
The script provides console output confirming that Basic Authentication has been disabled for each user mailbox processed.

## Notes
-   Make sure to review the mailbox settings after executing the script to ensure that configurations meet your organization's security policies.
-   Always test scripts in a non-production environment where possible.