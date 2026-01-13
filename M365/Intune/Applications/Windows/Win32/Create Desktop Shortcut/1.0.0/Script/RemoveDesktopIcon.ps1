<#
.SYNOPSIS
    Removes a shortcut from the Desktop and Start Menu based on the provided name.
.DESCRIPTION
    This script identifies whether it's running as SYSTEM or user mode, and then attempts to remove
    a shortcut with a specified display name from both the Desktop and Start Menu.
.INPUTS
    String - The display name of the shortcut to be removed.
.OUTPUTS
    None.
.NOTES
    ===========================================================================
    Created on:    13.01.2026
    Created by:    Michele Blum
    Filename:      RemoveDesktopIcon.ps1
    ===========================================================================
.COMPONENT
    Shortcut Removal
.ROLE
    Script to remove specified shortcuts from Desktop and Start Menu.
.FUNCTIONALITY
    Deletes a predefined shortcut from the user's Desktop and Start Menu.
#>

[CmdletBinding()]
Param (
   [Parameter(Mandatory=$true)]
   [String]$ShortcutDisplayName # The display name of the shortcut to remove
)

# Function to determine if the script is running as SYSTEM
function Test-RunningAsSystem {
   [CmdletBinding()]
   param()
   process{
       # Check the user SID to confirm SYSTEM privileges
       return ($(whoami -user) -match "S-1-5-18")
   }
}

# Function to get the correct desktop directory based on user privilege
function Get-DesktopDir {
   [CmdletBinding()]
   param()
   process{
       if (Test-RunningAsSystem){
           # Use the PUBLIC desktop path if running as SYSTEM
           $desktopDir = Join-Path -Path $env:PUBLIC -ChildPath "Desktop"
       } else {
           # Use the current user's desktop path
           $desktopDir = $([Environment]::GetFolderPath("Desktop"))
       }
       return $desktopDir
   }
}

# Function to get the correct Start Menu directory based on user privilege
function Get-StartDir {
   [CmdletBinding()]
   param()
   process{
       if (Test-RunningAsSystem){
           # Use the All Users Start Menu path if running as SYSTEM
           $startMenuDir = Join-Path $env:ALLUSERSPROFILE "Microsoft\Windows\Start Menu\Programs"
       } else {
           # Use the current user's Start Menu path
           $startMenuDir = "$([Environment]::GetFolderPath("StartMenu"))\Programs"
       }
       return $startMenuDir
   }
}

# Remove the shortcut icon from the Desktop, if it exists
Remove-Item -Path $(Join-Path $(Get-DesktopDir) "$ShortcutDisplayName.lnk") -EA SilentlyContinue

# Remove the shortcut icon from the Start Menu, if it exists
Remove-Item -Path $(Join-Path $(Get-StartDir) "$ShortcutDisplayName.lnk") -EA SilentlyContinue