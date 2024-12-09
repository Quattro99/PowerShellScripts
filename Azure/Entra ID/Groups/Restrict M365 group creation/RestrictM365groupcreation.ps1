<#
.SYNOPSIS
    This script restricts the creation of Microsoft 365 groups by configuring directory settings.

.DESCRIPTION
    This PowerShell script connects to the Microsoft Graph API and modifies the directory settings to restrict group creation in a Microsoft 365 environment. 
    The script checks for the existing settings, creates default settings if they do not exist, and updates the group creation policy.

.INPUTS
    -GroupName: The display name of the group for which to control the creation permissions.
    -AllowGroupCreation: A Boolean value (string) indicating whether group creation is allowed; set to "True" or "False".

.OUTPUTS
    Outputs the current directory setting values after updates.

.NOTES
   ===========================================================================
	 Created on:   	09.12.2024
	 Created by:   	Michele Blum
	 Filename:     	RestrictM365groupcreation.ps1
	===========================================================================
.COMPONENT
    Microsoft Graph API

.ROLE
    Group Management

.FUNCTIONALITY
    Modify group creation permissions within a Microsoft 365 environment.
	
SOURCE: https://learn.microsoft.com/en-us/microsoft-365/solutions/manage-creation-of-groups?view=o365-worldwide
#>

# Import necessary modules from the Microsoft Graph Beta API for directory management and group operations
Import-Module Microsoft.Graph.Beta.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Beta.Groups

# Connect to Microsoft Graph with necessary permissions/scopes to read and write directory information
Connect-MgGraph -Scopes "Directory.ReadWrite.All", "Group.Read.All"

# Define the name of the group to restrict creation for and whether to allow creation
$GroupName = "xxx"
$AllowGroupCreation = "False"

# Retrieve the Object ID of the current Group Unified setting
$settingsObjectID = (Get-MgBetaDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id

# If no settings exist, create new directory settings with default values
if(!$settingsObjectID)
{
    # Parameters to create a new directory setting
    $params = @{
	  templateId = "62375ab9-6b52-47ed-826b-58e47e0e304b"
	  values = @(
		    @{
			       name = "EnableMSStandardBlockedWords"
			       value = "true"
		     }
	 	     )
	     }
	
    # Create the new directory setting
    New-MgBetaDirectorySetting -BodyParameter $params
	
    # Retrieve the Object ID of the newly created settings
    $settingsObjectID = (Get-MgBetaDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).Id
}

# Get the group ID for the specified group name to update its permissions
$groupId = (Get-MgBetaGroup | Where-object {$_.displayname -eq $GroupName}).Id

# Prepare parameters to update the group creation setting
$params = @{
	templateId = "62375ab9-6b52-47ed-826b-58e47e0e304b"
	values = @(
		@{
			name = "EnableGroupCreation"
			value = $AllowGroupCreation   # Set whether group creation is allowed
		}
		@{
			name = "GroupCreationAllowedGroupId"
			value = $groupId               # Set the group ID allowed to create groups
		}
	)
}

# Update the directory setting with the new group creation permissions
Update-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID -BodyParameter $params

# Output the current values of the directory setting to verify the changes
(Get-MgBetaDirectorySetting -DirectorySettingId $settingsObjectID).Values