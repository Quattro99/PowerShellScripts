<#
.SYNOPSIS
    Validates Outlook font settings from the registry.
.DESCRIPTION
    This script checks the font settings used by Outlook in the registry
    and compares them against predefined values to determine compliance.
.INPUTS
    None. The script reads registry values.
.OUTPUTS
    Outputs "Compliant" if the registry values match the expected values.
    Outputs "Not Compliant" if there is a mismatch or error.
.NOTES
    ===========================================================================
    Created on:    13.01.2026
    Created by:    Michele Blum
    Filename:      Outlook_Fonts_Detection.ps1
    ===========================================================================
.COMPONENT
    Outlook Font Settings Compliance
.ROLE
    Compares registry settings for Outlook fonts with predefined standards.
.FUNCTIONALITY
    Ensures that the specified fonts and styles in Outlook match organizational standards.
#>

# Define registry path and expected values
$Path = "registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Common\mailsettings"
$Name1 = "ReplyFontComplex"
$Name2 = "ComposeFontComplex"
$Value1 = "3C,68,74,6D,6C,3E,...,3C,2F,68,74,6D,6C,3E,0D,0A" # Concatenated expected value
$Value2 = "3C,68,74,6D,6C,3E,...,3C,2F,68,74,6D,6C,3E,0D,0A" # Concatenated expected value

Try {
    # Retrieve registry value for ReplyFontComplex
    $Registry1 = (Get-ItemProperty -Path $Path -Name $Name1 -ErrorAction Stop | 
                  Select-Object -ExpandProperty $Name1 | 
                  ForEach-Object { '{0:X2}' -f $_ }) -join ','

    # Retrieve registry value for ComposeFontComplex
    $Registry2 = (Get-ItemProperty -Path $Path -Name $Name2 -ErrorAction Stop | 
                  Select-Object -ExpandProperty $Name2 | 
                  ForEach-Object { '{0:X2}' -f $_ }) -join ','

    # Compare retrieved values with expected values
    If ($Registry1 -eq $Value1 -and $Registry2 -eq $Value2) {
        Write-Output "Compliant"
        Exit 0
    } else {
        Write-Warning "Not Compliant"
        Exit 1
    }
}
Catch {
    # Handle exceptions and output non-compliance
    Write-Warning "Not Compliant"
    Exit 1
}