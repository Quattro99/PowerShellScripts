<#
.SYNOPSIS
   This script handles installation and uninstallation of applications in an Intune environment.

.DESCRIPTION
   The script can either install or uninstall an application based on the parameters provided. 
   It uses the Windows Installer (MSI) or executable (EXE) methods for installation and uninstallation, 
   ensuring that the process is logged for troubleshooting.

.INPUTS
   -Remove: Specify this switch to perform uninstallation of the application.

.OUTPUTS
   Returns the exit code of the installation or uninstallation process.

.NOTES
   ===========================================================================
	Created on:  04.02.2024
	Created by:  Michele Blum
	Filename:    BrotheriPrint&Scan-13_1_0_85.ps1
   ===========================================================================
.COMPONENT
   Application Management

.ROLE
   Installation and Uninstallation Script

.FUNCTIONALITY
   - Handles application installation via EXE or MSI.
   - Logs the installation/uninstallation process for debugging.
   - Implements error handling with relevant exit codes.
   
   Error Codes: 
   0 = success
   1 = error/failure

   MSI install example:
   msiexec /i "application.msi" /qn /parameter

   EXE install example: 
   $application = "app.exe"
   $argument = '/quiet /parameter2'
#>

#------- Parameters and preferences -----------
[CmdletBinding()]
Param (
   [Parameter(Mandatory=$false)]
   [Switch]$Remove  # Switch to indicate whether to remove the application
)

# Action preferences to capture verbose output and errors
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#-------- Logging Configuration --------#
# Set up a logging mechanism to capture outputs for troubleshooting
if ($PSCommandPath) {
    $LogName = (split-path $PSCommandPath -Leaf) -replace ".ps1",""  # Log name based on script name
} else {
    $LogName = "Current"  # Default log name
}

# Define the full path for logging
$LogFullname = "{0}\{1}\{2}-{3}.log" -f $env:ProgramData, "Microsoft\IntuneManagementExtension\Logs", $LogName, $(get-Date -f "yyyyMMdd-HHmmss")

# Start logging the output to the log file
Start-Transcript -Path $LogFullname

#-------- Install / Uninstall --------------#
Try {
    # Check if the Remove switch is specified for uninstallation
    if ($Remove) {
        ##### Stop Application Process ############
        Write-Verbose "Stopping Application..."
        Get-Process "ProcessName" -ErrorAction Ignore | Stop-Process  # Replace "ProcessName" with the actual application process name to stop

        Write-Verbose "Removing Application..."
        $Application = "$PSScriptRoot\Package\iPrintScan-Setup-13_1_0_85.exe"  # Specify the executable for uninstallation
        $Argument = '/uninstall /quiet /norestart'  # Specify the arguments for uninstallation

        # Start the uninstallation process
        $Result = Start-Process $Application -Wait -PassThru -ArgumentList $Argument
        $ExitCode = $Result.ExitCode
        Write-Verbose "Uninstallation successful. ExitCode: $ExitCode"
    }
    # If Remove is not specified, perform installation
    else {
        Write-Verbose "Installing Application..."
        $Application = "$PSScriptRoot\Package\iPrintScan-Setup-13_1_0_85.exe"  # Specify the executable for installation
        $Argument = '/install /quiet /norestart'  # Specify the arguments for installation

        # Start the installation process
        $Result = Start-Process $Application -Wait -PassThru -ArgumentList $Argument
        $ExitCode = $Result.ExitCode
        Write-Verbose "Installation successful. ExitCode: $ExitCode"
    }
}
Catch {
    # Error handling if something goes wrong
    Write-Verbose "Error occurred during installation or uninstallation. Exit with Exitcode: 1"
    $ExitCode = 1
}

#-------- Exit App----------#
# Check the ExitCode and handle accordingly
if ($ExitCode -eq $null -or $ExitCode -eq "1") {
    Write-Error "Exit with Exitcode $ExitCode"
    # Stop logging
    Stop-Transcript
    Exit 1
} else {
    Write-Output "Exit with Exitcode $ExitCode"
    # Stop logging
    Stop-Transcript
    Exit $ExitCode
}