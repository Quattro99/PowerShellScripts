<#
.SYNOPSIS
    This script creates a registry key and sets a value for Outlook 2016 configuration.

.DESCRIPTION
    The script creates the registry key "Setup" under "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook" if it doesn't already exist,
    and sets the "DisableRoamingSignaturesTemporaryToggle" value to 1.

.NOTES
    ===========================================================================
    Created on:  20.05.2025
    Created by:  Michele Blum
    Filename:    Configure_Outlook_RoamingSignatures.ps1
    ===========================================================================
.COMPONENT
    Outlook Configuration

.ROLE
    Registry Configuration Script

.FUNCTIONALITY
    - Creates registry key "Setup" under "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook".
    - Sets registry value "DisableRoamingSignaturesTemporaryToggle" to 1.
    
    - Provides error handling to ensure registry updates are applied as required.
#>

# Path to the registry key
$registryPath = "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Setup"

try {
    # Create the registry key if it does not exist
    if (!(Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
        Write-Host "Successfully created registry key: $registryPath"
    }
    
    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name "DisableRoamingSignaturesTemporaryToggle" -Type DWORD -Value 1
    Write-Host "Successfully set DisableRoamingSignaturesTemporaryToggle to 1"

} catch {
    Write-Host "An error occurred while updating the registry key and values: $_"
    Exit 1
}

Exit 0