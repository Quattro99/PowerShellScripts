# PowerShell Script to Configure Outlook 2016 Roaming Signatures

## Overview

This PowerShell script creates a registry key and sets a value to configure Outlook 2016 for disabling roaming signatures at the user level. It ensures that the required registry key is created if it doesn't exist, and sets the corresponding value.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration](#configuration)

## Prerequisites

Before executing this script, ensure you have:

- Administrative privileges or proper user permissions on the local machine.
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
    .\Configure_Outlook_RoamingSignatures.ps1
    ```

3. **Review the results**: The script will create the required registry key and set the value, logging its actions.

## Configuration

The script is configured to create the registry key `Setup` under `HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook` and set the `DisableRoamingSignaturesTemporaryToggle` value to `1`.

To modify the script for different behavior, adjust the registry path or value as needed. Here is the key configuration:

- **Registry Path**: `HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Setup`
- **Value Name**: `DisableRoamingSignaturesTemporaryToggle`
- **Value Type**: `DWORD`
- **Value**: `1`

---

*This script was created by Michele Blum on 20.05.2025. For any issues or contributions, refer to the repository or contact the author.*