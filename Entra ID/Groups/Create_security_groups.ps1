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
$module = "Microsoft.Graph"

# Required MS Graph scope
$RequiredScopes = @("Group.ReadWrite.All", "GroupMember.ReadWrite.All", "User.ReadWrite.All", "RoleManagement.ReadWrite.Directory")

# Define the location of the .csv-file where the names of all groups are stored
$CSVFilePath  = Read-Host -Prompt "Enter the path of your .csv-file with all group names"

$groups = Import-Csv -Path $CSVFilePath

#----- main-function -----#
function main () {
	mggraph
	mggroup
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
  foreach ($group in $groups) {
    $groupparam = @{
      displayname     		= $group.displayname
      description     		= $group.description
      mailenabled     		= $false
      securityenabled 		= $true
      mailnickname    		= $group.nickname
      IsAssignableToRole 	= $true
      #owners          		= "$group.owners"
      #members         		= "$group.members"
    }
     
    New-MgGroup @groupparam
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
