# Intune Application Management Script

## Overview

This PowerShell script is designed to handle the installation and uninstallation of applications within an Intune environment. It leverages both the Windows Installer (MSI) and executable (EXE) methods, ensuring that the actions are logged for troubleshooting purposes.

## Features

- Supports installation and uninstallation of applications.

- Uses MSI and EXE installation methods.

- Logs actions and outputs for debugging and troubleshooting.

- Implements error handling with relevant exit codes.

## Requirements

- PowerShell 5.1 or higher.

- Execution policy set to allow the script to run.

- Appropriate permissions to install/uninstall applications on target machines.

## Usage

To run the script, open a PowerShell prompt with administrative privileges and execute the following command:

```powershell
.\Default_Win32_App.ps1 [-Remove]
```

### Parameters

- `-Remove`: Optional switch to indicate that the application should be uninstalled instead of installed.

### Exit Codes

- `0` = Success

- `1` = Error or failure

## Installation and Uninstallation Examples

### Installing an Application

Modify the script to specify the path to the application executable and any necessary arguments. For example:

```powershell
$Application = "C:\Path\To\App.exe"

$Argument = "/quiet /install"
```

### Uninstalling an Application

To configure the script for uninstallation, set the correct executable and arguments in the script:

```powershell
$Application = "C:\Path\To\App.exe"

$Argument = "/quiet /uninstall"
```

## Logging

The script automatically logs to a file located in the following directory:

```
%ProgramData%\Microsoft\IntuneManagementExtension\Logs
```

The log file will be named based on the script name and timestamp, allowing for easy identification.

## Error Handling

The script includes error handling that logs any errors encountered during installation or uninstallation processes. This can assist in troubleshooting issues related to application management.
