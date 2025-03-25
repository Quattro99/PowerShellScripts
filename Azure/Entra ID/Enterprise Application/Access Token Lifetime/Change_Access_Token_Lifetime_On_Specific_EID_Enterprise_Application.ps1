<#
.SYNOPSIS
    This script creates and binds a token lifetime policy to a specified application in Entra ID.

.DESCRIPTION
    This script connects to Microsoft Graph and creates a token lifetime policy that sets the access token lifetime to 12 hours.
    It then binds this policy to a specified application in Microsoft Entra ID.

.INPUTS
    This script accepts parameters such as the display name for the token lifetime policy, the access token lifetime,
    and the application ID to which the policy is bound.

.OUTPUTS
    The script outputs the details of the created token lifetime policy and its binding to the specified application.

.NOTES
   ===========================================================================
	 Created on:   	21.03.2025
	 Created by:   	Michele Blum
	 Filename:     	Change_Access_Token_Lifetime_On_Specific_EID_Enterprise_Application.ps1
	===========================================================================
.COMPONENT
    Microsoft Graph API

.ROLE
    Token Lifetime Management

.FUNCTIONALITY
    - Connects to Microsoft Graph.
    - Creates a token lifetime policy.
    - Binds the policy to a specified Entra ID application.
#>

# Connect to Microsoft Graph with required scopes
$scopes = 'Policy.ReadWrite.ApplicationConfiguration', 'Policy.Read.All', 'Application.ReadWrite.All'
Connect-MgGraph -Scopes $scopes

# Import required modules
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.Applications

# Function to create a token lifetime policy
function Create-TokenLifetimePolicy {
    param (
        [string]$DisplayName,
        [string]$AccessTokenLifetime,
        [bool]$IsOrganizationDefault = $false
    )
   
    # Define the policy parameters
    $definitionJson = @(
        "{""TokenLifetimePolicy"":{""Version"":1,""AccessTokenLifetime"":""$AccessTokenLifetime""}}"
    )

    $params = @{
        DisplayName            = $DisplayName
        Definition             = $definitionJson
        IsOrganizationDefault   = $IsOrganizationDefault
    }

    # Create the token lifetime policy
    try {
        $policy = New-MgPolicyTokenLifetimePolicy -BodyParameter $params
        Write-Host "Token lifetime policy '$DisplayName' created successfully with ID: $($policy.Id)"
        return $policy
    } catch {
        Write-Error "Error creating token lifetime policy: $_"
        return $null
    }
}

# Create a token lifetime policy for access tokens valid for 12 hours
$tokenLifetimePolicy = Create-TokenLifetimePolicy -DisplayName "NAME" -AccessTokenLifetime "12:00:00"
### CHANGE THESE VALUES TO YOUR NEEDS ###

# Function to bind a token lifetime policy to an application
function Bind-ApplicationTokenLifetimePolicy {
    param (
        [string]$ApplicationId,
        [string]$PolicyId
    )

    # Construct the body parameter for binding the policy
    $params = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/policies/tokenLifetimePolicies/$PolicyId"
    }

    # Bind the token lifetime policy to the application
    try {
        New-MgApplicationTokenLifetimePolicyByRef -ApplicationId $ApplicationId -BodyParameter $params
        Write-Host "Policy '$PolicyId' successfully bound to application '$ApplicationId'."
    } catch {
        Write-Error "Error binding policy to application: $_"
    }
}

# Define the application ID (update as necessary)
$applicationId = 'xxx-xxx-xxx-xxx-xxx'
### CHANGE THESE VALUES TO YOUR NEEDS ###

$policyId = $tokenLifetimePolicy.Id  # Assuming the policy was created successfully

# Bind the created token lifetime policy to the specified application
if ($tokenLifetimePolicy -and $policyId) {
    Bind-ApplicationTokenLifetimePolicy -ApplicationId $applicationId -PolicyId $policyId
}

# Retrieve and display the token lifetime policy bound to the application
try {
    $boundPolicy = Get-MgApplicationTokenLifetimePolicyByRef -ApplicationId $applicationId
    $boundPolicy | Format-Table -AutoSize
} catch {
    Write-Error "Error retrieving bound token lifetime policy: $_"
}