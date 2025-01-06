# PowerShell Script to Remove Desktop Shortcuts

## Overview

This PowerShell script deletes `.lnk` files (shortcuts) from the desktop of the current user. It can also delete shortcuts from the public desktop if indicated. This functionality helps maintain a clean and organized desktop environment.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration](#configuration)
- [Logging](#logging)

## Prerequisites

Before executing this script, ensure you have:

- Administrative privileges on the local machine (if deleting from the public desktop).
- PowerShell version 5.1 or later installed.

## Usage

1. **Clone the repository** (if applicable):

    ```bash
    git clone https://github.com/yourusername/yourrepository.git
    cd yourrepository
    ```

2. **Run the script**:

    Open PowerShell and execute the script with:

    ```powershell
    .\Remove-PublicDesktopShortcuts.ps1
    ```

    **Note**: To run the script with the option to delete only from the current user's desktop, use the following:

    ```powershell
    .\Remove-PublicDesktopShortcuts.ps1 -MyDesktopOnly $true
    ```

3. **Review the results**: The script will output which desktop shortcuts were deleted.

## Configuration

The script by default will remove shortcuts from both the current user's desktop and the public desktop. To delete only from the current user's desktop, pass the parameter `$MyDesktopOnly` as `$true`.

- **Delete from current user's desktop only**:

    ```powershell
    .\Remove-PublicDesktopShortcuts.ps1 -MyDesktopOnly $true
    ```

- **Delete from both the current user's desktop and public desktop** (default):

    ```powershell
    .\Remove-PublicDesktopShortcuts.ps1
    ```

## Logging

The script uses verbose logging to display which shortcuts are being deleted. Ensure PowerShell's console output is visible to monitor this information.
