<#
.SYNOPSIS
    This script automates the creation of security groups  in Microsoft Graph.

.DESCRIPTION
    The script installs and imports the necessary PowerShell modules, reads groups from a CSV file and creates security groups.

.INPUTS
    None. User inputs are prompted for file paths and owner IDs when the script runs.

.OUTPUTS
    None. The script produces groups in Microsoft Graph as a side effect.

.NOTES
   ===========================================================================
    Created on:    20.02.2025
    Created by:    Michele Blum
    Filename:      BulkCreateSecurityGroupsCAP.ps1
   ===========================================================================
.COMPONENT
    Microsoft Graph

.ROLE
    Group Management

.FUNCTIONALITY
    Automates group management in Microsoft Graph, specifically for CAP groups.
#>

#----- Local variables -----#
# Names of the PowerShell modules to install & import
$modules = @("Microsoft.Graph", "Microsoft.Graph.Beta")

# Required MS Graph scopes
$RequiredScopes = @("Group.ReadWrite.All")

# Log file path
$LogPath = "C:\PATH\to\logfile.txt"  # Update this path as needed

# Prompt user for the paths of the required CSV and TXT files
$CAPGroupsCSV           = Read-Host -Prompt "Enter the path of your .csv-file with all groups for CAP"
$CAPGroupsOwnerId       = Read-Host -Prompt "Enter the ID of the PIM assigned Entra ID role groups owner"

# Import data from CSV and TXT files
$CAPGroupsToCreate      = Import-Csv -Path $CAPGroupsCSV

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
    capgroups
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
function capgroups {
    $global:CAPGroupsCreated = foreach ($CAPGroupToCreate in $CAPGroupsToCreate) {
        $CAPGroupParams = @{
            displayname         = $CAPGroupToCreate.displayname
            description         = $CAPGroupToCreate.description
            mailenabled         = $false
            securityenabled     = $true
            mailnickname        = $CAPGroupToCreate.nickname
            isAssignableToRole  = $true
            "owners@odata.bind" = @("https://graph.microsoft.com/v1.0/users/$($CAPGroupsOwnerId)")
        }

        # Create the group in Microsoft Graph
        New-MgGroup -BodyParameter $CAPGroupParams

        # Log the creation of the group
        Write-Host "Created CAP Group: $($CAPGroupParams.displayname)"
    }
}
