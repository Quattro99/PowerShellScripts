# Set Language to German (Switzerland) Script

## Overview

This PowerShell script configures the system locale, time zone, and language settings for a Windows machine to German (Switzerland) (de-CH). It adjusts the necessary region settings and ensures that all relevant user and system settings are applied appropriately.

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

2\. **Download the XML Configuration**: Ensure that the `CHRegion.xml` file (provided in your script or as a separate file) is located in the same directory as the script.

3\. **Run the script**:

   Open PowerShell as an administrator and execute the script with:

```powershell
.\Set-Language_to_de-ch.ps1
```

4\. **Review the results**: The script will output the progress of the adjustments being made to the language and locale settings.

## Configuration

- The script sets the following configurations:

  - User locale: **de-CH**

  - System locale: **de-CH**

  - Time zone: **W. Europe Standard Time**

You may modify the XML or parameters in the script to suit your needs if you require different settings.

## Logging

The script logs its actions and results to a transcript file located at `C:\Temp\Set-Language_to_de-ch_Transcript.txt`. Ensure the specified path is writable, or adjust the logging path in the script as necessary.
