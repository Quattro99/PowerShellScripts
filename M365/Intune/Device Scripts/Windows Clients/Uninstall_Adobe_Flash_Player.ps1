<#
.SYNOPSIS
   Uninstalls Adobe Flash Player from the system.
.DESCRIPTION
   Detects the installed Flash Player version in 
   C:\Windows\SysWOW64\Macromed\Flash\
   and runs the corresponding FlashUtil32 uninstaller with force.
.INPUTS
   None
.OUTPUTS
   None
.NOTES
   ===========================================================================
     Created on:    05.03.2026
     Created by:    Michele Blum
     Filename:      Uninstall_Adobe_Flash_Player.ps1
   ===========================================================================
.COMPONENT
   System Maintenance
.ROLE
   Software Removal / Cleanup
.FUNCTIONALITY
   Automatically detects and uninstalls the installed Flash Player version.
#>

# Get the installed Flash Player version from the Flash directory
$version = (    (Get-ChildItem 'C:\Windows\SysWOW64\Macromed\Flash\').Name -match "FlashUtil32_(.*).exe")[0].Split('_')[1].Split('.')[0]

# Build the uninstall command based on the detected version
$uninstallCommand = "C:\Windows\SysWOW64\Macromed\Flash\FlashUtil32_$($version).exe -uninstall -force"

# Execute the uninstall command
Invoke-Expression $uninstallCommand