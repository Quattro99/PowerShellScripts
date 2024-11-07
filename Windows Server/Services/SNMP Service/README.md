# SNMP Service Installation Script

## Overview

This PowerShell script automates the installation of the SNMP (Simple Network Management Protocol) Service on Windows Server. It checks if the SNMP Service is already installed and, if not, proceeds to install it along with all its components. The script also refreshes Group Policy settings to apply any configurations automatically.

## Table of Contents

- [Prerequisites](#prerequisites)

- [Usage](#usage)

- [Configuration](#configuration)

- [Logging](#logging)


## Prerequisites

Before using this script, ensure you have:

- Administrative privileges on the Windows Server where the script will be executed.

- PowerShell version 5.1 or later installed on the system.

## Usage

1\. **Clone the repository** (if using version control):

```bash
git clone https://github.com/Quattro99/PowerShellScripts.git

cd PowerShellScripts
```

2\. **Run the script**:

   Open PowerShell as an administrator and navigate to the directory containing the script. Then execute:

```powershell
.\SNMP_Service_Install.ps1
```

3\. **Automation**:

   This script can be scheduled to run at regular intervals using Task Scheduler or can be incorporated into GPO for automatic execution across multiple servers.

## Configuration

The script will automatically configure the SNMP Service using Group Policies. Ensure that the necessary GPOs are properly set up in your environment for SNMP configuration.

## Logging

The installation process is logged to a transcript file located in `C:\Temp\SNMP_Service_Install_Transcript.txt`. Make sure that the path `C:\Temp` exists and is writable, or change the path in the script to a suitable location.
