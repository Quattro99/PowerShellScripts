<#
.SYNOPSIS
    Tracks the expiration of Entra ID App Registration secrets and certificates and sends email warnings before they expire.
.DESCRIPTION
    This script monitors the expiration dates of client secrets and certificates associated with Entra ID App Registrations.
    Warning emails are sent to specified recipients if any secrets or certificates are about to expire within a defined period.
.INPUTS
    None.
.OUTPUTS
    This script outputs logs to the console and sends email notifications via Microsoft Graph API.
.NOTES
   ===========================================================================
     Created on:    25.09.2025
     Created by:    Michele Blum
     Filename:      TrackEntraIDAppRegSecretsAndCerts.ps1
   ===========================================================================
.COMPONENT
    PowerShell, Microsoft Graph API
.ROLE
    Monitor the expiry of secrets and certificates for Entra ID App Registrations
.FUNCTIONALITY
    Tracks expiration dates and sends notifications for expiring client secrets and certificates.
#>

# ================================
# Configuration
# Define parameters for the script
# ================================
$DaysBeforeExpiry   = 30  # Number of days before expiry to trigger a warning
$FromEmail          = "xxx@duo-infernale.ch" # Sender email (also used as sending user via Graph)
$ToEmail            = "xxx@duo-infernale.ch" # Recipient email
$TenantId           = "xxx" # Tenant ID
$ClientId           = "xxx" # Client ID
$ClientSecret       = "xxx" # Client Secret

# ================================
# Authentication with Microsoft Graph
# Obtain an access token using Client Credentials Flow
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
# Fetch all App Registrations
# Retrieve all applications from Entra ID
# ================================
$Applications = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/applications" `
                                  -Headers @{ Authorization = "Bearer $AccessToken" } `
                                  -Method Get

# Get Today's Date for comparison
$Today = Get-Date

# Debugging: Output the number of applications retrieved
Write-Output "Number of App Registrations found: $($Applications.value.Count)"

# ================================
# Check Secrets and Certificates
# Verify the expiry dates of secrets and certificates
# ================================
foreach ($App in $Applications.value) {
    Write-Output "Checking App: $($App.displayName)"
    
    # Check Client Secrets
    $Secrets = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/applications/$($App.id)/passwordCredentials" `
                                 -Headers @{ Authorization = "Bearer $AccessToken" } `
                                 -Method Get
    foreach ($Secret in $Secrets.value) {
        $ExpiryDate = Get-Date $Secret.endDateTime  # Convert the expiry date
        $DaysToExpiry = ($ExpiryDate - $Today).Days  # Calculate days to expiry

        if ($DaysToExpiry -lt $DaysBeforeExpiry) {
            # Prepare notification email
            $Subject = "Warning: $($App.displayName) Client Secret Expiring Soon"
            $Body = "The client secret for the app '$($App.displayName)' expires in $DaysToExpiry days (on $ExpiryDate) or is already expired. Please update it."

            # Debugging: Output the email content as JSON
            $EmailBody = @{
                message = @{
                    subject = $Subject
                    body = @{
                        contentType = "Text"
                        content = $Body
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

            # Send Email with error handling
            try {
                $Response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$FromEmail/sendMail" `
                                               -Headers @{ Authorization = "Bearer $AccessToken" } `
                                               -Method POST `
                                               -ContentType "application/json" `
                                               -Body $EmailBodyJson
                Write-Output "Email sent successfully!"
            } catch {
                Write-Output "Error sending email:"
                Write-Output $_.Exception.Message
            }
        }
    }

    # Check Certificates
    $Certificates = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/applications/$($App.id)/keyCredentials" `
                                      -Headers @{ Authorization = "Bearer $AccessToken" } `
                                      -Method Get
    foreach ($Cert in $Certificates.value) {
        $ExpiryDate = Get-Date $Cert.endDateTime  # Convert the expiry date
        $DaysToExpiry = ($ExpiryDate - $Today).Days  # Calculate days to expiry

        if ($DaysToExpiry -lt $DaysBeforeExpiry) {
            # Prepare notification email
            $Subject = "Warning: $($App.displayName) Certificate Expiring Soon"
            $Body = "The certificate for the app '$($App.displayName)' expires in $DaysToExpiry days (on $ExpiryDate) or is already expired. Please update it."


            # Debugging: Output the email content as JSON
            $EmailBody = @{
                message = @{
                    subject = $Subject
                    body = @{
                        contentType = "Text"
                        content = $Body
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

            # Send Email with error handling
            try {
                $Response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$FromEmail/sendMail" `
                                               -Headers @{ Authorization = "Bearer $AccessToken" } `
                                               -Method POST `
                                               -ContentType "application/json" `
                                               -Body $EmailBodyJson
                Write-Output "Email sent successfully!"
            } catch {
                Write-Output "Error sending email:"
                Write-Output $_.Exception.Message
            }
        }
    }
}