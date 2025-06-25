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

# Define the URL where the XML file is located
$xmlUrl = "https://raw.githubusercontent.com/Quattro99/PowerShellScripts/5992efa6edb488e7b2a68f50fe504aa14c9f76c6/Azure/AVD/Change%20Language/CHRegion.xml"

# Check if C:\Temp already exists
$tempDirPath = "C:\Temp"
if (-not (Test-Path $tempDirPath)) {
    # Create New directory if it does not exist
    try {
        New-Item -Path "C:\" -Name "Temp" -ItemType "Directory"
        Write-Host "Created directory: $tempDirPath"
    } catch {
        Write-Host "Failed to create directory: $_"
        exit
    }
} else {
    Write-Host "Directory already exists: $tempDirPath"
}

# Define the local path to save the downloaded XML file
$xmlFilePath = "$tempDirPath\CHRegion.xml"

# Download the XML file if it does not already exist
if (-not (Test-Path $xmlFilePath)) {
    try {
        Invoke-WebRequest -Uri $xmlUrl -OutFile $xmlFilePath
        Write-Host "Downloaded XML file to: $xmlFilePath"
    } catch {
        Write-Host "Failed to download XML file: $_"
        exit
    }
} else {
    Write-Host "XML file already exists at: $xmlFilePath"
}

# Set Locale, language, etc. using the downloaded XML file
try {
    & "$env:SystemRoot\System32\control.exe" "intl.cpl,,/f:`"$xmlFilePath`""
    Write-Host "Locale and language settings applied from XML."
} catch {
    Write-Host "Failed to set locale and language: $_"
}

# Set Timezone
try {
    tzutil /s "W. Europe Standard Time"
    Write-Host "Timezone set to W. Europe Standard Time."
} catch {
    Write-Host "Failed to set timezone: $_"
}

# Set languages/culture
try {
    Set-Culture de-CH
    Write-Host "Culture set to de-CH."
} catch {
    Write-Host "Failed to set culture: $_"
}

# Set International Settings
try{
    Set-WinSystemLocale de-CH
    Write-Host "International Settings set to de-CH."
} catch {
    Write-Host "Failed to set international settings: $_"
}

# Install the language pack for German (Switzerland)
try {
    Install-Language de-CH
    Write-Host "Language pack for German (Switzerland) installed."
} catch {
    Write-Host "Failed to install language pack: $_"
}

# End the transcript to capture all output
Stop-Transcript
