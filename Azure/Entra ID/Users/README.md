# Bulk Create Users for Azure Entra ID

## Overview

This document describes the format and usage of the `bulk_create_users.csv` file used to create multiple users in Azure Entra ID (Azure Active Directory) through the bulk action feature. This allows administrators to efficiently onboard users by specifying their details in a CSV format.

## File Structure

The CSV file must adhere to the following structure:

| Field Name       | Description                                           | Required |
|------------------|-------------------------------------------------------|----------|
| displayName      | The name displayed for the user (e.g., "Chris Green").           | Yes      |
| userPrincipalName| The user's email address or User Principal Name (UPN) (e.g., "chris@contoso.com").  | Yes      |
| passwordProfile   | The initial password for the user (e.g., "myPassword1234"). | Yes      |
| accountEnabled    | Specify if the user account should be enabled or blocked (e.g., "Yes" or "No").  | Yes      |

### Example Entry

Here is an example of a valid entry in the `bulk_create_users.csv` file:

```
Chris Green, chris@contoso.com, myPassword1234, No
```

## How to Use

1\. **Edit the CSV File**: Open the `bulk_create_users.csv` file with a text editor or spreadsheet application (like Excel) and enter the relevant user details following the specified structure.

2\. **Save the File**: Ensure the file is saved in UTF-8 format and retains the `.csv` extension.

3\. **Upload to Azure Entra ID**:

   - Go to the Azure portal and navigate to Azure Entra ID.

   - Select **Users** > **Bulk operations** > **Bulk create**.

   - Upload the CSV file to initiate the user creation process.

4\. **Review the Results**: After processing, review any errors or confirmation messages to ensure users were created successfully.

## Important Notes

- Ensure that passwords adhere to your organization's password policy.

- If blocking sign-in is set to "Yes," users will not be able to sign in until enabled.
