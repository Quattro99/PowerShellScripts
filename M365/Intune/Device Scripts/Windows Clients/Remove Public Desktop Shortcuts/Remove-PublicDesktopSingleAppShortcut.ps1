<#
.SYNOPSIS
    Script to remove public DIAS desktop shortcut.
.DESCRIPTION
    This script deletes the DIAS.rdp file from the public desktop.
.INPUTS
    None
.OUTPUTS
    Exit code: 0 = success, 1 = failure
.NOTES
   ===========================================================================
     Created on:     19.11.2025
     Created by:     Michele Blum
     Filename:       Remove-PublicDesktopDIASShortcut.ps1
   ===========================================================================
.COMPONENT
    Utility
.ROLE
    Maintenance
.FUNCTIONALITY
    Cleans up DIAS.rdp from the public desktop.
#>

function Remove-DIASShortcut {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ()

    # Resolve target path
    $publicDesktop = Join-Path -Path $env:PUBLIC -ChildPath 'Desktop'
    $target = Join-Path -Path $publicDesktop -ChildPath 'DIAS.rdp'

    Write-Verbose "Public desktop resolved to: $publicDesktop"
    Write-Verbose "Target file: $target"

    try {
        if (-not (Test-Path -Path $publicDesktop -PathType Container)) {
            Write-Verbose "Public desktop folder does not exist: $publicDesktop"
            Write-Output "Public desktop not found — nothing to remove."
            return $true
        }

        if (-not (Test-Path -Path $target -PathType Leaf)) {
            Write-Verbose "DIAS.rdp not present on public desktop."
            Write-Output "Not found (nothing to remove): $target"
            return $true
        }

        # Support -WhatIf / -Confirm
        if ($PSCmdlet.ShouldProcess($target, 'Remove file')) {
            Remove-Item -Path $target -Force -ErrorAction Stop
            Write-Output "Removed: $target"
        } else {
            Write-Output "Operation skipped by ShouldProcess (WhatIf/Confirm): $target"
        }

        return $true
    }
    catch {
        Write-Error "Failed to remove $target. Error: $($_.Exception.Message)"
        return $false
    }
}

# Run the function (supports -WhatIf / -Confirm on the script)
$success = Remove-DIASShortcut

if ($success) {
    Exit 0
} else {
    Exit 1
}