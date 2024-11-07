<#
.SYNOPSIS
   This script retrieves and displays computers running Windows 7 in Active Directory.
.DESCRIPTION
   The script fetches all computers that are using Windows 7, sorts them by their last logon date,
   and presents their names, last logon properties, and formatted last logon times for better readability.
.INPUTS
   None. This script does not require any input parameters.
.OUTPUTS
   Displays a list of Windows 7 computers along with their last logon date and time.
.NOTES
   ===========================================================================
   Created on:    07.11.2024
   Created by:    Michele Blum
   Filename:      Check_old_OS.ps1
   ===========================================================================
.COMPONENT
   Active Directory
.ROLE
   System Administration
.FUNCTIONALITY
   Identifies outdated operating systems in the Active Directory environment.
#>

# Logging configuration
$logFilePath = "C:\Temp\Check_old_OS_Transcript.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Checking for computers running Windows 7..." -ForegroundColor Green

# Fetch computers running Windows 7 from Active Directory
$oldOSComputers = Get-ADComputer -Filter "OperatingSystem -like '*Windows 7*'" -Properties LastLogon |
    Sort-Object LastLogon |
    Select-Object Name, LastLogonDate, @{Name='LastLogon'; Expression={[DateTime]::FromFileTime($_.LastLogon)}}

# Check if any Windows 7 computers were found
if ($oldOSComputers) {
    Write-Host "The following Windows 7 computers were found:" -ForegroundColor Yellow
    foreach ($computer in $oldOSComputers) {
        Write-Host "- Computer Name: $($computer.Name), Last Logon: $($computer.LastLogon)" -ForegroundColor Green
    }
} else {
    Write-Host "No Windows 7 computers found." -ForegroundColor Green
}

# Log completion message
Write-Host "Old OS check completed." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript