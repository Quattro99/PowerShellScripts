<#
.SYNOPSIS
   This script cleans up stale and disabled Autopilot devices from Intune by leveraging Microsoft Graph API.

.DESCRIPTION
   The script connects to Microsoft Graph and queries for Windows Autopilot devices. It identifies stale devices that have not contacted the Intune service for a specified time period, as well as devices that have never contacted the service. Additionally, it locates devices that are disabled. The script then removes these devices from the Autopilot portal and disables them in Entra ID (Azure AD).
   
.INPUTS
   - Tenant ID: The script requires the tenant ID for connecting to Microsoft Graph.
   - The script operates on data returned from Microsoft Graph without requiring further input.

.OUTPUTS
   - Outputs summary information about the total counts of devices in various categories (existing, stale, never-contacted, disabled).
   - Outputs details about devices that are being deleted or disabled during the cleanup process.

.NOTES
   Source: https://niklastinner.medium.com/autopilot-cleanup-script-e29c98a71aa6
   
   ===========================================================================
   Created on:    16.12.2024
   Created by:    Michele Blum
   Filename:      IntuneDeviceCleanUp.ps1
   ===========================================================================
.COMPONENT
   Microsoft Graph API

.ROLE
   Intune Administrator / Azure Administrator

.FUNCTIONALITY
   Automates the cleanup of stale and disabled Autopilot devices in Intune, ensuring ongoing device management and operational efficiency.
#>

# Requires Module
Install-Module Microsoft.Graph.Beta.DeviceManagement.Enrollment
Install-Module Microsoft.Graph.Identity.DirectoryManagement
Install-Module Microsoft.Graph.Beta.DeviceManagement.Actions

# Import required module
Import-Module Microsoft.Graph.Beta.DeviceManagement.Enrollment
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Beta.DeviceManagement.Actions

#Start Log
$LogPath = "C:\temp\autopilotlog.log"
Start-Transcript -Path $LogPath -Append

# Set tenant ID if you access a customer tenant
$tenantid = "***"

# Connect to MgGraph with permission scopes
Connect-MgGraph -NoWelcome -Scopes "DeviceManagementServiceConfig.Read.All, DeviceManagementServiceConfig.ReadWrite.All, Device.ReadWrite.All" -TenantId $tenantid

# Specify time range
$currentTime = Get-Date
$minAge = $currentTime.AddDays(-90)


# Query Microsoft Graph Endpoints and filter for conditions
$allAutopilot = Get-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -All
$staleAutopilot = Get-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object { $_.EnrollmentState -ne "notContacted" -and $_.LastContactedDateTime -lt $minAge }
$neverContactedAutopilot = Get-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object { $_.EnrollmentState -eq "notContacted" }
$disabledDevices = Get-MgBetaDevice -all | Where-Object {$_.AccountEnabled -eq $false -and $_.ApproximateLastSignInDateTime -lt $minAge } 


Write-Output "$($allAutopilot.Count) Autopilot identities are existing in your tenant."
Write-Output "$($staleAutopilot.Count) Autopilot identities have not contacted the Intune service since $($minAge)."
Write-Output "$($neverContactedAutopilot.Count) Autopilot identities have not contacted the Intune service ever."
Write-Output "$($disabledDevices.Count) Devices that are disabled since $($minAge)."


# Delete stale autopilot devices and deactivate them
foreach ($staleautopilotdevice in $staleAutopilot) {
    Write-Output "The device with the following serial number will be deleted from the Autopilot portal: $($staleautopilotdevice.SerialNumber)"
    Remove-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $staleautopilotdevice.Id

    Write-Output "The device with the following serial number will be deactivated in Entra ID: $($staleautopilotdevice.SerialNumber)"
    $deactivatedstaleautopilotdevice = Get-MgDevice -All | Where-Object {$_.DeviceId -eq $staleautopilotdevice.AzureAdDeviceId} 
    Update-MgDevice -DeviceId $deactivatedstaleautopilotdevice.id -AccountEnabled:$false
}

# Delete disabled devices and autopilot information
foreach ($disabledDevice in $disabledDevices) {
    
    $autpilotdisabledDevice = Get-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object $disabledDevice.Id

    if ($null -eq $autpilotdisabledDevice) {
        Write-Output "No Autopilot Device found."}

    
    else {
        Write-Output "The device with the following serial number will be deleted from the Autopilot portal: $($disableddevice.DisplayName)"
        Remove-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $disableddevice.Id}


        Write-Output "The device with the following serial number will be deleted: $($disabledDevice.DisplayName)"
        #$deletedisabledDevice = Get-MgDevice -All | Where-Object {$_.DeviceId -eq $disabledDevice.AzureAdDeviceId}
        Remove-MgBetaDevice -DeviceId $disabledDevice.Id
    }
    


# Sync Autopilot devices (recommended after deletion), requires module Microsoft.Graph.Beta.DeviceManagement.Actions
Sync-MgBetaDeviceManagementWindowsAutopilotSetting
