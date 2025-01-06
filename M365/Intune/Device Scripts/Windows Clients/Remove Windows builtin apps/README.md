# PowerShell Script to Remove Built-in Apps from Windows 11 for All Users

## Overview

This PowerShell script removes built-in apps (modern apps) from Windows 11 for all users. There are two versions of the script:
- **Remove-Appx-AllUsers.ps1:** This script uses a hardcoded list of built-in apps to remove.
- **Remove-Appx-AllUsers-CloudSourceList.ps1:** This script removes built-in apps based on a dynamically updated list hosted in Azure Blob storage or GitHub. Only those apps prefixed with a `#` in this file will be considered eligible for removal.

> **Warning:** Use this script with caution, as restoring deleted provisioning packages is not a simple process.

> **Tip:** If removing `MicrosoftTeams`, also consider disabling the "Chat" icon on the taskbar using Intune settings catalog, as clicking this will re-install the `appxpackage` for the user.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration](#configuration)
- [Logging](#logging)

## Prerequisites

Before executing this script, ensure you have:

- Administrative privileges on the local machine.
- PowerShell version 5.1 or later installed.

## Usage

1. **Clone the repository** (if applicable):

    ```bash
    git clone https://github.com/yourusername/yourrepository.git
    cd yourrepository
    ```

2. **Run the script**:

    Open PowerShell as an administrator and execute the appropriate script:

    To use the hardcoded list script:
    ```powershell
    .\Remove-Appx-AllUsers.ps1
    ```

    To use the script with the dynamic list from the cloud:
    ```powershell
    .\Remove-Appx-AllUsers-CloudSourceList.ps1
    ```

3. **Review the results**: The script will remove the specified built-in apps and log its actions.

## Configuration

### Hardcoded List Script (`Remove-Appx-AllUsers.ps1`)

The script uses a hardcoded list of built-in apps to remove. You can adjust the lists of apps to be removed directly in the script.

### Dynamic List from Cloud Script (`Remove-Appx-AllUsers-CloudSourceList.ps1`)

The script removes built-in apps based on a dynamically updated list hosted online. You can adjust the URL for the `Remove-List-Appx.txt` file in the script to point to your specific location.

#### Example List (`Remove-List-Appx.txt`)

```plaintext
#Microsoft.BingNews
#Microsoft.BingWeather
#Microsoft.GamingApp
#Microsoft.GetHelp
#Microsoft.Getstarted
#Microsoft.MicrosoftOfficeHub
#Microsoft.MicrosoftSolitaireCollection
#Microsoft.MicrosoftStickyNotes
#Microsoft.PowerAutomateDesktop
#Microsoft.Todos
#Microsoft.WindowsAlarms
#Microsoft.WindowsCommunicationsApps
#Microsoft.WindowsFeedbackHub
#Microsoft.WindowsMaps
#Microsoft.Xbox.TCUI
#Microsoft.XboxGameOverlay
#Microsoft.XboxGamingOverlay
#Microsoft.XboxIdentityProvider
#Microsoft.XboxSpeechToTextOverlay
#Microsoft.YourPhone
#MicrosoftTeams
#Microsoft.Office.OneNote
#Microsoft.XboxApp
```

* Feel free to modify this list in the script to add or remove apps according to your needs.
* Only the apps prefixed with # will be targeted for removal.

## Logging

The script logs its actions and results to a log file located at `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AppXRemoval.log`. Ensure that the specified path is writable, or adjust the logging path in the script as needed.

---

*This script was created by Michele Blum on 28.06.2024, based on an original Windows 10 app removal script by Nickolaj Andersen @ MSEndpointMgr. For any issues or contributions, refer to the repository or contact the author.*