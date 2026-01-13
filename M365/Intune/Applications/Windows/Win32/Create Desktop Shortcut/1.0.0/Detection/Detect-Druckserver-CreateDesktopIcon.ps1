<#
.SYNOPSIS
    Creates a desktop shortcut for the Druckserver application.
.DESCRIPTION
    This script checks if a user is running it as SYSTEM, then it creates or verifies the existence of
    a shortcut on the Desktop named "Druckserver". If the shortcut already exists, it outputs "0".
.INPUTS
    None.
.OUTPUTS
    String - Outputs "0" if the shortcut already exists.
.NOTES
    ===========================================================================
    Created on:    13.01.2026
    Created by:    Michele Blum
    Filename:      Detect-Druckserver-CreateDesktopIcon.ps1
    ===========================================================================
.COMPONENT
    Druckserver Shortcut Creation
.ROLE
    Script to check and create Druckserver shortcut on the desktop.
.FUNCTIONALITY
    Verifies and generates a desktop shortcut for the Druckserver application.
#>

# Define the name of the shortcut without the *.lnk extension
$shortcutName = "Druckserver"

# Check if script is running with SYSTEM privileges
if ($(whoami -user) -match "S-1-5-18"){
    $runningAsSystem = $true
}

# Determine the correct desktop directory based on privilege level
if ($runningAsSystem){
    # If running as SYSTEM, use the PUBLIC desktop path
    $desktopDir = Join-Path -Path $env:PUBLIC -ChildPath "Desktop"
} else {
    # If not running as SYSTEM, use the current user's desktop path
    $desktopDir = $([Environment]::GetFolderPath("Desktop"))
}

# Check if the shortcut already exists on the desktop
if (Test-Path -Path $(Join-Path $desktopDir "$shortcutName.lnk")){
    # Output "0" if the shortcut exists
    Write-Output "0"
}