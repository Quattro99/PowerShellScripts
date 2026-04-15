<#
.SYNOPSIS
    Detects whether BitLocker is enabled on the C: drive.
.DESCRIPTION
    Checks the ProtectionStatus of the BitLocker volume on C:.
    Returns exit code 1 if enabled (non‑compliant), 0 if disabled (compliant).
.INPUTS
    None
.OUTPUTS
    Exit code for Intune detection.
.NOTES
   ===========================================================================
     Created on:       15.04.2026
     Created by:       Michele Blum
     Filename:         BitLocker_Detect.ps1
   ===========================================================================
.COMPONENT
    Intune Compliance
.ROLE
    Detection
.FUNCTIONALITY
    Detect BitLocker status
#>

try {
    $blv = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop

    if ($blv.ProtectionStatus -eq 'On') {
        exit 1   # Non‑compliant
    }
    else {
        exit 0   # Compliant
    }
}
catch {
    # If something goes wrong, treat as compliant to avoid remediation loops
    exit 0
}