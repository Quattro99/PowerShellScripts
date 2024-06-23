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
$CSVFilePathPIMGroups   = Read-Host -Prompt "Enter the path of your .csv-file with all groups for PIM"
$CSVFilePathDAGroups    = Read-Host -Prompt "Enter the path of your .csv-file with all groups for permanent assigned Entra ID role assignments"
$TXTFilePathPIMUserId   = Read-Host -Prompt "Enter the path of your .txt-file with all user id's who should be added to the PIM groups"
$TXTFilePathDAUserId    = Read-Host -Prompt "Enter the path of your .txt-file with all user id's who should be added to the permanent assigned Entra ID role groups"
$PIMOwnerId             = Read-Host -Prompt "Enter the ID of the PIM groups owner"
$DAOwnerId              = Read-Host -Prompt "Enter the ID of the permanent assigned Entra ID role groups owner"
$tocreatePIMgroups      = Import-Csv -Path $CSVFilePathPIMGroups
$tocreateDAGroups       = Import-Csv -Path $CSVFilePathDAGroups
$PIMUserIds             = Get-Content -Path $TXTFilePathPIMUserId
$DAUserIds              = Get-Content -Path $TXTFilePathDAUserId

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

#----- pimgroups-function -----#
function pimgroups {
  $global:createdPIMgroups = foreach ($tocreatePIMgroup in $tocreatePIMgroups) {
    $PIMgroupparams = @{
      displayname     		= $tocreatePIMgroup.displayname
      description     		= $tocreatePIMgroup.description
      mailenabled     		= $false
      securityenabled 		= $true
      mailnickname    		= $tocreatePIMgroup.nickname
      isAssignableToRole 	= $true
      "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($PIMOwnerId)")
      
    }
      # Initialize the members array
      $PIMgroupmembers = @()

      # Loop through each user ID and add to the members array
      foreach ($PIMUserId in $PIMUserIds) {
        $PIMgroupmembers += "https://graph.microsoft.com/v1.0/users/$($PIMUserId)"
      }

      # Add the members array to the group parameters
      $PIMgroupparams["members@odata.bind"] = $pimgroupmembers
     
    New-MgGroup -BodyParameter $PIMgroupparams
    }

}

function dagroups {
  $global:createdDAgroups = foreach ($tocreateDAgroup in $tocreateDAgroups) {
    $DAgroupparams = @{
      displayname     		= $tocreateDAgroup.displayname
      description     		= $tocreateDAgroup.description
      mailenabled     		= $false
      securityenabled 		= $true
      mailnickname    		= $tocreateDAgroup.nickname
      isAssignableToRole 	= $true
      "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($DAOwnerId)")
          
    }
    
    # Initialize the members array
    $DAgroupmembers = @()

    # Loop through each user ID and add to the members array
    foreach ($DAUserId in $DAUserIds) {
      $DAgroupmembers += "https://graph.microsoft.com/v1.0/users/$($DAUserId)"
    }

    # Add the members array to the group parameters
    $DAgroupparams["members@odata.bind"] = $DAgroupmembers
    
    New-MgGroup -BodyParameter $DAgroupparams
    }
  }

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