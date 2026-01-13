<#
.SYNOPSIS
    Creates a shortcut on the Desktop and optionally pins it to the Start Menu.
.DESCRIPTION
    This script creates shortcuts for a specified target path, allowing customization of icon,
    arguments, and working directory. It includes the option to pin the shortcut to the Start Menu.
.INPUTS
    String - Requires the target path and display name for the shortcut.
    Switch - Optional parameter to pin the shortcut to the Start Menu.
    String - Optional parameters for icon file, shortcut arguments, and working directory.
.OUTPUTS
    None.
.NOTES
    ===========================================================================
    Created on:    13.01.2026
    Created by:    Michele Blum
    Filename:      CreateDesktopIcon.ps1
    ===========================================================================
.COMPONENT
    Shortcut Creation
.ROLE
    Script to create desktop and start menu shortcuts.
.FUNCTIONALITY
    Generates desktop and optionally start menu shortcuts with user-defined settings.
#>

[CmdletBinding()]
Param (
   [Parameter(Mandatory=$true)]
   [String]$ShortcutTargetPath,    # Path of the target for the shortcut

   [Parameter(Mandatory=$true)]
   [String]$ShortcutDisplayName,   # Display name of the shortcut

   [Parameter(Mandatory=$false)]
   [Switch]$PinToStart=$false,     # Switch to optionally pin the shortcut to Start

   [Parameter(Mandatory=$false)]
   [String]$IconFile=$null,        # Optional icon file for the shortcut

   [Parameter(Mandatory=$false)]
   [String]$ShortcutArguments=$null, # Optional arguments for the shortcut

   [Parameter(Mandatory=$false)]
   [String]$WorkingDirectory=$null  # Optional working directory for the shortcut
)

# Helper function to create shortcuts
function Add-Shortcut {
    param (
        [Parameter(Mandatory)]
        [String]$ShortcutTargetPath,   # Target path for the shortcut
        [Parameter(Mandatory)]
        [String] $DestinationPath,     # Destination path where the shortcut will be created
        [Parameter()]
        [String] $WorkingDirectory     # Working directory for the shortcut
    )

    process{
        # Create a COM object to handle shortcut creation
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($destinationPath)
        
        # Set properties for the shortcut
        $Shortcut.TargetPath = $ShortcutTargetPath
        $Shortcut.Arguments = $ShortcutArguments
        $Shortcut.WorkingDirectory = $WorkingDirectory
    
        # Set an icon for the shortcut if provided
        if ($IconFile){
            $Shortcut.IconLocation = $IconFile
        }

        # Create the shortcut
        $Shortcut.Save()
        
        # Release the COM object resources
        [Runtime.InteropServices.Marshal]::ReleaseComObject($WshShell) | Out-Null
    }
}

# Function to check if the script is running as SYSTEM
function Test-RunningAsSystem {
    [CmdletBinding()]
    param()
    process{
        # Determine SYSTEM privileges by checking user SID
        return ($(whoami -user) -match "S-1-5-18")
    }
}

# Function to get the desktop directory path
function Get-DesktopDir {
    [CmdletBinding()]
    param()
    process{
        if (Test-RunningAsSystem){
            # Use PUBLIC desktop path if running as SYSTEM
            $desktopDir = Join-Path -Path $env:PUBLIC -ChildPath "Desktop"
        } else {
            # Use current user's desktop path
            $desktopDir = $([Environment]::GetFolderPath("Desktop"))
        }
        return $desktopDir
    }
}

# Function to get the Start Menu directory path
function Get-StartDir {
    [CmdletBinding()]
    param()
    process{
        if (Test-RunningAsSystem){
            # Use All Users Start Menu path if running as SYSTEM
            $startMenuDir = Join-Path $env:ALLUSERSPROFILE "Microsoft\Windows\Start Menu\Programs"
        } else {
            # Use current user's Start Menu path
            $startMenuDir = "$([Environment]::GetFolderPath("StartMenu"))\Programs"
        }
        return $startMenuDir
    }
}

#### Create Desktop Shortcut
$destinationPath = Join-Path -Path $(Get-DesktopDir) -ChildPath "$shortcutDisplayName.lnk"
Add-Shortcut -DestinationPath $destinationPath -ShortcutTargetPath $ShortcutTargetPath -WorkingDirectory $WorkingDirectory

#### Create Start menu entry if pinning to start is requested
if ($PinToStart.IsPresent -eq $true){
    $destinationPath = Join-Path -Path $(Get-StartDir) -ChildPath "$shortcutDisplayName.lnk"
    Add-Shortcut -DestinationPath $destinationPath -ShortcutTargetPath $ShortcutTargetPath -WorkingDirectory $WorkingDirectory
}