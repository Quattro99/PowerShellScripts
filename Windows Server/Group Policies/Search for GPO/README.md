# GPO Check for a string

## Overview

This PowerShell script automates the process of checking Group Policies (GPOs) in an Active Directory domain for specific settings related to an input string. The script retrieves a list of all GPOs and examines their reports to identify if the specified string is present, allowing system administrators to quickly determine if certain policies are applied.

## Table of Contents

- [Prerequisites](#prerequisites)

- [Usage](#usage)

- [Configuration](#configuration)

- [Logging](#logging)


## Prerequisites

Before running this script, ensure you have:

- Administrative privileges in the Active Directory environment.

- The `ActiveDirectory` module installed and available in PowerShell.

- PowerShell version 5.1 or later.

## Usage

1\. **Clone the repository** (if applicable):

```bash
git clone https://github.com/yourusername/yourrepository.git

cd yourrepository
```

2\. **Run the script**:

   Open PowerShell as an administrator and navigate to the directory where the script is located. Execute the script with the following command:

```powershell
.\SearchForTextInGPOs.ps1
```

3\. **Review the results**:

   The script will output results directly to the console and log the details in a transcript file located at `C:\Temp\SearchForTextInGPOs.txt`. Ensure the path is writable or modify it as needed.

## Configuration

The script searches for the string **"Point and Print Restrictions"** within the GPO reports in the specified Active Directory domain. This can be modified in the script by changing the value assigned to the `$String` variable.

## Logging

The script logs its activities and results to a transcript file (`C:\Temp\SearchForTextInGPOs.txt`). Make sure that the directory exists and is writable, or adjust the log file path in the script if necessary.
