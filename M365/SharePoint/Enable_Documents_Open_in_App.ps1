<#
.SYNOPSIS
    Connects to a SharePoint Online tenant and ensures a specific site-scoped feature is activated on all sites under the /sites path.

.DESCRIPTION
    This script uses PnP.PowerShell to:
      - Connect to the tenant admin site
      - Enumerate all site collections
      - Filter those that live under the /sites URL prefix
      - Connect to each site and ensure the provided site-scoped feature (by GUID) is activated
      - Implements simple retry/throttling handling for site-level operations

    The script supports interactive authentication using a registered Azure AD application (ClientID),
    and returns site-level connection objects to run PnP cmdlets against each site.

.PARAMETER Tenant
    Tenant name (the DNS prefix part of your SharePoint tenant). Example: "contoso" to form "https://contoso-admin.sharepoint.com".

.PARAMETER FeatureID
    The GUID of the site-scoped feature to enable (example: a custom feature deployed to the tenant). Default is a sample GUID.

.PARAMETER ClientID
    The Client (Application) ID of a registered Azure AD app used for interactive authentication.

.PARAMETER MaxRetries
    Maximum number of attempts per site if transient errors or throttling occur.

.PARAMETER DelaySecondsBetweenSites
    Number of seconds to wait between processing sites to reduce bursting requests.

.EXAMPLE
    .\Enable_Documents_Open_in_App.ps1 -Tenant "contoso" -FeatureID "8a4b..." -ClientID "00000000-0000-0000-0000-000000000000"

.NOTES
    ===================================================================
    Created on:    19.05.2026
    Created by:    Michele Blum
    Filename:      Enable_Documents_Open_in_App.ps1
    Requires:      PnP.PowerShell module (will be installed if missing)
    Permissions:   Tenant admin permissions required to enumerate all site collections.
    ===================================================================

.COMPONENT
    SharePoint Online / PnP PowerShell automation

.ROLE
    Tenant administrator automation to ensure a site-scoped feature is enabled across sites.

.FUNCTIONALITY
    - Bulk feature activation
    - Basic retry and throttling handling
#>

param(
    [string]$Tenant = "xxx",
    [string]$FeatureID = "8a4b8de2-6fd8-41e9-923c-c7c3c00f8295",
    [string]$ClientID = "xxx-xxx-xxx-xxx",
    [int]$MaxRetries = 3,
    [int]$DelaySecondsBetweenSites = 2
)

# Build URLs used in the script
$TenantAdminUrl = "https://$Tenant-admin.sharepoint.com"
$SitesUrlPrefix  = "https://$Tenant.sharepoint.com/sites"

# Ensure the PnP.PowerShell module is available. If not, install it for the current user.
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "PnP.PowerShell module not found. Installing..." -ForegroundColor Yellow
    Install-Module PnP.PowerShell -Scope CurrentUser -Force
}

# Connect to the tenant admin center using interactive auth and the provided ClientID.
# This allows subsequent tenant-scoped operations (like Get-PnPTenantSite).
Write-Host "Connecting to tenant admin: $TenantAdminUrl"
Connect-PnPOnline -Url $TenantAdminUrl -Interactive -ClientID $ClientID

# Retrieve all site collections (Detailed option returns additional properties).
# Note: This operation requires tenant admin privileges and can be slow for large tenants.
Write-Host "Getting all site collections..."
$allSites = Get-PnPTenantSite -Detailed

# Filter to sites under the /sites path (avoid root, personal and other managed paths if needed).
$targetSites = $allSites | Where-Object { $_.Url -like "$SitesUrlPrefix*" }

Write-Host "Found $($targetSites.Count) site(s) under /sites"

# Iterate through each target site and ensure the feature is activated.
foreach ($site in $targetSites) {
    Write-Host "----------------------------------------"
    Write-Host "Processing: $($site.Url)"

    $attempt = 0
    $succeeded = $false

    # Retry loop: handles transient errors and simple throttling retry logic.
    while (-not $succeeded -and $attempt -lt $MaxRetries) {
        try {
            $attempt++

            # Connect to the individual site and return a connection object so we can use it explicitly.
            # Using -ReturnConnection avoids changing the global connection state and is safer in loops.
            $conn = Connect-PnPOnline -Url $site.Url -Interactive -ClientID $ClientID -ReturnConnection

            # Check whether the feature is already activated at the Site (site collection) scope.
            # -ErrorAction SilentlyContinue to allow $null when not present.
            $feature = Get-PnPFeature -Scope Site -Identity $FeatureID -Connection $conn -ErrorAction SilentlyContinue

            if ($null -eq $feature) {
                Write-Host "Feature not present -- activating..." -ForegroundColor Yellow
                # Activate the feature. -Force ensures activation if minor conflicts exist.
                Enable-PnPFeature -Identity $FeatureID -Scope Site -Connection $conn -Force -ErrorAction Stop
                Write-Host "Activated on $($site.Url)" -ForegroundColor Green
            } else {
                Write-Host "Feature already active on $($site.Url)" -ForegroundColor DarkYellow
            }

            $succeeded = $true
        } catch {
            # Basic error handling: inspect the message for throttling or transient issues.
            $msg = $_.Exception.Message
            Write-Host "Error processing $($site.Url): $msg" -ForegroundColor Red

            # Detect common throttling indications (HTTP 429 or "throttl" substring).
            if ($msg -match "429" -or $msg -match "throttl") {
                if ($attempt -lt $MaxRetries) {
                    # Back off progressively: wait longer for subsequent attempts.
                    $wait = 10 * $attempt
                    Write-Host "Throttled. Waiting $wait seconds before retry (attempt $attempt of $MaxRetries)..." -ForegroundColor Yellow
                    Start-Sleep -Seconds $wait
                } else {
                    Write-Host "Max retries reached for $($site.Url). Skipping." -ForegroundColor Red
                }
            } elseif ($attempt -lt $MaxRetries) {
                # Generic retry for transient failures.
                Write-Host "Retrying in 5 seconds (attempt $attempt of $MaxRetries)..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
            } else {
                Write-Host "Max retries reached for $($site.Url). Skipping." -ForegroundColor Red
            }
        }
    }

    # Pause a little between processing sites to reduce request bursts against the service.
    Start-Sleep -Seconds $DelaySecondsBetweenSites
}

Write-Host "Processing complete." -ForegroundColor Green
