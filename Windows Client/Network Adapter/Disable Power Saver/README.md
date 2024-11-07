# PowerShell Script to Disable Network Adapter Power Saving

## Overview

This PowerShell script automatically disables the "Allow the computer to turn off this device to save power" option for physical network adapters that are not Microsoft devices. This functionality is designed to help ensure network adapters remain active and connections are stable, preventing interruptions that power-saving features might cause.

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

1\. **Clone the repository** (if applicable):

```bash
git clone https://github.com/yourusername/yourrepository.git

cd yourrepository
```

2\. **Run the script**:

   Open PowerShell as an administrator and execute the script with:

```powershell
.\PNPCapabilities.ps1
```

3\. **Review the results**: The script will output which network adapters were processed, and whether their power-saving options were disabled.

## Configuration

The script is currently set to check all physical network adapters and apply the change accordingly. You may adjust the filtering logic if needed to fit your specific environment.

## Logging

The script logs its actions and results to a transcript file located at `C:\Temp\PNPCapabilities_Transcript.txt`. Ensure that the specified path is writable, or adjust the logging path in the script as needed.
