<#
.SYNOPSIS
    Script to remove pre-installed HP software from a Windows system.
.DESCRIPTION
    This script identifies and uninstalls a predefined list of HP applications and packages from the system, including provisioned packages, Appx packages, Win32 applications, and more.
.INPUTS
    None. The script does not take any pipeline input.
.OUTPUTS
    None. The script does not produce any output objects.
.NOTES
    Idea based on an original script for deleting HP pre-installed software / Credit to: foeyonghai @ Intune Specialist

   ===========================================================================
    Created on:    22.05.2025
    Created by:    Michele Blum
    Filename:      Remove-HPBloatware.ps1
   ===========================================================================
.COMPONENT
    Intune, System Cleanup
.ROLE
    Intune Administrator
.FUNCTIONALITY
    Removes pre-installed HP software to streamline and optimize system performance.
#>

#------- Parameters and preferences -----------
[CmdletBinding()]
Param ()

# Action preferences to capture verbose output and errors
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#-------- Logging Configuration --------#
# Set up a logging mechanism to capture outputs for troubleshooting
if ($PSCommandPath) {
    $LogName = (split-path $PSCommandPath -Leaf) -replace ".ps1", ""  # Log name based on script name
} else {
    $LogName = "Current"  # Default log name
}

# Define the full path for logging
$LogFullname = "{0}\{1}\{2}-{3}.log" -f $env:ProgramData, "Microsoft\IntuneManagementExtension\Logs", $LogName, $(get-Date -f "yyyyMMdd-HHmmss")

# Start logging the output to the log file
Start-Transcript -Path $LogFullname

# List of built-in apps to remove
$UninstallPackages = @(
    "AD2F1837.HPJumpStarts",
    "AD2F1837.HPPCHardwareDiagnosticsWindows",
    "AD2F1837.HPPowerManager",
    "AD2F1837.HPPrivacySettings",
    "AD2F1837.HPSureShieldAI",
    "AD2F1837.HPSystemInformation",
    "AD2F1837.HPQuickDrop",
    "AD2F1837.HPWorkWell",
    "AD2F1837.myHP",
    "AD2F1837.HPDesktopSupportUtilities",
    "AD2F1837.HPQuickTouch",
    "AD2F1837.HPEasyClean",
    "AD2F1837.HPSystemInformation"
)

# List of programs to uninstall
$UninstallPrograms = @(
    "HP Client Security Manager",
    "HP Connection Optimizer",
    "HP Documentation",
    "HP MAC Address Manager",
    "HP Notifications",
    "HP Security Update Service",
    "HP System Default Settings",
    "HP Sure Click",
    "HP Sure Click Security Browser",
    "HP Sure Run",
    "HP Sure Recover",
    "HP Sure Sense",
    "HP Sure Sense Installer",
    "HP Wolf Security",
    "HP Wolf Security Application Support for Sure Sense",
    "HP Wolf Security Application Support for Windows"
)

# Silent uninstall response file for HP Connection Optimizer
$optimizerUninstallAnswer = @"
[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-DlgOrder]
Dlg0={6468C4A5-E47E-405F-B675-A70A70983EA6}-SdWelcomeMaint-0
Count=3
Dlg1={6468C4A5-E47E-405F-B675-A70A70983EA6}-MessageBox-0
Dlg2={6468C4A5-E47E-405F-B675-A70A70983EA6}-SdFinishReboot-0
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-SdWelcomeMaint-0]
Result=303
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-MessageBox-0]
Result=6
[Application]
Name=HP Connection Optimizer
Version=2.0.18.0
Company=HP Inc.
Lang=0409
[{6468C4A5-E47E-405F-B675-A70A70983EA6}-SdFinishReboot-0]
Result=1
BootOption=0
"@

