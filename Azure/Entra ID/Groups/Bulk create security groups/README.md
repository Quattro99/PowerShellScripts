# Bulk Create Security Groups for Entra ID

## Overview

This document describes the format and usage of the `BulkCreateSecurityGroups.csv` file used to create multiple security groups in Entra ID through the bulk action feature. This allows administrators to efficiently onboard security groups by specifying their details in a CSV format.

## File Structure

The CSV file must adhere to the following structure:

| Field Name       | Description                                           | Required |
|------------------|-------------------------------------------------------|----------|
| DisplayName      | The name displayed for the security group (e.g., "Finance").           | Yes      |
| Description | A brief description of the security group (e.g., "This is the finance security group").  | No      |
| Nickname   | A nickname for the group. (e.g., "Finance"). | Yes      |
| Owners    | A comma-separated list of email addresses for users who will be owners of the group (e.g., "michele.blum@duo-infernale.ch").  | No      |
| Members    | A comma-separated list of email addresses for users who will be members of the group (e.g., "user1@contoso.com,user2@contoso.com").  | No      |

### Example Entry

Here is an example of a valid entry in the `BulkCreateSecurityGroups.csv` file:

```
Finance, This is the finance security group, Finance, michele.blum@duo-infernale.ch, michele.blum@duo-infernale.ch
```

## How to Use

1\. **Edit the CSV File**: Open the `BulkCreateSecurityGroups.csv` file with a text editor or spreadsheet application (like Excel) and enter the relevant security group details following the specified structure.

2\. **Save the File**: Ensure the file is saved in UTF-8 format and retains the `.csv` extension.

3\. **Upload to Entra ID**:

   - Go to the Azure portal and navigate to Entra ID.

   - Select **Groups** > **Bulk operations** > **Bulk create**.

   - Upload the CSV file to initiate the secuirty group creation process.

4\. **Review the Results**: After processing, review any errors or confirmation messages to ensure the security groups were created successfully.
