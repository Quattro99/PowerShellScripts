<#
.SYNOPSIS
    Intune remediation script to remove the public DIAS desktop shortcut.
.DESCRIPTION
    Removes $env:Public\Desktop\DIAS.rdp if present. Idempotent.
    Exit codes:
      0 = success (removed or not present)
      1 = failure (error during removal)
#>

#region Logging helper
$logDir = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\RemediationLogs'
if (-not (Test-Path $logDir)) {
    try { New-Item -Path $logDir -ItemType Directory -Force | Out-Null } catch {}
}
$logFile = Join-Path $logDir ("Remediate-RemoveDIAS-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))

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

    Write-Log "Remediation started. Target: $target"

    if (-not (Test-Path -Path $publicDesktop -PathType Container)) {
        Write-Log "Public desktop folder not found: $publicDesktop. Nothing to do."
        Exit 0
    }

    if (-not (Test-Path -Path $target -PathType Leaf)) {
        Write-Log "DIAS.rdp not found on public desktop. Nothing to remove."
        Exit 0
    }

    Remove-Item -Path $target -Force -ErrorAction Stop
    Write-Log "Removed DIAS shortcut: $target"
    Exit 0
}
catch {
    Write-Log "ERROR removing DIAS.rdp: $($_.Exception.Message)"
    Exit 1
}