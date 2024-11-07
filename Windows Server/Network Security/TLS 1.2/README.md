# Enable TLS 1.2 on Windows Server

## Overview

This PowerShell script enables the TLS 1.2 protocol on Windows Server by modifying the necessary registry settings. It configures the .NET Framework, WinHttp settings, and SCHANNEL to ensure that the server supports and prioritizes the TLS 1.2 protocol for secure communications.

## Table of Contents

- [Prerequisites](#prerequisites)

- [Usage](#usage)

- [Configuration](#configuration)

- [Logging](#logging)

- [References](#references)

## Prerequisites

Before running this script, ensure you have:

- Administrative privileges on the Windows Server where the script will be executed.

- PowerShell version 5.1 or later installed on the system.

## Usage

1\. **Clone the repository** (if applicable):

```bash
git clone https://github.com/Quattro99/PowerShellScripts.git

cd PowerShellScripts
```

2\. **Run the script**:

   Open PowerShell as an administrator and navigate to the directory containing the script. Execute the script using the following command:

```powershell
.\Enable_TLS_1.2_WinSrv2019.ps1
```

## Configuration

This script modifies the following registry settings to enable TLS 1.2:

- **.NET Framework**: Configures the `SchUseStrongCrypto` property to use strong cryptography.

- **WinHttp Settings**: Updates the secure protocol settings to enable TLS 1.2.

- **SCHANNEL**: Creates necessary registry entries to enable and configure TLS 1.2 for both client and server.

After running the script, TLS 1.2 will be activated without requiring any further input.

## Logging

The script logs its activities to a transcript file located at `C:\Temp\Enable_TLS_1_2_Install_Transcript.txt`. Ensure that the specified path exists and is writable, or modify the path in the script to a suitable location if necessary.

## References

- [How to Enable TLS 1.2 on Windows Server](https://thesecmaster.com/how-to-enable-tls-1-2-and-tls-1-3-on-windows-server/)

- [Microsoft Documentation on Secure Protocols](https://docs.microsoft.com/en-us/dotnet/framework/networking/security/)
