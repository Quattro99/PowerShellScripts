# PowerShell Script to Configure NumLock at Startup for Default User Profile

## Overview

This PowerShell script sets the `InitialKeyboardIndicators` value for the default user profile to control the behavior of the NumLock key at startup. By configuring the registry, it ensures NumLock is enabled when a user logs in.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration](#configuration)

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
    .\Configure_NumLock.ps1
    ```

3. **Review the results**: The script will update the registry and log its actions.

## Configuration

The script is currently configured to set the `InitialKeyboardIndicators` value to "2" under the registry key `HKU\.DEFAULT\Control Panel\Keyboard`. This ensures that NumLock is enabled at startup.

To modify the script for different behavior, adjust the registry path or value as needed. Here is the key configuration:

- **Registry Path**: `Registry::HKU\.DEFAULT\Control Panel\Keyboard`
- **Value Name**: `InitialKeyboardIndicators`
- **Value**: `2`

---

*This script was created by Michele Blum on 20.05.2025. For any issues or contributions, refer to the repository or contact the author.*