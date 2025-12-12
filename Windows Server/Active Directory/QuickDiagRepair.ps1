<#
.SYNOPSIS
    Quick diagnostics and secure channel repair helper for a domain-joined Windows computer.

.DESCRIPTION
    This script performs quick diagnostics (DNS resolution, ICMP reachability, secure channel check,
    local time and time skew versus a specified domain controller) and provides helper functions to repair
    a broken computer account secure channel. It attempts Test-ComputerSecureChannel -Repair (when credentials
    are provided), then falls back to Reset-ComputerMachinePassword against a specified DC. If those steps fail
    and you accept a reboot, it can rejoin the machine to the domain (temporary workgroup followed by Add-Computer).
    The script is intended to be run locally on the affected machine or remotely via an automation job.

.INPUTS
    None directly via the pipeline. Parameters are provided via named parameters to the script.

.OUTPUTS
    Text output to host describing each step and results.

.NOTES
   ===========================================================================
     Created on:    12.12.2025
     Created by:    Michele Blum
     Filename:      QuickDiagRepair.ps1
   ===========================================================================

   - Run with elevated privileges for repair actions that change machine account or join domain.
   - Avoid hard-coding plaintext passwords; omit the -Password parameter to be prompted securely.

.COMPONENT
    Active Directory / Windows Time / Network diagnostics

.ROLE
    Domain join troubleshooting, machine account repair

.FUNCTIONALITY
    - DNS resolution for a domain controller
    - Ping (ICMP) reachability check
    - Test secure channel status
    - Compare local time to DC (w32time)
    - Attempt secure channel repair using provided credentials
    - Attempt machine password reset against a DC
    - Optionally rejoin domain (will restart machine)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Domain = "contoso.com",

    [Parameter(Mandatory=$false)]
    [string]$DC = "dc1.contoso.com",

    [Parameter(Mandatory=$false)]
    [string]$User = "CONTOSO\AdminUser",

    # If you prefer not to hard-code a plaintext password, omit this parameter - the script will prompt for credentials.
    [Parameter(Mandatory=$false)]
    [string]$Password = "",

    [Parameter(Mandatory=$false)]
    [switch]$ForceRejoin,   # If set, attempt domain rejoin when reset fails (will restart computer)

    [Parameter(Mandatory=$false)]
    [switch]$WhatIfMode     # Use -WhatIfMode to simulate rejoin step (Add-Computer supports -WhatIf)
)

# -------------------------
# Helper: create PSCredential
# -------------------------
function Get-TargetCredential {
    param (
        [string]$UserName,
        [string]$PlainPassword
    )
    # Returns: PSCredential or $null
    if ([string]::IsNullOrEmpty($UserName)) {
        Write-Verbose "No username provided for credential creation."
        return $null
    }

    if (-not [string]::IsNullOrEmpty($PlainPassword)) {
        try {
            Write-Verbose "Creating credential from provided plaintext password."
            $sec = ConvertTo-SecureString -String $PlainPassword -AsPlainText -Force
            return New-Object System.Management.Automation.PSCredential($UserName, $sec)
        } catch {
            Write-Warning "Failed to create credential from plain password: $_"
            return $null
        }
    }

    # No plain password provided: prompt for credential (safer)
    try {
        Write-Verbose "Prompting for credentials interactively."
        return Get-Credential -UserName $UserName -Message "Enter password for $UserName"
    } catch {
        Write-Warning "Get-Credential failed or was cancelled: $_"
        return $null
    }
}

# -------------------------
# Quick diagnostics function
# -------------------------
function Invoke-QuickDiagnostics {
    param(
        [string]$DomainController
    )

    Write-Output "=== Quick Diagnostics ==="
    Write-Output "Resolve domain controller name: $DomainController"
    try {
        Resolve-DnsName -Name $DomainController -ErrorAction Stop | Format-List -Force
    } catch {
        Write-Warning "Resolve-DnsName failed: $_"
    }

    Write-Output ""
    Write-Output "Ping DC:"
    try {
        Test-Connection -ComputerName $DomainController -Count 2 -ErrorAction Stop | Select-Object Address, ResponseTime, StatusCode
    } catch {
        Write-Warning "Test-Connection failed (ICMP may be blocked or DC unreachable): $_"
    }

    Write-Output ""
    Write-Output "Check secure channel status (no credentials):"
    try {
        Test-ComputerSecureChannel -Verbose -ErrorAction Stop
    } catch {
        Write-Warning "Test-ComputerSecureChannel (no credentials) returned error: $_"
    }

    Write-Output ""
    Write-Output "Get local computer name and current time:"
    Write-Output "ComputerName: $env:COMPUTERNAME"
    Get-Date

    Write-Output ""
    Write-Output "Check time against DC (w32time):"
    try {
        w32tm /stripchart /computer:$DomainController /samples:1 2>&1
    } catch {
        Write-Warning "w32tm stripchart failed: $_"
    }

    Write-Output "=== End Quick Diagnostics ==="
    Write-Output ""
}

