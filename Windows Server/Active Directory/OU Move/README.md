# Automated AVD Hosts OU Move Script

## Overview

This PowerShell script automates the process of moving Azure Virtual Desktop (AVD) host Active Directory (AD) objects into the appropriate organizational units (OUs). This ensures that AVD hosts are organized correctly for the application of Group Policy Objects (GPOs).

## Table of Contents

- [Prerequisites](#prerequisites)

- [Usage](#usage)

- [Configuration](#configuration)

- [Logging](#logging)

## Prerequisites

Before executing this script, ensure you have:

- Administrative privileges in your Active Directory environment.

- PowerShell with the `Active Directory` module available.

## Usage

1\. **Clone the repository** (if applicable):

```bash
git clone https://github.com/yourusername/yourrepository.git

cd yourrepository
```

2\. **Run the script**:

   Open PowerShell as an administrator, navigate to the directory containing the script, and execute it as follows:

```powershell
.\AD_automated_OU_move.ps1
```

3\. **Review the results**:

   The script will output information on which AVD hosts were moved, as well as log the actions taken in a transcript file.

## Configuration

- **Name Filter**: The script currently looks for AVD hosts with names matching the pattern `contosoavd*`. Adjust this filter in the script as necessary.

- **Destination OU**: The destination organizational unit for moving AVD hosts is specified in the `Move-ADObject` command. Ensure it points to the correct OU for your environment.

## Logging

The script logs its actions and results to a transcript file located at `C:\Temp\AD_automated_OU_move_Transcript.txt`. Ensure the specified path is writable, or adjust the path in the script if necessary.
