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
    Created on:    28.06.2024
    Created by:    Michele Blum
    Filename:      Remove-HPbloatware.ps1
   ===========================================================================
.COMPONENT
    Intune, System Cleanup
.ROLE
    Intune Administrator
.FUNCTIONALITY
    Removes pre-installed HP software to streamline and optimize system performance.
#>

# List of built-in apps to remove
$UninstallPackages = @(
    "AD2F1837.HPJumpStarts"
    "AD2F1837.HPPCHardwareDiagnosticsWindows"
    "AD2F1837.HPPowerManager"
    "AD2F1837.HPPrivacySettings"
    "AD2F1837.HPSupportAssistant"
    "AD2F1837.HPSureShieldAI"
    "AD2F1837.HPSystemInformation"
    "AD2F1837.HPQuickDrop"
    "AD2F1837.HPWorkWell"
    "AD2F1837.myHP"
    "AD2F1837.HPDesktopSupportUtilities"
    "AD2F1837.HPQuickTouch"
    "AD2F1837.HPEasyClean"
    "AD2F1837.HPSystemInformation"
)

# List of programs to uninstall
$UninstallPrograms = @(
    "HP Client Security Manager"
    "HP Connection Optimizer"
    "HP Documentation"
    "HP MAC Address Manager"
    "HP Notifications"
    "HP Security Update Service"
    "HP System Default Settings"
    "HP Sure Click"
    "HP Sure Click Security Browser"
    "HP Sure Run"
    "HP Sure Recover"
    "HP Sure Sense"
    "HP Sure Sense Installer"
    "HP Support Assistant"
    "HP Wolf Security"
    "HP Wolf Security Application Support for Sure Sense"
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

#Function to log output
function Log {
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "HPBbloatware.log",
        [switch]$Stamp
    )

    #Build Log File appending System Date/Time to output
    $LogFile = Join-Path -Path $env:ProgramData -ChildPath $("Microsoft\IntuneManagementExtension\Logs\$FileName")
    $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
    $Date = (Get-Date -Format "MM-dd-yyyy")

    If ($Stamp) {
        $LogText = "<$($Value)> <time=""$($Time)"" date=""$($Date)"">"
    }
    else {
        $LogText = "$($Value)"   
    }
    
    Try {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFile -ErrorAction Stop
    }
    Catch [System.Exception] {
        Write-Warning -Message "Unable to add log entry to $LogFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

# Function to remove HP APPX provisioned packages
function RemoveAppxProvisionedHPApps {
    ForEach ($ProvPackage in $ProvisionedPackages) {
        Write-Host "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
        Try {
            Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
            Write-Host "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
        }
        Catch {
            Write-Warning "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
        }
    }
    # Proceed to the next function
    RemoveAppxHPApps
}

# Function to remove HP APPX packages
function RemoveAppxHPApps {
    ForEach ($AppxPackage in $InstalledPackages) {                                 
        Write-Host "Attempting to remove Appx package: [$($AppxPackage.Name)]..."
        Try {
            Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "Successfully removed Appx package: [$($AppxPackage.Name)]"
        }
        Catch {
            Write-Warning "Failed to remove Appx package: [$($AppxPackage.Name)]"
        }
    }
    # Proceed to the next function
    RemoveHPInstalledPrograms
}

# Function to remove HP installed programs
function RemoveHPInstalledPrograms {
    ForEach ($Program in $InstalledPrograms) {
        Write-Host "Attempting to uninstall: [$($Program.Name)]..."
        Try {
            $Program | Uninstall-Package -AllVersions -Force -ErrorAction Stop
            Write-Host "Successfully uninstalled: [$($Program.Name)]"
        }
        Catch {
            Write-Warning "Failed to uninstall: [$($Program.Name)]"
        }
    }
    # Proceed to the next function
    RemoveHPWin32Apps
}

# Function to remove HP Win32 applications
function RemoveHPWin32Apps {
    ForEach ($app in $apps) {
        $id = $app.IdentifyingNumber
        msiexec /uninstall "$id" /quiet /log $msilog /norestart
    }
    # Proceed to the next function
    RemoveHPConnectionOptimizer
}

# Function to remove HP Connection Optimizer
function RemoveHPConnectionOptimizer {
    If ($HPCommRecoveryPresent) {
        $optimizerUninstallAnswer | Out-File $env:TEMP\optimizer.iss
        $arguments = "/s /f1`"$env:TEMP\optimizer.iss`" /f2`"C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PConnectionOptimizerUninstall.log`""
        Start-Process "C:\Program Files (x86)\InstallShield Installation Information\{6468C4A5-E47E-405F-B675-A70A70983EA6}\Setup.exe" -ArgumentList $arguments -PassThru -Wait
    }
    # Proceed to the next function
    RemoveHPDocumentation
}

# Function to remove HP Documentation
function RemoveHPDocumentation {
    If (Test-Path "${Env:ProgramFiles}\HP\Documentation\Doc_uninstall.cmd" -PathType Leaf) {
        Write-Host "Attempting to remove HP Documentation..."
        Try {
            Invoke-Item "${Env:ProgramFiles}\HP\Documentation\Doc_uninstall.cmd"
            Write-Host "Successfully removed HP Documentation"
        }
        Catch {
            Write-Warning "Error removing HP Documentation: $($_.Exception.Message)"
        }
    } Else {
        Write-Host "HP Documentation is not installed"
    }
    # Proceed to the next function
    RemoveHPSupportAssistant
}

# Function to remove HP Support Assistant
function RemoveHPSupportAssistant {
    If (Test-Path -Path "HKLM:\Software\WOW6432Node\Hewlett-Packard\HPActiveSupport") {
        Write-Host "Attempting to remove HP Support Assistant registry key..."
        Try {
            Remove-Item -Path "HKLM:\Software\WOW6432Node\Hewlett-Packard\HPActiveSupport" -Recurse -Force
            Write-Host "Successfully removed HP Support Assistant registry key"
        }
        Catch {
            Write-Warning "Error retrieving registry key for HP Support Assistant: $($_.Exception.Message)"
        }
    } Else {
        Write-Host "HP Support Assistant registry key not found"
    }

    If (Test-Path $HPSAuninstall -PathType Leaf) {
        Write-Host "Attempting to uninstall HP Support Assistant..."
        Try {
            & $HPSAuninstall /s /v/qn UninstallKeepPreferences=FALSE
            Write-Host "Successfully uninstalled HP Support Assistant"
        }
        Catch {
            Write-Warning "Error uninstalling HP Support Assistant: $($_.Exception.Message)"
        }
    } Else {
        Write-Host "HP Support Assistant uninstaller not found"
    }
    # Proceed to the next function
    RemoveRemainingHPApps
}

# Function to remove remaining HP applications
function RemoveRemainingHPApps {
    $remainingApps = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "HP"}
    If ($remainingApps) {
        Write-Host "Attempting to remove remaining HP applications..."
        ForEach ($app in $remainingApps) {
            $id = $app.IdentifyingNumber
            msiexec /uninstall "$id" /quiet /log $msilog /norestart
        }
    } Else {
        Write-Host "No remaining HP applications found"
    }
}

# Start with the first functions
Log
RemoveAppxProvisionedHPApps
