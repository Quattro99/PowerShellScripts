# PowerShell Scripts for Exchange Online Mailbox Management

## Overview
This folder contains PowerShell scripts designed for managing Exchange Online mailboxes. The scripts automate specific administrative tasks, including mailbox permission retrieval, user account creation, and setting regional configurations for user mailboxes.

## Scripts

### 1. GetAllAccessRights.ps1

#### Purpose
Retrieves mailbox permissions for all user mailboxes in an Exchange Online environment and exports the permissions to a CSV file.

#### Features
- Connects to Exchange Online.
- Retrieves mailbox permissions for each user mailbox.
- Exports the permissions to a specified CSV file.

#### Usage
1. Open PowerShell as an administrator.
2. Run the script to retrieve and export mailbox permissions:
   ```powershell
   .\GetAllAccessRights.ps1
   ```
   You need administrative privileges in Exchange Online to run this script.

### 2. SetLanguageAndTimezoneOnAllMailboxes.ps1

#### Purpose
Sets the language and timezone settings for all user mailboxes in an Exchange Online environment.

#### Features
-   Connects to Exchange Online.
-   Updates language, date format, time format, and timezone for all user mailboxes.
-   Retrieves updated regional configuration to verify changes.

#### Usage
1.  Open PowerShell as an administrator.
2.  Run the script to set regional configurations:
    ```powershell
    .\SetLanguageAndTimezoneOnAllMailboxes.ps1
    ```

### 3. SetLanguageAndTimezoneOnAllMailboxes.ps1

#### Purpose
Creates user accounts in Microsoft Online Services (O365) based on a CSV template and exports the results, including the newly created account details.

#### Features
-   Connects to O365 and creates user accounts using a CSV file.
-   Exports results, including newly created account information.

#### Usage
1.  Ensure the CSV file with user data is ready at `C:\Temp\O365\MailboxesTemplate.csv`.
2.  Run the script to create user accounts and export the results:
    ```powershell
    .\SetLanguageAndTimezoneOnAllMailboxes.ps1
    ```

## Notes
-   Ensure you have the necessary permissions to run these scripts.
-   Test scripts in a non-production environment when possible.
-   Customize scripts (e.g., paths, settings) to fit your organization's specific requirements prior to execution.