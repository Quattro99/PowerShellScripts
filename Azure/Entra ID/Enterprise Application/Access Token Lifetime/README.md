# Token Lifetime Policy Management Script

## Overview

This PowerShell script manages Microsoft Entra ID (Entra ID) token lifetime policies by creating a new token lifetime policy that sets the access token lifetime to 12 hours and binding it to a specified application. It leverages the Microsoft Graph PowerShell SDK to interact with Entra ID.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Script Details](#script-details)
- [Error Handling](#error-handling)
- [License](#license)
- [Contributors](#contributors)

## Prerequisites

Before running the script, ensure you have the following:

1. **PowerShell**: Version 5.0 or later.
2. **Microsoft Graph PowerShell SDK**: Install it via PowerShell Gallery:
    ```powershell
    Install-Module Microsoft.Graph -Scope CurrentUser -AllowPrerelease
    ```
3. **Permissions**: You must have the following permissions granted:
   - Application: `Policy.ReadWrite.ApplicationConfiguration`, `Policy.Read.All`, `Application.ReadWrite.All`.
4. **Entra ID Tenant**: Ensure you have an Entra ID tenant with at least one registered application.

## Usage

1. **Clone or Download**: Get the script file (`Change_Access_Token_Lifetime_On_Specific_EID_Enterprise_Application.ps1`) to your local machine.
2. **Modify the Displayname and Access Token Lifetime**: Update the line `$tokenLifetimePolicy = Create-TokenLifetimePolicy -DisplayName "NAME" -AccessTokenLifetime "12:00:00"` with your preferences.
3. **Modify Application ID**: Update the `$applicationId` variable in the script with the actual ID of the application you want to bind the policy to.
4. **Run the Script**:
   Open PowerShell and run the script:
   ```powershell
   .\Change_Access_Token_Lifetime_On_Specific_EID_Enterprise_Application.ps1

## Script Details

The script includes the following main features:

-   Create Token Lifetime Policy: Creates a token lifetime policy with a specified access token lifetime (currently set to 12 hours).
-   Bind Policy to Application: Binds the created token lifetime policy to a specified Entra ID application.
-   Informative Output: Displays the creation and binding status of the policies.

### Example of Key Functions

-   `Create-TokenLifetimePolicy`: This function takes parameters for display name and access token lifetime and creates the policy.
-   `Bind-ApplicationTokenLifetimePolicy`: This function binds the created policy to the specified application.

## Error Handling

The script contains error handling mechanisms that provide informative messages if any operation fails. Pay attention to the output logs for troubleshooting.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Quattro99/PowerShellScripts/blob/main/LICENSE) file for details.

## Contributors

-   Michele Blum: Initial creation and implementation of the script.
