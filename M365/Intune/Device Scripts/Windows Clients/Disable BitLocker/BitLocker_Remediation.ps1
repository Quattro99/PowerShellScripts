<#
.SYNOPSIS
    Disables BitLocker on the C: drive.
.DESCRIPTION
    If BitLocker is enabled on the C: drive, it will be disabled.
.INPUTS
    None
.OUTPUTS
    Exit code for Intune remediation.
.NOTES
   ===========================================================================
     Created on:       15.04.2026
     Created by:       Michele Blum
     Filename:         BitLocker_Remediation.ps1
   ===========================================================================
.COMPONENT
    Intune Remediation
.ROLE
    Remediation
.FUNCTIONALITY
    Disable BitLocker if detected as enabled
#>

try {
    $blv = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop

    if ($blv.ProtectionStatus -eq 'On') {
        Disable-BitLocker -MountPoint "C:"
    }

    exit 0
}
catch {
    # Report failure to Intune
    exit 1
}