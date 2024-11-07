# Virtual Machine Power On / Off Role

## Overview

This JSON configuration defines a custom role for Azure, titled "Virtual Machine Power On / Off". The role is designed to provide specific permissions that allow the assigned users or services to manage the power state of Virtual Machines within a specified Azure subscription.

## Description

The "Virtual Machine Power On / Off" role grants the ability to view, start, restart, stop, and deallocate Virtual Machines. This role is particularly useful for managing the resources efficiently and ensuring that VMs are not running when not needed, thus potentially reducing costs.

## Permissions

The role includes the following permissions:

- **Read Operations:**
  - `Microsoft.Resources/subscriptions/resourceGroups/read`
  - `Microsoft.Compute/virtualMachines/read`

- **Write Operations:**
  - `Microsoft.Compute/virtualMachines/start/action`
  - `Microsoft.Compute/virtualMachines/restart/action`
  - `Microsoft.Compute/virtualMachines/powerOff/action`
  - `Microsoft.Compute/virtualMachines/deallocate/action`

These permissions ensure that the role has the necessary rights to manage the power state of VMs without granting unnecessary broader access to the Azure environment.

## Assignable Scopes

The role can be assigned at the following scopes:

- `/subscriptions/XXXX`

Replace `XXXX` with the actual subscription ID where you want to apply this role.

## Usage

To use this role, you will need to create it in Azure using the Azure CLI, PowerShell, or through the Azure portal. Once created, you can assign it to users, groups, or service principals that require the ability to manage VM power states.

### Creating the Role

You can create this role using the Azure CLI with the following command:

```bash
az role definition create --role-definition path/to/your/role-definition.json