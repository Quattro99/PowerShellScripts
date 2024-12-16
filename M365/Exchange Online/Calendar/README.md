# DefaultCalendarUserPermissions.ps1

## Overview
`DefaultCalendarUserPermissions.ps1` is a PowerShell script designed to set default calendar permissions for user, shared, room, and equipment mailboxes in an Exchange Online environment. It ensures that all specified calendar folders have consistent access rights.

## Features
- Connects to Exchange Online and retrieves all user, shared, room, and equipment mailboxes.
- Checks for the existence of calendar folders named "Calendar" (and "Kalender" in certain languages).
- Sets default permissions (defaulting to "Reviewer") for the calendar folders.
- Outputs the status of permission changes for each mailbox.

## Prerequisites
- PowerShell should be installed on your machine.
- The user running this script must have permissions to administer Exchange Online.
- You must be connected to Exchange Online Management.

## Installation Steps
1. **Open PowerShell** as an administrator.
2. **Connect to Exchange Online:**
   Execute the following command to connect:
   ```powershell
   Connect-ExchangeOnline
   ```
3. **Run the Script**: To set calendar permissions, run:
    ```powershell
    .\DefaultCalendarUserPermissions.ps1
    ```

## Input

The script does not require any user input. It automatically fetches mailbox information from Exchange Online.

## Output
The script provides console output indicating each mailbox processed and whether the default calendar permissions were already set or newly applied.

##Notes
-   The script sets permissions for the "Default" user on the calendar.
-   The permission level can be adjusted by modifying the `$Permission` variable in the script.