# PowerShell Script to Remove Pre-installed HP Software from a Windows System

## Overview

This PowerShell script identifies and uninstalls a predefined list of HP applications and packages from a Windows system. It targets various types of applications including provisioned packages, Appx packages, Win32 applications, and more. This functionality is designed to streamline and optimize system performance by removing unnecessary HP bloatware.

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

    Open PowerShell as an administrator and execute the script with:

    ```powershell
    .\Remove-HPBloatware.ps1
    ```

3. **Review the results**: The script will automatically remove the predefined HP software and log its actions.

## Configuration

The script is currently set to remove a specific list of HP software. You may adjust the lists of applications and packages in the script to fit your specific environment. The predefined lists include:

### Appx Packages to Remove
- AD2F1837.HPJumpStarts
- AD2F1837.HPPCHardwareDiagnosticsWindows
- AD2F1837.HPPowerManager
- AD2F1837.HPPrivacySettings
- AD2F1837.HPSupportAssistant
- AD2F1837.HPSureShieldAI
- AD2F1837.HPSystemInformation
- AD2F1837.HPQuickDrop
- AD2F1837.HPWorkWell
- AD2F1837.myHP
- AD2F1837.HPDesktopSupportUtilities
- AD2F1837.HPQuickTouch
- AD2F1837.HPEasyClean

### Programs to Remove
- HP Client Security Manager
- HP Connection Optimizer
- HP Documentation
- HP MAC Address Manager
- HP Notifications
- HP Security Update Service
- HP System Default Settings
- HP Sure Click
- HP Sure Click Security Browser
- HP Sure Run
- HP Sure Recover
- HP Sure Sense
- HP Sure Sense Installer
- HP Support Assistant
- HP Wolf Security
- HP Wolf Security Application Support for Sure Sense
- HP Wolf Security Application Support for Windows

## Logging

The script logs its actions and results to a log file located at `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\HPbloatware.log`. Ensure that the specified path is writable, or adjust the logging path in the script as needed.

---

*This script was created by Michele Blum on 28.06.2024, inspired by an original script for deleting HP pre-installed software by foeyonghai @ Intune Specialist. For any issues or contributions, refer to the repository or contact the author.*