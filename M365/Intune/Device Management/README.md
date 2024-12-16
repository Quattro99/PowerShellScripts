# IntuneDeviceCleanUp.ps1

## Overview
`IntuneDeviceCleanUp.ps1` is a PowerShell script designed to clean up stale and disabled Windows Autopilot devices from Microsoft Intune. By querying the Microsoft Graph API, this script identifies devices that have not contacted the Intune service for a specified duration or have been disabled, and it proceeds to remove them from the management portal.

## Features
- Connects to Microsoft Graph with the required permissions.
- Identifies stale Autopilot devices based on last contact time.
- Identifies devices that have never contacted Intune.
- Locates and removes disabled devices from Intune and the Autopilot portal.
- Logs the cleanup process in a designated log file.

## Prerequisites
- **PowerShell**: Ensure you have PowerShell installed on your machine.
- **Microsoft Graph Modules**: Install the required Microsoft Graph modules if not already installed:
  ```powershell
  Install-Module Microsoft.Graph.Beta.DeviceManagement.Enrollment
  Install-Module Microsoft.Graph.Identity.DirectoryManagement
  Install-Module Microsoft.Graph.Beta.DeviceManagement.Actions
  ```
  **Permissions**: Make sure the account used to run the script has the necessary permissions to read and write device configurations in Intune.

## Usage
1.  Open PowerShell as an administrator.
2.  Modify the Script: Set your tenant ID in the script where indicated:
    ```powershell
    $tenantid = "***"
    ```
3.  Run the Script to clean up the devices:
    ```powershell
    .\IntuneDeviceCleanUp.ps1
    ```

## Input/Output
- Input: The script retrieves tenant ID from the configuration and does not require additional input parameters.
- Output: Summary output is provided in the console regarding the number of devices found in different categories, as well as detailed logging of the actions taken in `C:\temp\autopilotlog.log`.

## Notes
- Ensure logging is enabled and accessible for review after running the script.
- It is recommended to review the summary output before deletion to ensure accuracy.

## Source
For additional context and guidance, refer to the original article (thank you Niklas): [Autopilot Cleanup Script](https://niklastinner.medium.com/autopilot-cleanup-script-e29c98a71aa6)