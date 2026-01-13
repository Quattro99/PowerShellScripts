<#
.SYNOPSIS
    Remediates Outlook font settings in the registry.
.DESCRIPTION
    This script sets specific Outlook font settings in the registry to enforce compliance
    with predefined configurations for simple and complex fonts.
.INPUTS
    None. The script writes values to the registry.
.OUTPUTS
    None. Outputs to the registry but can log actions.
.NOTES
    ===========================================================================
    Created on:    13.01.2026
    Created by:    Michele Blum
    Filename:      Outlook_Fonts_Remediation.ps1
    ===========================================================================
.COMPONENT
    Outlook Font Settings Configuration
.ROLE
    Configures and enforces Outlook font settings via registry.
.FUNCTIONALITY
    Updates registry entries to predefined font settings in Outlook.
#>

# Predefined hex values for font settings
$ValueSimple = "3C,00,00,00,1F,00,00,F8,00,00,00,40,C8,00,00,00,00,00,00,00,00,00,00,00,00,22,53,65,67,6F,65,20,55,49,20,53,65,6D,69,6C,69,67,68,74,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00"
$ValueComposeComplex = "3C,68,74,6D,6C,3E,0D,0A,...,3C,2F,68,74,6D,6C,3E,0D,0A"
$ValueReplyComplex = "3C,68,74,6D,6C,3E,0D,0A,...,3C,2F,68,74,6D,6C,3E,0D,0A"
$ValueTextComplex = "3C,68,74,6D,6C,3E,0D,0A,...,3C,2F,68,74,6D,6C,3E,0D,0A"

# Define registry path and names
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\mailsettings'
$Name1Simple = "ComposeFontSimple"
$Name1Complex = "ComposeFontComplex"
$Name2Simple = "ReplyFontSimple"
$Name2Complex = "ReplyFontComplex"
$Name3Simple = "TextFontSimple"
$Name3Complex = "TextFontComplex"

# Convert the hex values into byte arrays
$hexSimple = $ValueSimple.Split(',') | % { "0x$_"}
$hexComposeComplex = $ValueComposeComplex.Split(',') | % { "0x$_"}
$hexReplyComplex = $ValueReplyComplex.Split(',') | % { "0x$_"}
$hexTextComplex = $ValueTextComplex.Split(',') | % { "0x$_"}

# Check if the registry path exists and create/update values accordingly
IF (!(Test-Path $registryPath)) {
    # Creates the registry path and sets properties for font values
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -name NewTheme -PropertyType string
    New-ItemProperty -Path $registryPath -Name $Name1Simple -Value ([byte[]]$hexSimple) -PropertyType Binary -Force
    New-ItemProperty -Path $registryPath -Name $Name2Simple -Value ([byte[]]$hexSimple) -PropertyType Binary -Force
    New-ItemProperty -Path $registryPath -Name $Name3Simple -Value ([byte[]]$hexSimple) -PropertyType Binary -Force
    New-ItemProperty -Path $registryPath -Name $Name1Complex -Value ([byte[]]$hexComposeComplex) -PropertyType Binary -Force
    New-ItemProperty -Path $registryPath -Name $Name2Complex -Value ([byte[]]$hexReplyComplex) -PropertyType Binary -Force
    New-ItemProperty -Path $registryPath -Name $Name3Complex -Value ([byte[]]$hexTextComplex) -PropertyType Binary -Force
} ELSE {
    # Updates existing registry properties with the new values
    Set-ItemProperty -Path $registryPath -name NewTheme -value $null
    Set-ItemProperty -Path $registryPath -name ThemeFont -value 2
    Set-ItemProperty -Path $registryPath -Name $Name1Simple -Value ([byte[]]$hexSimple) -Force
    Set-ItemProperty -Path $registryPath -Name $Name2Simple -Value ([byte[]]$hexSimple) -Force
    Set-ItemProperty -Path $registryPath -Name $Name3Simple -Value ([byte[]]$hexSimple) -Force
    Set-ItemProperty -Path $registryPath -Name $Name1Complex -Value ([byte[]]$hexComposeComplex) -Force
    Set-ItemProperty -Path $registryPath -Name $Name2Complex -Value ([byte[]]$hexReplyComplex) -Force
    Set-ItemProperty -Path $registryPath -Name $Name3Complex -Value ([byte[]]$hexTextComplex) -Force
}