# Requires Module
Install-Module Microsoft.Graph.Beta.DeviceManagement.Enrollment
Install-Module Microsoft.Graph.Identity.DirectoryManagement
Install-Module Microsoft.Graph.Beta.DeviceManagement.Actions

# Import required module
Import-Module Microsoft.Graph.Beta.DeviceManagement.Enrollment
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Beta.DeviceManagement.Actions

#Start Log
$LogPath = "C:\temp\autopilotlog3.log"
Start-Transcript -Path $LogPath -Append

# Set tenant ID if you access a customer tenant
$tenantid = "***"

# Connect to MgGraph with permission scopes
Connect-MgGraph -NoWelcome -Scopes "DeviceManagementServiceConfig.Read.All, DeviceManagementServiceConfig.ReadWrite.All" -TenantId $tenantid

# Specify time range
$currentTime = Get-Date
$minAge = $currentTime.AddDays(-90)


# Query Microsoft Graph Endpoints and filter for conditions
$allAutopilot = Get-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -All
$staleAutopilot = Get-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object { $_.EnrollmentState -ne "notContacted" -and $_.LastContactedDateTime -lt $minAge }
$neverContactedAutopilot = Get-MgBetaDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object { $_.EnrollmentState -eq "notContacted" }
$disabledDevices = Get-MgDevice -all | Where-Object {$_.AccountEnabled -eq $false -and $_.ApproximateLastSignInDateTime -lt $minAge } 


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
        Remove-MgDevice -DeviceId $disabledDevice.Id
    }
    


# Sync Autopilot devices (recommended after deletion), requires module Microsoft.Graph.Beta.DeviceManagement.Actions
Sync-MgBetaDeviceManagementWindowsAutopilotSetting
