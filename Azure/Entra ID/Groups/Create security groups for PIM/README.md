# Create Security Groups for PIM and some for permanent assignment

## Overview

The `CreateSecurityGroupsForPIMandPermanentAssigned.ps1` script automates the creation and assignment of security groups and associated roles in Microsoft Graph. This script is designed to optimize the management of Privileged Identity Management (PIM) and permanent role assignments with minimal manual effort.

## Prerequisites

- Microsoft Graph PowerShell SDK installed on your system.
- Appropriate permissions to modify groups and roles in Microsoft Graph.
- PowerShell 5.1 or later.

## Input Files

The script requires the following input files located in the same directory as the script:

1. **PIMGroups.csv**
   - Contains information for the groups to be created for PIM.
   - Structure:
     - **DisplayName**: Name of the group.
     - **Description**: Description of the group.
     - **Nickname**: Mail nickname for the group.
     - **RoleDefinitionId**: The ID of the role to be assigned to the group for PIM (added as an additional field).

2. **PAGroups.csv**
   - Contains information for the groups to be created for permanent assignments.
   - Structure:
     - **DisplayName**: Name of the group.
     - **Description**: Description of the group.
     - **Nickname**: Mail nickname for the group.
     - **RoleDefinitionId**: The ID of the role to be assigned to the group for permanent assignments (added as an additional field).

3. **PIMUserId.txt**
   - A text file containing the user IDs for users to be added to the PIM groups. Each user ID should be on a new line.

4. **PAUserId.txt**
   - A text file containing the user IDs for users to be added to the permanent assigned groups. Each user ID should be on a new line.

## How to Use

1. **Edit the Input Files**:
   - Open `PIMGroups.csv` and `PAGroups.csv` in a spreadsheet application or text editor and fill in the required fields.
   - Update the `PIMUserId.txt` and `PAUserId.txt` with the relevant user IDs.

2. **Save the Files**:
   - Ensure that the files are saved in the correct format (CSV files in UTF-8 format).

3. **Run the Script**:
   - Open PowerShell and navigate to the directory where the script is located.
   - Execute the script:
     ```powershell
     .\CreateSecurityGroupsForPIMandPermanentAssigned.ps1
     ```

4. **Follow Prompts**:
   - The script will prompt you for the paths of the input files and the IDs of the group owners. Provide the required information as requested.

5. **Review Results**:
   - The script will log actions in the specified log file, including the creation of groups and role assignments.
   - Check the log file to verify successful operations and troubleshoot any errors.

## Notes

- This script is intended for use by administrators with appropriate permissions in Entra ID (Azure Active Directory).
- Make sure to adjust the `$LogPath` variable in the script to specify the desired location for logging.

## Author

- **Michele Blum**
- Created on: 23.03.2024

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.