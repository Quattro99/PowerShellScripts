# PowerShell Scripts for Active Directory Security

## Overview

This repository contains a collection of PowerShell scripts designed to enhance security and management of Active Directory (AD) environments. The scripts focus on various aspects of security administration, making it easier for system administrators to automate tasks and enforce policies within their Windows Server Active Directory infrastructure.

## Table of Contents

- [Prerequisites](#prerequisites)

- [Scripts Overview](#scripts-overview)

- [Usage](#usage)

- [Configuration](#configuration)

- [Logging](#logging)

## Prerequisites

Before executing the scripts in this directory, ensure you have:

- Administrative privileges in your Active Directory environment.

- PowerShell 5.1 or later installed.

- The `Active Directory` module available in PowerShell.

## Scripts Overview

This folder contains the following scripts:

- **[Invoke_ADAccountCheck.ps1](Invoke_ADAccountCheck.ps1)**: Performs a comprehensive check on Active Directory accounts. It identifies accounts with empty passwords, inactive users, unused accounts, and outdated passwords based on specified criteria.

- **[Get_PW_LastSet.ps1](Get_PW_LastSet.ps1)**: Retrieves a list of enabled users in Active Directory along with their password last set dates, helping administrators assess password policies.

- **[Check_old_OS.ps1](Check_old_OS.ps1)**: Identifies computers in Active Directory running outdated operating systems, specifically Windows 7, which helps to maintain compliance and security in the environment.

- **[Check_AccountNotDelegated.ps1](Check_AccountNotDelegated.ps1)**: Checks Active Directory users to see if they have the 'Account Not Delegated' property set. This can help identify users who may need this property updated for enhanced security.


## Usage

To use the scripts, follow these general instructions:

1\. **Clone the repository**:

```bash
git clone https://github.com/Quattro99/PowerShellScripts.git

cd PowerShellScripts/Windows Server/Active Directory/Security
```

2\. **Run a script**:

   Open PowerShell as an administrator and execute the script you need. For example:

```powershell
.\Check_AccountNotDelegated.ps1
```

3\. **Review the output**: Each script has specific output related to its functionality. Follow any prompts as necessary.

## Configuration

Each script may have configurable parameters. Review the script content to adjust parameters to fit your environment's needs.

## Logging

Most scripts log their activities to a specified transcript file. Ensure that the directory for logging exists and is writable or adjust the logging path in the scripts as needed.
