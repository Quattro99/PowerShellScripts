<#
.SYNOPSIS
    Tracks the expiration of Entra ID enterprise application SAML certificates and sends email warnings before they expire.
.DESCRIPTION
    This script tracks the expiration dates of SAML SSO certificates associated with Entra ID enterprise applications.
    A warning email will be sent to the specified recipients if a certificate is about to expire within a specified period.
.INPUTS
    None.
.OUTPUTS
    This script outputs logs to the console and sends email notifications via Microsoft Graph API.
.NOTES
   ===========================================================================
     Created on:    25.09.2025
     Created by:    Michele Blum
     Filename:      TrackEntraIDEntAppSAMLCerts.ps1
   ===========================================================================
.COMPONENT
    PowerShell, Microsoft Graph API
.ROLE
    Monitor Expiry of SAML Certificates for Entra ID Enterprise Applications
.FUNCTIONALITY
    Monitors SAML SSO certificate expirations and sends email notifications.
#>

# ================================
# Configuration
# Set parameters for the script
# ================================
$DaysBeforeExpiry   = 30 # Number of days before expiry to send warning
$FromEmail          = "xxx@duo-infernale.ch" # Sender email (also used as sending user via Graph)
$ToEmail            = "xxx@duo-infernale.ch" # Recipient email
$TenantId           = "xxx" # Tenant ID
$ClientId           = "xxx" # Client ID
$ClientSecret       = "xxx" # Client Secret

# ================================
# Authentication with Microsoft Graph (Client Credentials Flow)
# Obtain an access token to authenticate against the Microsoft Graph API
# ================================
$Body = @{
    client_id     = $ClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $ClientSecret
    grant_type    = "client_credentials"
}

$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
                    -Method Post -Body $Body -ContentType "application/x-www-form-urlencoded"
$AccessToken = $TokenResponse.access_token  # Store the access token

# ================================
# Fetch all Service Principals (Enterprise Apps) using Pagination
# Retrieve all the Service Principals from the Graph API
# ================================
$ServicePrincipals = @()
$Uri = "https://graph.microsoft.com/v1.0/servicePrincipals"
do {
    Write-Output "Fetching: $Uri"
    $Response = Invoke-RestMethod -Uri $Uri -Headers @{ Authorization = "Bearer $AccessToken" } -Method Get
    $ServicePrincipals += $Response.value  # Accumulate the results
    $Uri = $Response.'@odata.nextLink'  # Handle pagination by following the next link
} while ($Uri)

Write-Output "Number of Service Principals found: $($ServicePrincipals.Count)"  # Output the number of Service Principals found

$Today = Get-Date

# ================================
# Check SAML SSO certificates (keyCredentials) for each Service Principal
# ================================
foreach ($sp in $ServicePrincipals) {
    Write-Output "Checking Service Principal: $($sp.displayName)"

    $Certificates = $sp.keyCredentials
    if ($Certificates -and $Certificates.Count -gt 0) {
        foreach ($Cert in $Certificates) {
            # Convert expiry date and calculate remaining days
            $ExpiryDate   = Get-Date $Cert.endDateTime
            $DaysToExpiry = ($ExpiryDate - $Today).Days  # Calculate the number of days until expiry
            Write-Output "Certificate for '$($sp.displayName)' expires on: $ExpiryDate (in $DaysToExpiry days)"

            if ($DaysToExpiry -lt $DaysBeforeExpiry -and $DaysToExpiry -gt 0) {
                # Add unique timestamp to subject to avoid email grouping
                $Subject     = "Warning: [$($sp.displayName)] SAML SSO Certificate Expiring Soon"
                $BodyContent = "The SAML SSO certificate for the app '$($sp.displayName)' will expire in $DaysToExpiry days (on $ExpiryDate) or is already expired. Please update it."

                # Compose JSON payload for sending email via Microsoft Graph
                $EmailBody = @{
                    message = @{
                        subject = $Subject
                        body    = @{
                            contentType = "Text"
                            content     = $BodyContent
                        }
                        toRecipients = @(@{
                            emailAddress = @{
                                address = $ToEmail
                            }
                        })
                    }
                }
                $EmailBodyJson = $EmailBody | ConvertTo-Json -Depth 10 -Compress
                Write-Output "Sending the following JSON payload to Microsoft Graph:"
                Write-Output $EmailBodyJson

                # Send email with try-catch for error handling
                try {
                    $ResponseMail = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$FromEmail/sendMail" `
                        -Headers @{ Authorization = "Bearer $AccessToken" } `
                        -Method POST `
                        -ContentType "application/json" `
                        -Body $EmailBodyJson
                    Write-Output "Email for '$($sp.displayName)' sent successfully!"  # Confirm successful email send
                } catch {
                    Write-Output "Error sending email for '$($sp.displayName)':"  # Log detailed error message
                    Write-Output $_.Exception.Message
                }
            }
        }
    } else {
        Write-Output "No keyCredentials found for '$($sp.displayName)'."  # Log when no certificates are found
    }
}