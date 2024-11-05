<#
.SYNOPSIS
    Script to remove desktop shortcuts.
.DESCRIPTION
    This script deletes the .lnk files (shortcuts) from the desktop of the current user. 
    It can also delete shortcuts from the public desktop, if indicated.
.INPUTS
    None
.OUTPUTS
    None
.NOTES
   ===========================================================================
	 Created on:   	16.08.2024
	 Created by:   	Michele Blum
	 Filename:     	Remove-Shortcuts.ps1
	===========================================================================
.COMPONENT
    Utility
.ROLE
    Maintenance
.FUNCTIONALITY
    Cleans up desktop shortcuts.
#>

function Remove-Shortcuts {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false, 
                   HelpMessage = "Specify if you want to delete shortcuts only from current user's desktop.")]
        [bool]$MyDesktopOnly = $false
    )

    Write-Host 'Deleting desktop icons...' -ForegroundColor Green

    # Remove shortcuts from current user's desktop
    Remove-Item -Path "C:\Users\$env:USERNAME\Desktop\*.lnk" -Force -Verbose

    # If MyDesktopOnly is not specified, also remove from public desktop
    if (-not $MyDesktopOnly) {
        Remove-Item -Path "C:\Users\Public\Desktop\*.lnk" -Force -Verbose
    }
}

# Invoke the function
Remove-Shortcuts
