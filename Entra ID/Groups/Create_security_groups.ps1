<#
.Synopsis
.DESCRIPTION
.INPUTS
.OUTPUTS
.NOTES
   ===========================================================================
	 Created on:   	23.03.2024
	 Created by:   	Michele Blum
	 Filename:     	
	===========================================================================
.COMPONENT
.ROLE
.FUNCTIONALITY
#>

#----- Local variables -----#
# Name of the PowerShell module to install & import
$module = "Microsoft.Graph", "Microsoft.Graph.Beta"

# Required MS Graph scope
$RequiredScopes = @("Group.ReadWrite.All", "GroupMember.ReadWrite.All", "User.ReadWrite.All", "RoleManagement.ReadWrite.Directory")

# Define the location of the .csv-file where the names of all groups are stored
$CSVFilePathGroups  = Read-Host -Prompt "Enter the path of your .csv-file with all group names"
$OwnerId      = Read-Host -Prompt "Enter the ID of the owner"
$CSVFilePathUserId       = Read-Host -Prompt "Enter the path of your .csv-file with all user id's who should be added to the group"
$tocreategroups = Import-Csv -Path $CSVFilePathGroups
$UserIds = Import-Csv -Path $CSVFilePathUserId

#----- main-function -----#
function main () {
	mggraph
	mggroup
  roleassignment
  Disconnect-MgGraph -Verbose
}


#----- msgraph-function -----#
function mggraph {
  # Check if the PowerShell module is installed on the local computer
  if (-not (Get-Module -ListAvailable -Name $module)) {

    Write-Host "Microsoft.Graph not installed. Module will be installed."

    # Install the module, if not installed, to the scope of the currentuser
    Install-Module $module -Scope CurrentUser -Force

    # Import the module
    Import-Module $module
  }

  else {

    Write-Host "Microsoft.Graph Module already installed."

    # Import the module
    Import-Module $module
  }

    # Connect to the tenant with the appropriate graph permissions (enterprise application registration eq. service principal)
	Connect-MgGraph -Scopes $RequiredScopes -ContextScope Process

}

#----- mggroup-function -----#
function mggroup {
  foreach ($tocreategroup in $tocreategroups) {
    $groupparams = @{
      displayname     		= $tocreategroups.displayname
      description     		= $tocreategroups.description
      mailenabled     		= $false
      securityenabled 		= $true
      mailnickname    		= $tocreategroups.nickname
      isAssignableToRole 	= $true
      "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($OwnerId)")
    }
      # Initialize the members array
      $members = @()

      # Loop through each user ID and add to the members array
      foreach ($UserId in $UserIds) {
        $members += "https://graph.microsoft.com/v1.0/users/$($UserId)"
      }

      # Add the members array to the group parameters
      $groupparams["members@odata.bind"] = $members
     
    $global:createdgroups = New-MgGroup -BodyParameter $groupparams
    }

  }

  function roleassignment {
    if ($tocreategroups.displayname -contains "*PIM*") {
    foreach ($createdgroup in $createdgroups) {
    $pimroleassignmentparams = @{
      Action = "AdminAssign"
      RoleDefinitionId = $tocreategroup.RoleDefinitionId
      PrincipalId = $createdgroup.id
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
    else {
      foreach ($createdgroup in $createdgroups) {
        $permanentroleassignmentparams = @{
          "@odata.type" = "#microsoft.graph.unifiedRoleAssignment"
          roleDefinitionId = "$($tocreategroups.RoleDefinitionId)"
          principalId = "$($createdgroup.id)"
          directoryScopeId = "/"
        }
    
        New-MgBetaRoleManagementDirectoryRoleDefinition -BodyParameter $permanentroleassignmentparams
        }
    }
  }

#----- logging-function -----#
# Call local inforamtion of the runtime script
$prefix = $MyInvocation.MyCommand.Name
Start-Transcript -Path $LogPath -Append
$elapsed = (Get-Date) - $start
$runtimesec = $elapsed.TotalSeconds


#----- Entry point -----#
$start = $null
$start = Get-Date
main