<#
.SYNOPSIS
    This script automates the creation and assignment of security groups and roles in Microsoft Graph.

.DESCRIPTION
    The script installs and imports the necessary PowerShell modules, reads group and user data from CSV and TXT files, 
    creates security groups, assigns users to these groups, and assigns roles to the groups in the context of 
    Privileged Identity Management (PIM) and permanent assignments.

.INPUTS
    None. User inputs are prompted for file paths and owner IDs when the script runs.

.OUTPUTS
    None. The script produces groups in Microsoft Graph as a side effect.

.NOTES
   ===========================================================================
    Created on:    23.03.2024
    Created by:    Michele Blum
    Filename:      CreateSecurityGroupsForPIMandPermanentAssigned.ps1
   ===========================================================================
.COMPONENT
    Microsoft Graph

.ROLE
    Group and Role Management

.FUNCTIONALITY
    Automates group and role management in Microsoft Graph, specifically for Privileged Identity Management.
#>

#----- Local variables -----#
# Names of the PowerShell modules to install & import
$modules = @("Microsoft.Graph", "Microsoft.Graph.Beta")

# Required MS Graph scopes
$RequiredScopes = @("Group.ReadWrite.All", "GroupMember.ReadWrite.All", "User.ReadWrite.All", "RoleManagement.ReadWrite.Directory")

# Log file path
$LogPath = "C:\Path\To\Your\Log\logfile.txt"  # Update this path as needed

# Prompt user for the paths of the required CSV and TXT files
$PIMGroupsCSV           = Read-Host -Prompt "Enter the path of your .csv-file with all groups for PIM"
$PAGroupsCSV            = Read-Host -Prompt "Enter the path of your .csv-file with all groups for permanent assigned Entra ID role assignments"
$PIMUsersIdCSV          = Read-Host -Prompt "Enter the path of your .txt-file with all user IDs who should be added to the PIM Entra ID role groups"
$PAUsersIdCSV           = Read-Host -Prompt "Enter the path of your .txt-file with all user IDs who should be added to the permanent assigned Entra ID role groups"
$PIMGroupsOwnerId       = Read-Host -Prompt "Enter the ID of the PIM assigned Entra ID role groups owner"
$PAGroupsOwnerId        = Read-Host -Prompt "Enter the ID of the permanent assigned Entra ID role groups owner"

# Import data from CSV and TXT files
$PIMGroupsToCreate      = Import-Csv -Path $PIMGroupsCSV
$PAGroupsToCreate       = Import-Csv -Path $PAGroupsCSV
$PIMGroupsUserIds       = Get-Content -Path $PIMUsersIdCSV
$PAGroupsUserIds        = Get-Content -Path $PAUsersIdCSV

#----- Main function -----#
function main {
    # Start logging
    Start-Transcript -Path $LogPath -Append

    # Log the start time
    Write-Host "Script started at: $(Get-Date)"
    Write-Host "Log file: $LogPath"

    # Connect to Microsoft Graph
    mggraph
    # Create PIM groups
    pimgroups
    # Create permanent assigned groups
    pagroups
    # Assign roles to the created groups
    roleassignment
    # Disconnect from Microsoft Graph
    Disconnect-MgGraph -Verbose

    # Log the end time
    Write-Host "Script ended at: $(Get-Date)"
    
    # Calculate and log elapsed time
    $elapsed = (Get-Date) - $start
    Write-Host "Total runtime: $($elapsed.TotalSeconds) seconds"

    # Stop logging
    Stop-Transcript
}

#----- MS Graph connection function -----#
function mggraph {
    # Check if the required PowerShell modules are installed
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "$module not installed. Installing module."
            Install-Module $module -Scope CurrentUser -Force
        } else {
            Write-Host "$module Module already installed."
        }
    }

    # Import the modules
    Import-Module $modules

    # Connect to the tenant with the appropriate graph permissions
    Connect-MgGraph -Scopes $RequiredScopes -ContextScope Process
}

