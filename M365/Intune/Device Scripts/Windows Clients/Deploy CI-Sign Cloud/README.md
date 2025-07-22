# PowerShell Scripts for CI-Sign Detection and Execution

## Overview

These PowerShell scripts are designed to detect if the `CI-Sign` executable has been run, and to remotely execute the `CI-Sign` executable from a specified network path.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration](#configuration)

## Prerequisites

Before executing these scripts, ensure you have:

- Administrative privileges or proper user permissions on the local machine.
- PowerShell version 5.1 or later installed.
- Network access to the specified path for the `CI-Sign` executable.

## Usage

### Clone the repository

If applicable:

```bash
git clone https://github.com/yourusername/yourrepository.git
cd yourrepository
```

### Detect-CI-Sign.ps1

#### Purpose

This script checks for the existence of a specific path indicating the `CI-Sign` executable has successfully run.

#### Execution

Open PowerShell and execute the script with: `.\Detect-CI-Sign.ps1`

#### Output

The script will output either "CI-Sign executable has run successfully." or "CI-Sign executable has not run successfully." and exit with codes `0` (success) or `1` (failure) respectively.

### Run-CI-Sign.ps1

#### Purpose

This script is designed to remotely run the `CI-Sign` executable located at a specified network path.

#### Execution

Open PowerShell and execute the script with: `.\Run-CI-Sign.ps1`

#### Output

The script will output success or error messages to the console depending on the execution result of the executable.

Configuration
-------------

### Detect-CI-Sign.ps1

The script checks for the existence of the path `LocalApplicationData\ci-sign`.

To modify the script for different behavior, adjust the path as needed in the script.

### Run-CI-Sign.ps1

The script is currently configured to execute the file located at: `\\int.duo-infernale.ch\SYSVOL\int.duo-infernale.ch\scripts\deployment\ci-cloud\ci-sign\CI-Sign.exe`

To modify the script, adjust the `$exePath` variable as needed.

---

*These scripts were created by Michele Blum on 18.06.2025. For any issues or contributions, refer to the repository or contact the author.*