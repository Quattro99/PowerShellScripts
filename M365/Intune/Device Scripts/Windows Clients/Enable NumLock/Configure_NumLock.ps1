<#
.SYNOPSIS
    This script sets the InitialKeyboardIndicators value for the default user profile.

.DESCRIPTION
    The script updates the InitialKeyboardIndicators value under HKU\.DEFAULT\Control Panel\Keyboard to "2" 
    to control the behavior of the NumLock key at startup.

.NOTES
    ===========================================================================
    Created on:  20.05.2025
    Created by:  Michele Blum
    Filename:    Configure_NumLock.ps1
    ===========================================================================
.COMPONENT
    System Configuration

.ROLE
    Registry Configuration Script

.FUNCTIONALITY
    - Sets the InitialKeyboardIndicators value to "2" under HKU\.DEFAULT\Control Panel\Keyboard.
    - Provides error handling to ensure registry updates are applied as required.
#>

# Path to the registry key
$registryPath = "Registry::HKU\.DEFAULT\Control Panel\Keyboard"

try {
    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name "InitialKeyboardIndicators" -Value "2"
    Write-Host "Successfully set InitialKeyboardIndicators to 2"

} catch {
    Write-Host "An error occurred while updating the registry value: $_"
    Exit 1
}

Exit 0