#----- PIM groups creation function -----#
function pimgroups {
    $global:PIMGroupsCreated = foreach ($PIMGroupToCreate in $PIMGroupsToCreate) {
        $PIMGroupParams = @{
            displayname         = $PIMGroupToCreate.displayname
            description         = $PIMGroupToCreate.description
            mailenabled         = $false
            securityenabled     = $true
            mailnickname        = $PIMGroupToCreate.nickname
            isAssignableToRole  = $true
            "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($PIMGroupsOwnerId)")
        }

        # Initialize the members array
        $PIMGroupMembers = @()
        foreach ($PIMGroupsUserId in $PIMGroupsUserIds) {
            $PIMGroupMembers += "https://graph.microsoft.com/v1.0/users/$PIMGroupsUserId"
        }
        $PIMGroupParams["members@odata.bind"] = $PIMGroupMembers

        # Create the group in Microsoft Graph
        New-MgGroup -BodyParameter $PIMGroupParams

        # Log the creation of the group
        Write-Host "Created PIM Group: $($PIMGroupParams.displayname)"
    }
}

#----- Permanent assigned groups creation function -----#
function pagroups {
    $global:PAGroupsCreated = foreach ($PAGroupToCreate in $PAGroupsToCreate) {
        $PAGroupParams = @{
            displayname         = $PAGroupToCreate.displayname
            description         = $PAGroupToCreate.description
            mailenabled         = $false
            securityenabled     = $true
            mailnickname        = $PAGroupToCreate.nickname
            isAssignableToRole  = $true
            "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($PAGroupsOwnerId)")
        }

        # Initialize the members array
        $PAGroupMembers = @()
        foreach ($PAGroupsUserId in $PAGroupsUserIds) {
            $PAGroupMembers += "https://graph.microsoft.com/v1.0/users/$PAGroupsUserId"
        }
        $PAGroupParams["members@odata.bind"] = $PAGroupMembers

        # Create the group in Microsoft Graph
        New-MgGroup -BodyParameter $PAGroupParams

        # Log the creation of the group
        Write-Host "Created Permanent Assigned Group: $($PAGroupParams.displayname)"
    }
}

#----- Role assignment function -----#
function roleassignment {
    # Assign roles for PIM groups
    foreach ($PIMGroupCreated in $PIMGroupsCreated) {
        $matchingPIMGroup = $PIMGroupsToCreate | Where-Object { $_.displayname -eq $PIMGroupCreated.displayname }
        if ($matchingPIMGroup) {
            $PIMRoleAssignmentParams = @{
                Action = "AdminAssign"
                RoleDefinitionId = $matchingPIMGroup.RoleDefinitionId
                PrincipalId = $PIMGroupCreated.id
                DirectoryScopeId = "/" # The scope at which the role is being assigned
                ScheduleInfo = @{
                    StartDateTime = (Get-Date).ToString("o") # Start time in ISO 8601 format
                    Expiration = @{
                        Type = "NoExpiration" # Or "AfterDateTime" with an ExpirationDateTime
                    }
                }
            }
            New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $PIMRoleAssignmentParams

            # Log the role assignment
            Write-Host "Assigned role to PIM Group: $($PIMGroupCreated.displayname)"
        }
    }

    # Assign roles for permanent assigned groups
    foreach ($PAGroupCreated in $PAGroupsCreated) {
        $matchingPAGroup = $PAGroupsToCreate | Where-Object { $_.displayname -eq $PAGroupCreated.displayname }
        if ($matchingPAGroup) {
            $PARoleAssignmentParams = @{
                roleDefinitionId = "$($matchingPAGroup.RoleDefinitionId)"
                principalId = "$($PAGroupCreated.id)"
                directoryScopeId = "/"
            }
            New-MgBetaRoleManagementDirectoryRoleAssignment -BodyParameter $PARoleAssignmentParams

            # Log the role assignment
            Write-Host "Assigned role to Permanent Assigned Group: $($PAGroupCreated.displayname)"
        }
    }
}

#----- Entry point -----#
$start = Get-Date
main