# Run inventories
$HPidentifier = "AD2F1837"
$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object {($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier")}
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier")}
$InstalledPrograms = Get-Package | Where-Object {$UninstallPrograms -contains $_.Name}
$HPCommRecoveryPresent = Test-Path -Path "C:\Program Files\HPCommRecovery"
$apps = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "HP"}
$HPSAuninstall = "${Env:ProgramFiles(x86)}\HP\HP Support Framework\UninstallHPSA.exe"

# Log Function
function Write-LogEntry {
    param (
        [string]$Value = "No value provided.",
        [string]$FileName = $LogFullname  # Use the log file defined earlier
    )

    $Time = Get-Date -Format "HH:mm:ss.fff"
    $Date = Get-Date -Format "MM-dd-yyyy"
    $LogText = "<$($Value)> <time=`"$($Time)`" date=`"$($Date)`">"

    Try {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $FileName -ErrorAction Stop
    }
    Catch {
        Write-Warning "Unable to add log entry to $FileName. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

# Function to Remove Appx-Provisioned Packages
function Remove-AppxProvisionedPackageCustom {
    param (
        [string]$PackageName
    )
    try {
        $AppProvisioningPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -eq $PackageName }
        if ($AppProvisioningPackage) {
            Write-Host "Removing provisioned package: $($AppProvisioningPackage.DisplayName)"
            Remove-AppxProvisionedPackage -PackageName $AppProvisioningPackage.PackageName -Online
            Write-LogEntry -Value "Removed provisioned package: $($AppProvisioningPackage.DisplayName)"
        }
    }
    catch {
        Write-Warning "Failed to remove provisioned package: $PackageName"
        Write-LogEntry -Value "Failed to remove provisioned package: $PackageName"
    }
    RemoveAppxHPApps
}

# Function to remove HP Appx packages
function RemoveAppxHPApps {
    ForEach ($AppxPackage in $InstalledPackages) {
        Write-Host "Attempting to remove Appx package: [$($AppxPackage.Name)]..."
        Try {
            Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "Successfully removed Appx package: [$($AppxPackage.Name)]"
            Write-LogEntry -Value "Successfully removed Appx package: $($AppxPackage.Name)"
        }
        Catch {
            Write-Warning "Failed to remove Appx package: [$($AppxPackage.Name)]"
            Write-LogEntry -Value "Failed to remove Appx package: $($AppxPackage.Name)"
        }
    }
    RemoveHPInstalledPrograms
}

# Function to remove HP installed programs
function RemoveHPInstalledPrograms {
    ForEach ($Program in $InstalledPrograms) {
        Write-Host "Attempting to uninstall: [$($Program.Name)]..."
        Try {
            $Program | Uninstall-Package -AllVersions -Force -ErrorAction Stop
            Write-Host "Successfully uninstalled: [$($Program.Name)]"
            Write-LogEntry -Value "Successfully uninstalled: $($Program.Name)"
        }
        Catch {
            Write-Warning "Failed to uninstall: [$($Program.Name)]"
            Write-LogEntry -Value "Failed to uninstall: $($Program.Name)"
        }
    }
    RemoveHPWin32Apps
}

# Function to remove HP Win32 applications
function RemoveHPWin32Apps {
    ForEach ($app in $apps) {
        Write-Host "Attempting to uninstall Win32 application: $($app.Name)"
        Try {
            $id = $app.IdentifyingNumber
            Start-Process msiexec.exe -ArgumentList "/uninstall `"$id`" /quiet /norestart" -Wait
            Write-Host "Successfully uninstalled Win32 application: $($app.Name)"
            Write-LogEntry -Value "Successfully uninstalled Win32 application: $($app.Name)"
        }
        Catch {
            Write-Warning "Failed to uninstall Win32 application: $($app.Name)"
            Write-LogEntry -Value "Failed to uninstall Win32 application: $($app.Name)"
        }
    }
    RemoveHPConnectionOptimizer
}

# Function to remove HP Connection Optimizer
function RemoveHPConnectionOptimizer {
    If ($HPCommRecoveryPresent) {
        $optimizerUninstallAnswer | Out-File -FilePath "$env:TEMP\optimizer.iss" -Force
        $arguments = "/s /f1`"$env:TEMP\optimizer.iss`" /f2`"C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PConnectionOptimizerUninstall.log`""
        Start-Process -FilePath "C:\Program Files (x86)\InstallShield Installation Information\{6468C4A5-E47E-405F-B675-A70A70983EA6}\Setup.exe" -ArgumentList $arguments -Wait
        Write-LogEntry -Value "HP Connection Optimizer uninstalled with ISS file"
    }
    RemoveHPDocumentation
}

# Function to remove HP Documentation
function RemoveHPDocumentation {
    If (Test-Path "${Env:ProgramFiles}\HP\Documentation\Doc_uninstall.cmd" -PathType Leaf) {
        Write-Host "Attempting to remove HP Documentation..."
        Try {
            Invoke-Item "${Env:ProgramFiles}\HP\Documentation\Doc_uninstall.cmd"
            Write-Host "Successfully removed HP Documentation"
            Write-LogEntry -Value "Successfully removed HP Documentation"
        }
        Catch {
            Write-Warning "Error removing HP Documentation: $($_.Exception.Message)"
            Write-LogEntry -Value "Error removing HP Documentation: $($_.Exception.Message)"
        }
    } Else {
        Write-Host "HP Documentation is not installed"
        Write-LogEntry -Value "HP Documentation is not installed"
    }
}

function RemoveHPBloatware {
    # Start removing HP software
    Remove-AppxProvisionedPackageCustom
}

# Execute the script
Write-Host "Removing HP Bloatware..."
Write-LogEntry -Value "Removing HP Bloatware..."
RemoveHPBloatware

# Stop logging the output to the log file
Stop-Transcript
