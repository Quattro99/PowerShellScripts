<#
.Synopsis
    This script automates the creation and assignment of groups and roles in Microsoft Graph.
.DESCRIPTION
    The script installs and imports necessary PowerShell modules, reads group and user data from CSV and TXT files, 
    creates groups, assigns users to these groups, and assigns roles to the groups.
.INPUTS
    None
.OUTPUTS
    None
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
    Automates group and role management in Microsoft Graph.
#>

#----- Local variables -----#
# Name of the PowerShell module to install & import
$module = "Microsoft.Graph", "Microsoft.Graph.Beta"

# Required MS Graph scope
$RequiredScopes = @("Group.ReadWrite.All", "GroupMember.ReadWrite.All", "User.ReadWrite.All", "RoleManagement.ReadWrite.Directory")

# Define the location of the .csv and .txt files
$CSVFilePathPIMGroups   = Read-Host -Prompt "Enter the path of your .csv-file with all groups for PIM"
$CSVFilePathDAGroups    = Read-Host -Prompt "Enter the path of your .csv-file with all groups for permanent assigned Entra ID role assignments"
$TXTFilePathPIMUserId   = Read-Host -Prompt "Enter the path of your .txt-file with all user id's who should be added to the PIM groups"
$TXTFilePathDAUserId    = Read-Host -Prompt "Enter the path of your .txt-file with all user id's who should be added to the permanent assigned Entra ID role groups"
$PIMOwnerId             = Read-Host -Prompt "Enter the ID of the PIM assigned Entra ID role groups owner"
$PAOwnerId              = Read-Host -Prompt "Enter the ID of the permanent assigned Entra ID role groups owner"

# Import data from CSV and TXT files
$tocreatePIMgroups      = Import-Csv -Path $CSVFilePathPIMGroups
$tocreateDAGroups       = Import-Csv -Path $CSVFilePathDAGroups
$PIMUserIds             = Get-Content -Path $TXTFilePathPIMUserId
$DAUserIds              = Get-Content -Path $TXTFilePathDAUserId

#----- Main function -----#
function main {
    # Connect to Microsoft Graph
    mggraph
    # Create PIM groups
    pimgroups
    # Create DA groups
    dagroups
    # Assign roles to the created groups
    roleassignment
    # Disconnect from Microsoft Graph
    Disconnect-MgGraph -Verbose
}

#----- MS Graph connection function -----#
function mggraph {
    # Check if the PowerShell module is installed on the local computer
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Microsoft.Graph not installed. Module will be installed."
        Install-Module $module -Scope CurrentUser -Force
    } else {
        Write-Host "Microsoft.Graph Module already installed."
    }

    # Import the module
    Import-Module $module

    # Connect to the tenant with the appropriate graph permissions
    Connect-MgGraph -Scopes $RequiredScopes -ContextScope Process
}

#----- PIM groups creation function -----#
function pimgroups {
    $global:createdPIMgroups = foreach ($tocreatePIMgroup in $tocreatePIMgroups) {
        $PIMgroupparams = @{
            displayname         = $tocreatePIMgroup.displayname
            description         = $tocreatePIMgroup.description
            mailenabled         = $false
            securityenabled     = $true
            mailnickname        = $tocreatePIMgroup.nickname
            isAssignableToRole  = $true
            "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($PIMOwnerId)")
        }

        # Initialize the members array
        $PIMgroupmembers = @()
        foreach ($PIMUserId in $PIMUserIds) {
            $PIMgroupmembers += "https://graph.microsoft.com/v1.0/users/$($PIMUserId)"
        }
        $PIMgroupparams["members@odata.bind"] = $PIMgroupmembers

        New-MgGroup -BodyParameter $PIMgroupparams
    }
}

#----- DA groups creation function -----#
function dagroups {
    $global:createdDAgroups = foreach ($tocreateDAgroup in $tocreateDAGroups) {
        $DAgroupparams = @{
            displayname         = $tocreateDAgroup.displayname
            description         = $tocreateDAgroup.description
            mailenabled         = $false
            securityenabled     = $true
            mailnickname        = $tocreateDAgroup.nickname
            isAssignableToRole  = $true
            "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($PAOwnerId)")
        }

        # Initialize the members array
        $DAgroupmembers = @()
        foreach ($DAUserId in $DAUserIds) {
            $DAgroupmembers += "https://graph.microsoft.com/v1.0/users/$($DAUserId)"
        }
        $DAgroupparams["members@odata.bind"] = $DAgroupmembers

        New-MgGroup -BodyParameter $DAgroupparams
    }
}

#----- Role assignment function -----#
function roleassignment {
    foreach ($createdPIMgroup in $createdPIMgroups) {
        $matchingPIMGroup = $tocreatePIMgroups | Where-Object { $_.displayname -eq $createdPIMgroup.displayname }
        if ($matchingPIMGroup) {
            $pimroleassignmentparams = @{
                Action = "AdminAssign"
                RoleDefinitionId = $matchingPIMGroup.RoleDefinitionId
                PrincipalId = $createdPIMgroup.id
                DirectoryScopeId = "/" # The scope at which the role is being assigned
                ScheduleInfo = @{
                    StartDateTime = (Get-Date).ToString("o") # Start time in ISO 8601 format
                    Expiration = @{
                        Type = "NoExpiration" # Or "AfterDateTime" with an ExpirationDateTime
                    }
                }
            }
            New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $pimroleassignmentparams
        }
    }

    foreach ($createdDAgroup in $createdDAgroups) {
        $matchingDAGroup = $tocreateDAGroups | Where-Object { $_.displayname -eq $createdDAgroup.displayname }
        $permanentroleassignmentparams = @{
            roleDefinitionId = "$($matchingDAGroup.RoleDefinitionId)"
            principalId = "$($createdDAgroup.id)"
            directoryScopeId = "/"
        }
        New-MgBetaRoleManagementDirectoryRoleAssignment -BodyParameter $permanentroleassignmentparams
    }
}

#----- Logging function -----#
# Call local information of the runtime script
$prefix = $MyInvocation.MyCommand.Name
Start-Transcript -Path $LogPath -Append
$elapsed = (Get-Date) - $start
$runtimesec = $elapsed.TotalSeconds

#----- Entry point -----#
$start = $null
$start = Get-Date
main