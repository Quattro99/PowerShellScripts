# PowerShell Scripts

## Overview

This repository contains a collection of PowerShell scripts designed to automate various tasks and enhance productivity. The scripts cover a wide range of functionalities, including system administration, task automation, and configuration management, making it easier for users to manage their Windows environments.

## Table of Contents

- [Prerequisites](#prerequisites)

- [Getting Started](#getting-started)

- [Usage](#usage)

- [Contributing](#contributing)

- [License](#license)

## Prerequisites

Before using the scripts in this repository, ensure you have the following installed:

- [Windows PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

- Appropriate permissions to run scripts on your system.

## Getting Started

1\. **Clone the Repository**:

   Clone this repository to your local machine by running:

```bash
git clone https://github.com/Quattro99/PowerShellScripts.git

cd PowerShellScripts
```

2\. **Set Execution Policy** (if necessary):

   You may need to adjust the execution policy to run the scripts:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Usage

To use any of the scripts in this repository, open a PowerShell prompt and navigate to the directory containing the desired script. You can execute a script by running:

```powershell
.\script-name.ps1
```

Replace `script-name.ps1` with the actual script file name.

### Example

For example, to run a script named `ExampleScript.ps1`, you would execute:

```powershell
.\ExampleScript.ps1
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
