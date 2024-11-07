<#
.SYNOPSIS
    This script configures the system locale, time zone, and language settings for a Windows machine to German (Switzerland).

.DESCRIPTION
    This script sets the user language, system locale, and time zone to correspond with the de-CH setting.
.INPUTS
    None. This script does not take any inputs.

.OUTPUTS
    Configures system language and locale settings.

.NOTES
   ===========================================================================
   Created on:    07.11.2024
   Created by:    Michele Blum
   Filename:      Set-Language_to_de-ch.ps1
   ===========================================================================
.COMPONENT
    Globalization Settings

.ROLE
    System Configuration

.FUNCTIONALITY
    Sets language and region settings for a Windows system.
#>

# Logging configuration
$logFilePath = "C:\Temp\Set-Language_to_de-ch_Transcript.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Starting the language and locale configuration to German (Switzerland)..." -ForegroundColor Green

# Set Locale, language etc. by applying the relevant settings from the XML configuration
$xmlConfigPath = "CHRegion.xml"
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$xmlConfigPath`""

# Set Timezone to W. Europe Standard Time
Write-Host "Setting time zone to W. Europe Standard Time..." -ForegroundColor Yellow
& tzutil /s "W. Europe Standard Time"

# Set the culture to German (Switzerland)
Write-Host "Setting culture to de-CH..." -ForegroundColor Yellow
Set-Culture de-CH

# Log completion message
Write-Host "Language and locale configuration completed successfully." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript