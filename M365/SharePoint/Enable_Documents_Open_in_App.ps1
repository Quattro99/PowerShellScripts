param(
    [string]$Tenant = "xxx",
    [string]$FeatureID = "8a4b8de2-6fd8-41e9-923c-c7c3c00f8295",
    [string]$ClientID = "xxx-xxx-xxx-xxx"
    [int]$MaxRetries = 3,
    [int]$DelaySecondsBetweenSites = 2
)

$TenantAdminUrl = "https://$Tenant-admin.sharepoint.com"
$SitesUrlPrefix  = "https://$Tenant.sharepoint.com/sites"

# Ensure PnP.PowerShell available
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Install-Module PnP.PowerShell -Scope CurrentUser -Force
}

Write-Host "Connect to tenant admin: $TenantAdminUrl"
Connect-PnPOnline -Url $TenantAdminUrl -Interactive -ClientID $ClientID

Write-Host "Getting all site collections..."
$allSites = Get-PnPTenantSite -Detailed
$targetSites = $allSites | Where-Object { $_.Url -like "$SitesUrlPrefix*" }

Write-Host "Found $($targetSites.Count) site(s) under /sites"

foreach ($site in $targetSites) {
    Write-Host "----------------------------------------"
    Write-Host "Processing: $($site.Url)"

    $attempt = 0
    $succeeded = $false

    while (-not $succeeded -and $attempt -lt $MaxRetries) {
        try {
            $attempt++

            # Connect to the site and get a connection object
            $conn = Connect-PnPOnline -Url $site.Url -Interactive -ClientID $ClientID -ReturnConnection

            # Use the connection object with the cmdlets
            $feature = Get-PnPFeature -Scope Site -Identity $FeatureID -Connection $conn -ErrorAction SilentlyContinue

            if ($null -eq $feature) {
                Write-Host "Feature not present -- activating..." -ForegroundColor Yellow
                Enable-PnPFeature -Identity $FeatureID -Scope Site -Connection $conn -Force -ErrorAction Stop
                Write-Host "Activated on $($site.Url)" -ForegroundColor Green
            } else {
                Write-Host "Feature already active on $($site.Url)" -ForegroundColor DarkYellow
            }

            $succeeded = $true
        } catch {
            $msg = $_.Exception.Message
            Write-Host "Error processing $($site.Url): $msg" -ForegroundColor Red

            if ($msg -match "429" -or $msg -match "throttl") {
                if ($attempt -lt $MaxRetries) {
                    $wait = 10 * $attempt
                    Write-Host "Throttled. Waiting $wait seconds before retry (attempt $attempt of $MaxRetries)..." -ForegroundColor Yellow
                    Start-Sleep -Seconds $wait
                } else {
                    Write-Host "Max retries reached for $($site.Url). Skipping." -ForegroundColor Red
                }
            } elseif ($attempt -lt $MaxRetries) {
                Write-Host "Retrying in 5 seconds (attempt $attempt of $MaxRetries)..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
            } else {
                Write-Host "Max retries reached for $($site.Url). Skipping." -ForegroundColor Red
            }
        }
    }

    Start-Sleep -Seconds $DelaySecondsBetweenSites
}

Write-Host "Processing complete." -ForegroundColor Green
