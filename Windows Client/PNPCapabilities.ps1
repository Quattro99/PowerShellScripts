<#
.SYNOPSIS
    Disables the "Allow the computer to turn off this device to save power" option for physical network adapters.

.DESCRIPTION
    This script identifies all physical network adapters that are not Microsoft devices and are working properly.
    It then checks the PnPCapabilities registry setting for each adapter and disables the power-saving option if it is not already disabled.

.INPUTS
    None. This script does not take any inputs.

.OUTPUTS
    None. This script does not produce any outputs.

.NOTES
   ===========================================================================
    Created on:   	31.07.2024
    Created by:   	Michele Blum
    Filename:     	PNPCapabilities.ps1
   ===========================================================================
    Source: https://github.com/KurtDeGreeff/PlayPowershell/blob/master/DisableNetworkAdapterPnPCapabilities.ps1

.COMPONENT
    Network Adapter Management

.ROLE
    System Administration

.FUNCTIONALITY
    Disables the power-saving option for physical network adapters.
#>

Function Disable-OSCNetAdapterPnPCapabilities {
    # Get all physical network adapters that are not Microsoft devices and are working properly
    $PhysicalAdapters = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {
        $_.PNPDeviceID -notlike "ROOT\*" -and
        $_.Manufacturer -ne "Microsoft" -and
        $_.ConfigManagerErrorCode -eq 0 -and
        $_.ConfigManagerErrorCode -ne 22
    }

    # Iterate through each physical adapter
    Foreach ($PhysicalAdapter in $PhysicalAdapters) {
        $PhysicalAdapterName = $PhysicalAdapter.Name
        $DeviceID = $PhysicalAdapter.DeviceID

        # Format the DeviceID to match the registry path format
        $AdapterDeviceNumber = if ([Int32]$DeviceID -lt 10) { "000$DeviceID" } else { "00$DeviceID" }

        # Define the registry path for the network adapter
        $KeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\$AdapterDeviceNumber"

        # Check if the registry path exists
        if (Test-Path -Path $KeyPath) {
            $PnPCapabilitiesValue = (Get-ItemProperty -Path $KeyPath).PnPCapabilities

            # Check the current PnPCapabilities value and take appropriate action
            switch ($PnPCapabilitiesValue) {
                24 {
                    Write-Warning """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" has been disabled already."
                }
                0 {
                    Try {
                        # Set the PnPCapabilities value to 24 to disable the power-saving option
                        Set-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 | Out-Null
                        Write-Host """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" was disabled."
                    } Catch {
                        Write-Host "Setting the value of properties of PnpCapabilities failed." -ForegroundColor Red
                    }
                }
                $null {
                    Try {
                        # Create the PnPCapabilities property and set its value to 24
                        New-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 -PropertyType DWord | Out-Null
                        Write-Host """$PhysicalAdapterName"" - The option ""Allow the computer to turn off this device to save power"" was disabled."
                    } Catch {
                        Write-Host "Setting the value of properties of PnpCapabilities failed." -ForegroundColor Red
                    }
                }
            }
        } else {
            Write-Warning "The path ($KeyPath) not found."
        }
    }
}

# Execute the function
Disable-OSCNetAdapterPnPCapabilities
