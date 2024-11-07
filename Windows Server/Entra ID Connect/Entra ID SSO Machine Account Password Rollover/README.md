# Entra ID SSO Account Password Rollover Script

## Overview

This PowerShell script automates the password rollover process for the Entra ID SSO account (`AZUREADSSOACC`) in an on-premises Active Directory environment. It includes authentication to Entra ID, updates the SSO account, and checks the current status of the SSO configuration.

## Table of Contents

- [Prerequisites](#prerequisites)

- [Usage](#usage)

- [Configuration](#configuration)

- [Logging](#logging)


## Prerequisites

Before executing this script, ensure you have:

- Administrative privileges in your Active Directory environment.

- `Microsoft Azure Active Directory Connect` installed.

- The `AzureADSSO` module available on your system.

- Access to the domain administrator credentials for the associated domain.

## Usage

1\. **Clone the repository** (if applicable):

```bash
git clone https://github.com/yourusername/yourrepository.git

cd yourrepository
```

2\. **Run the script**:

   Open PowerShell as an administrator, navigate to the directory containing the script, and execute the script as follows:

```powershell
.\AZUREADSSOACC_pwd_rollover.ps1
```

3\. **Follow the prompts** for domain admin credentials when updating the SSO account.

## Configuration

The script is designed to connect to the Entra ID and update the SSO account. Ensure that the `C:\Program Files\Microsoft Azure Active Directory Connect\` directory is correct and that the `AzureADSSO.psd1` module is present in that directory.

## Logging

The script logs its progress and results to a transcript file located at `C:\Temp\AZUREADSSOACC_pwd_rollover_Transcript.txt`. Ensure the specified path is writable, or adjust the path in the script if needed.
