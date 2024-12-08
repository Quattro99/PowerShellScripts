# Key Vault Backup Operator

## Overview

This document provides details about the *Key Vault Backup Operator* designed for use within Azure. This role allows Azure Backup service to interact with Azure Key Vault by managing keys and secrets necessary for performing backup operations in a secure manner.

## Role Details

- **Role Name**: Key Vault Backup Role
- **Description**: This role permits users to get, list, and back up keys and secrets stored in Azure Key Vault specifically for Azure Backup processes.

## Assignable Scopes

This role can be assigned at the following scope:

- **Subscription ID**: `/subscriptions/XXX`

*(Replace `XXX` with your actual Subscription ID)*

## Permissions

This role grants specific permissions that allow controlled access to Azure Key Vault resources:

### Actions

- **Allowed Actions**:
  - `Microsoft.KeyVault/vaults/secrets/read`: Grants read access to secrets in the Key Vault.

### Data Actions

- **Allowed Data Actions**:
  - `Microsoft.KeyVault/vaults/keys/read`: Grants read access to keys in the Key Vault.
  - `Microsoft.KeyVault/vaults/secrets/backup/action`: Grants permission to back up secrets in the Key Vault.
  - `Microsoft.KeyVault/vaults/secrets/restore/action`: Grants permission to restore secrets in the Key Vault.
  
*(Note: The `backup/action` is repeated, consider removing the duplicate if it's unintentional.)*

### Not Allowed Actions

- **Not Actions**: None specified.
- **Not Data Actions**: None specified.

## Usage

This role is intended to be assigned to Azure Backup services or users requiring access to perform backup tasks using the Azure Key Vault. To assign this role, use Azure PowerShell, Azure CLI, or the Azure Portal.

### Example of Role Assignment using Azure CLI

```bash
az role assignment create --assignee <assignee-principal-id> --role "Key Vault Backup Operator" --scope "/subscriptions/XXX"