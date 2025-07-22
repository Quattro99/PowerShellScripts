<#
.SYNOPSIS
    Script to detect if the CI-Sign executable has been run.
.DESCRIPTION
    This script checks for the existence of the path indicating CI-Sign executable has successfully run.
.INPUTS
    None.
.OUTPUTS
    Outputs true or false based on the detection criteria.
.NOTES
   ===========================================================================
    Created on:    18.06.2025
    Created by:    Michele Blum
    Filename:      Detect-CI-Sign.ps1
   ===========================================================================
.COMPONENT
    Detection Script.
.ROLE
    Verify execution of the remediation script.
.FUNCTIONALITY
    Check for specific indicators that CI-Sign executable has been run.
#>

# Get the current user's AppData path
$currentUserAppData = [System.Environment]::GetFolderPath('LocalApplicationData')

# Path of the folder created upon successful execution
$executionPath = Join-Path -Path $currentUserAppData -ChildPath "ci-sign"

# Function to check the existence of the path
function Check-ExecutionPath {
    param(
        [string]$path
    )
    
    if (Test-Path $path) {
        Write-Host "Execution path found."
        return $true
    } else {
        Write-Host "Execution path not found."
        return $false
    }
}

# Perform the check
$executionStatus = Check-ExecutionPath -path $executionPath

if ($executionStatus) {
    Write-Host "CI-Sign executable has run successfully."
    exit 0  # Exit code 0 indicates success for Intune detection
} else {
    Write-Host "CI-Sign executable has not run successfully."
    exit 1  # Exit code 1 indicates failure
}