# -------------------------
# Repair secure channel
# -------------------------
function Repair-SecureChannel {
    param(
        [System.Management.Automation.PSCredential]$Credential,
        [string]$DCName
    )

    if (-not $Credential) {
        Write-Warning "No credential provided. Cannot attempt repair that requires domain credentials."
        return $false
    }

    Write-Output "Attempting Test-ComputerSecureChannel -Repair ..."
    $repair = $false
    try {
        $repair = Test-ComputerSecureChannel -Repair -Credential $Credential -Verbose -ErrorAction Stop
        Write-Output "Test-ComputerSecureChannel returned: $repair"
    } catch {
        Write-Warning "Test-ComputerSecureChannel -Repair failed: $_"
        $repair = $false
    }

    if ($repair) {
        Write-Output "Secure channel repaired successfully via Test-ComputerSecureChannel -Repair."
        return $true
    }

    Write-Output "Attempting Reset-ComputerMachinePassword against DC $DCName ..."
    try {
        Reset-ComputerMachinePassword -Credential $Credential -Server $DCName -ErrorAction Stop
        Write-Output "Reset-ComputerMachinePassword succeeded."
    } catch {
        Write-Warning "Reset-ComputerMachinePassword failed: $_"
        return $false
    }

    Write-Output "Re-checking secure channel status:"
    try {
        $final = Test-ComputerSecureChannel -Verbose -ErrorAction Stop
        Write-Output "Test-ComputerSecureChannel final check returned: $final"
        return [bool]$final
    } catch {
        Write-Warning "Final Test-ComputerSecureChannel failed: $_"
        return $false
    }
}

# -------------------------
# Rejoin domain (destructive: will restart)
# -------------------------
function Rejoin-Domain {
    param(
        [string]$TargetDomain,
        [System.Management.Automation.PSCredential]$Credential,
        [switch]$WhatIfSwitch
    )

    if (-not $Credential) {
        Write-Warning "No credential provided. Cannot rejoin domain."
        return $false
    }

    Write-Output "Leaving domain by joining WORKGROUP temporarily ..."
    try {
        if ($WhatIfSwitch) {
            Add-Computer -Workgroup "WORKGROUP" -Force -ErrorAction Stop -WhatIf
        } else {
            Add-Computer -Workgroup "WORKGROUP" -Force -ErrorAction Stop
        }
        Write-Output "Temporary workgroup join step completed (or simulated with -WhatIf)."
    } catch {
        Write-Warning "Add-Computer (workgroup) failed (continuing to attempt domain join): $_"
    }

    Write-Output "Joining domain $TargetDomain ..."
    try {
        if ($WhatIfSwitch) {
            Add-Computer -DomainName $TargetDomain -Credential $Credential -Force -Options JoinWithNewName -ErrorAction Stop -WhatIf
        } else {
            Add-Computer -DomainName $TargetDomain -Credential $Credential -Force -Options JoinWithNewName -ErrorAction Stop
        }
        Write-Output "Domain join was initiated successfully."
    } catch {
        Write-Warning "Add-Computer (domain) failed: $_"
        return $false
    }

    if (-not $WhatIfSwitch) {
        Write-Output "Restarting now..."
        Restart-Computer -Force
    } else {
        Write-Output "Simulated rejoin (WhatIf). No restart performed."
    }

    return $true
}

# -------------------------
# Main script flow
# -------------------------
Write-Verbose "Script started. Parameters: Domain=$Domain, DC=$DC, User=$User, ForceRejoin=$ForceRejoin, WhatIfMode=$WhatIfMode"

# 1) Quick diagnostics
Invoke-QuickDiagnostics -DomainController $DC

# 2) If credentials provided or user specified, try repair
$credentialObj = $null
if (-not [string]::IsNullOrEmpty($User)) {
    $credentialObj = Get-TargetCredential -UserName $User -PlainPassword $Password
}

if ($credentialObj) {
    $repairResult = Repair-SecureChannel -Credential $credentialObj -DCName $DC
    if ($repairResult) {
        Write-Output "Secure channel is healthy after repair steps."
    } else {
        Write-Warning "Secure channel repair steps failed."

        if ($ForceRejoin) {
            Write-Output "ForceRejoin is set. Attempting domain rejoin (this will restart the computer)."
            $rejoinResult = Rejoin-Domain -TargetDomain $Domain -Credential $credentialObj -WhatIfSwitch:$WhatIfMode
            if (-not $rejoinResult) {
                Write-Warning "Domain rejoin failed or was simulated and may require manual intervention."
            }
        } else {
            Write-Output "If the previous steps failed and you can accept a reboot, run script with -ForceRejoin to rejoin the domain (this will reboot)."
        }
    }
} else {
    Write-Output "No domain credential available. Skipping repair steps that require credentials."
    Write-Output "To attempt repair, re-run and provide -User and -Password or omit -Password to be prompted securely."
}

Write-Output "Script completed."
# End of script.