# Restrict Microsoft 365 group creation to a specific group

## Overview

`RestrictM365GroupCreation.ps1` is a PowerShell script designed to manage group creation permissions in a Microsoft 365 environment. The script connects to the Microsoft Graph API and modifies directory settings to restrict or allow the creation of Microsoft 365 groups based on your configuration.

## Features

- Checks existing group creation settings.
- Creates default settings if none exist.
- Allows administrators to specify a group for creation permissions.
- Outputs the current directory settings for verification.

## Requirements

- PowerShell 5.1 or later.
- Microsoft Graph PowerShell SDK.
- Appropriate permissions granted to the user running the script:
  - `Directory.ReadWrite.All`
  - `Group.Read.All`

## Prerequisites

1. Install the Microsoft Graph PowerShell SDK:
   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
2.  Ensure you have the required permissions to modify directory settings in your Azure AD tenant.
    

## Usage

1.  Open PowerShell and navigate to the directory where the script is located.  
2.  Modify the script parameters:
    
    *   Set the variable **$GroupName** to the display name of the group you wish to control permissions for.
        
    *   Set the variable **$AllowGroupCreation** to **"True"** or **"False"** based on whether you want to allow group creation.
        
3.  Run the script:
    ```powershell
    .\RestrictM365groupcreation.ps1
## Example
To restrict the creation of groups for a specific group named "MyAdminGroup", set the parameters as follows:

```powershell 
$GroupName = "MyAdminGroup"  
$AllowGroupCreation = "False"
```
Then execute the script.

## Output

After running the script, the current values of the directory settings will be displayed, allowing you to verify the changes made:

```powershell 
(Get-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID).Values
````

## Notes

*   This script is designed to run in environments where organization policies and Azure AD configurations permit the management of group settings.
    
*   Use caution when modifying settings, as incorrect configurations may impact user permissions and group management capabilities.