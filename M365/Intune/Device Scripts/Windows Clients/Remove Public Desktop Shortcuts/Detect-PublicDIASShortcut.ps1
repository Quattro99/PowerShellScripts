<#
.SYNOPSIS
    Intune detection script for public DIAS desktop shortcut.
.DESCRIPTION
    Checks for the presence of $env:Public\Desktop\DIAS.rdp.
    Exit codes:
      0 = No remediation required (DIAS.rdp not present)
      1 = Remediation required (DIAS.rdp present) or an error occurred
#>

#region Logging helper
$logDir = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\RemediationLogs'
if (-not (Test-Path $logDir)) {
    try { New-Item -Path $logDir -ItemType Directory -Force | Out-Null } catch {}
}
$logFile = Join-Path $logDir ("Detect-DIAS-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))

function Write-Log {
    param([string]$Message)
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $entry = "$ts - $Message"
    try { Add-Content -Path $logFile -Value $entry -ErrorAction SilentlyContinue } catch {}
    Write-Output $entry
}
#endregion

try {
    $publicDesktop = Join-Path -Path $env:PUBLIC -ChildPath 'Desktop'
    $target = Join-Path -Path $publicDesktop -ChildPath 'DIAS.rdp'

    Write-Log "Detection started. Checking: $target"

    if (-not (Test-Path -Path $publicDesktop -PathType Container)) {
        Write-Log "Public desktop folder not found: $publicDesktop. Nothing to remediate."
        Exit 0
    }

    if (Test-Path -Path $target -PathType Leaf) {
        Write-Log "DIAS.rdp exists: $target. Remediation required."
        Exit 1
    } else {
        Write-Log "DIAS.rdp not found. No remediation required."
        Exit 0
    }
}
catch {
    Write-Log "ERROR during detection: $($_.Exception.Message)"
    # On error, treat as remediation required so remediation runs (safe default)
    Exit 1
}