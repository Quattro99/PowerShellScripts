<#
.SYNOPSIS
    Script to run CI-Sign executable remotely
.DESCRIPTION
    This script is designed to remotely run the CI-Sign executable located at a specified network path.
.INPUTS
    None
.OUTPUTS
    Outputs success or error messages to the console.
.NOTES
   ===========================================================================
    Created on:    18.06.2025
    Created by:    Michele Blum
    Filename:      Run-CI-Sign.ps1
   ===========================================================================
.COMPONENT
    Deployment Script
.ROLE
    Execute remote scripts
.FUNCTIONALITY
    Run an executable file from a specified network path
#>

# Define the path to the executable file
$exePath = "\\int.duo-infernale.ch\SYSVOL\int.duo-infernale.ch\scripts\deployment\ci-cloud\ci-sign\CI-Sign.exe"

# Function to run the executable
function Run-Executable {
    param(
        [string]$path
    )
    
    if (Test-Path $path) {
        try {
            # Run the executable
            Start-Process -FilePath $path -Wait -NoNewWindow
            Write-Host "Executable ran successfully."
        } catch {
            Write-Error "Failed to run the executable. Error: $_"
        }
    } else {
        Write-Error "Executable not found at path: $path"
    }
}

# Call the function to execute the file
Run-Executable -path $exePath