##https://danielchronlund.com/2023/06/21/automatic-azure-ad-pim-role-micromanagement-based-on-role-impact/

# Authenticate to Microsoft Graph:
Connect-MgGraph -Scopes "RoleManagement.ReadWrite.Directory"

# set the recipient email address for notifications
$InputRecipients = @("michele.blum@duo-infernale.ch","flavio.meyer@duo-infernale.ch","ict-support@duo-infernale.ch")

# Load CSV file content:
$CsvContent = Import-Csv -Delimiter ',' -Path 'C:\Users\michele.blum\OneDrive - TurnKey Services AG\Dokumente\EntraIDRoles.csv'

# Get all Entra ID role templates available in tenant:
$EntraIDRoleTemplates = Get-MgDirectoryRoleTemplate | Select-Object DisplayName, Description, Id | Sort-Object DisplayName

# For each role mentioned in the CSV file, set role configuration in Entra ID:
foreach ($Role in $CsvContent) {
    
    # Get the role managemnet policy assignment for this role:
    $PolicyAssignment = Get-MgPolicyRoleManagementPolicyAssignment -Filter "scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$(($EntraIDRoleTemplates | Where-Object DisplayName -eq $Role.EntraIDRole).Id)'" -ExpandProperty "policy(`$expand=rules)"

    # Get the role management policy that's been assigned:
    $Policy = Get-MgPolicyRoleManagementPolicy -UnifiedRoleManagementPolicyId $PolicyAssignment.PolicyId

    # Get all policy rules belonging to this role management policy:
    $PolicyRules = Get-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $Policy.Id

    # Configure rule: 'Expiration_EndUser_Assignment':
    $params = @{
        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule"
        Id = "Expiration_EndUser_Assignment"
        isExpirationRequired = $false
        maximumDuration = "PT$($Role.MaximumActivationDurationHours)H"
        Target = @{
            "@odata.type" = "microsoft.graph.unifiedRoleManagementPolicyRuleTarget"
            Caller = "EndUser"
            Operations = @(
                "all"
                )
            Level = "Assignment"
            InheritableSettings = @(
            )
            EnforcedSettings = @(
        )
        }
    }

    Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $Policy.Id -UnifiedRoleManagementPolicyRuleId 'Expiration_EndUser_Assignment' -BodyParameter $params

    # Configure rule: 'Enablement_EndUser_Assignment':
    $EnabledRules = @()
    if ($Role.RequireMFAOnActivation -eq 'True' -and $Role.RequireJustificationOnActivation -eq 'True') {
        $EnabledRules = "MultiFactorAuthentication", "Justification"
    } elseif ($Role.RequireMFAOnActivation -eq 'True') {
        $EnabledRules = "MultiFactorAuthentication"
    } elseif ($Role.RequireJustificationOnActivation -eq 'True') {
        $EnabledRules = "Justification"
    } else {
        $EnabledRules = @()
    }

    $params = @{
        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyEnablementRule"
        Id = "Enablement_EndUser_Assignment"
        enabledRules = $EnabledRules
        Target = @{
            "@odata.type" = "microsoft.graph.unifiedRoleManagementPolicyRuleTarget"
            Caller = "EndUser"
            Operations = @(
                "all"
                )
            Level = "Assignment"
            InheritableSettings = @(
            )
            EnforcedSettings = @(
        )
        }
    }

    Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $Policy.Id -UnifiedRoleManagementPolicyRuleId 'Enablement_EndUser_Assignment' -BodyParameter $params

    # Configure rule: 'Notification_Admin_Admin_Eligibility':
    $NotificationAdminAdminEligibility = $true
    if ($Role.ImpactLevel -eq 'High') {
        $recipients = $InputRecipients
    
    # Assuming you define or update $recipients here for 'High' impact level
    } elseif ($Role.ImpactLevel -eq 'Medium' -or $Role.ImpactLevel -eq 'Low') {
        $recipients = @()
    # For Medium and Low, we already set $NotificationAdminEligibility to $false and $recipients to empty above
    # No additional configuration needed here
    }

    $params = @{
        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule"
        Id = "Notification_Admin_Admin_Eligibility"
        isDefaultRecipientsEnabled = $NotificationAdminEligibility
        notificationType = "Email"
        recipientType = "Admin"
        notificationLevel = "All"
        notificationRecipients = $recipients
        Target = @{
            "@odata.type" = "microsoft.graph.unifiedRoleManagementPolicyRuleTarget"
            Caller = "Admin"
            Operations = @(
                "all"
                )
            Level = "Eligibility"
            InheritableSettings = @(
            )
            EnforcedSettings = @(
        )
        }
        }

    Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $Policy.Id -UnifiedRoleManagementPolicyRuleId 'Notification_Admin_Admin_Eligibility' -BodyParameter $params
    
    # Configure rule: 'Notification_Admin_Admin_Assignment'
    $NotificationAdminAssignment = $true
    if ($Role.ImpactLevel -eq 'High') {
        $recipients = $InputRecipients
    
    # Assuming you define or update $recipients here for 'High' impact level
    } elseif ($Role.ImpactLevel -eq 'Medium' -or $Role.ImpactLevel -eq 'Low') {
        $recipients = @()
    # For Medium and Low, we already set $NotificationAdminEligibility to $false and $recipients to empty above
    # No additional configuration needed here
    }

    $params = @{
        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule"
        Id = "Notification_Admin_Admin_Assignment"
        isDefaultRecipientsEnabled = $NotificationAdminAssignment
        notificationType = "Email"
        recipientType = "Admin"
        notificationLevel = "All"
        notificationRecipients = $recipients
        Target = @{
            "@odata.type" = "microsoft.graph.unifiedRoleManagementPolicyRuleTarget"
            Caller = "Admin"
            Operations = @(
                "all"
                )
            Level = "Assignment"
            InheritableSettings = @(
            )
            EnforcedSettings = @(
        )
        }
        }

    Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $Policy.Id -UnifiedRoleManagementPolicyRuleId 'Notification_Admin_Admin_Assignment' -BodyParameter $params

    # Configure rule: 'Notification_Admin_EndUser_Assignment' 
    $NotificationAdminEndUserAssignment = $true
    if ($Role.ImpactLevel -eq 'High') {
        $recipients = $InputRecipients
    
    # Assuming you define or update $recipients here for 'High' impact level
    } elseif ($Role.ImpactLevel -eq 'Medium' -or $Role.ImpactLevel -eq 'Low') {
        $recipients = @()
    # For Medium and Low, we already set $NotificationAdminEligibility to $false and $recipients to empty above
    # No additional configuration needed here
    }

    $params = @{
        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyNotificationRule"
        Id = "Notification_Admin_EndUser_Assignment"
        isDefaultRecipientsEnabled = $NotificationAdminEndUserAssignment
        notificationType = "Email"
        recipientType = "Admin"
        notificationLevel = "All"
        notificationRecipients = $recipients
        Target = @{
            "@odata.type" = "microsoft.graph.unifiedRoleManagementPolicyRuleTarget"
            Caller = "EndUser"
            Operations = @(
                "all"
                )
            Level = "Eligibility"
            InheritableSettings = @(
            )
            EnforcedSettings = @(
        )
        }
        }
    
        Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $Policy.Id -UnifiedRoleManagementPolicyRuleId 'Notification_Admin_EndUser_Assignment' -BodyParameter $params

    # Configure rule: 'Expiration_Admin_Eligibility':
    $ExpirationRequired = $true
    if ($Role.AllowPermanentActiveAssignment -eq 'True') {
        $ExpirationRequired = $false
    } else {
        # This value can be set to true if you want to enforce expiration for all roles, which are eligible.
        $ExpirationRequired = $false 
    }

    $params = @{
        "@odata.type" = "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule"
        Id = "Expiration_Admin_Eligibility"
        isExpirationRequired = $ExpirationRequired
        maximumDuration = "P30D"
        Target = @{
            "@odata.type" = "microsoft.graph.unifiedRoleManagementPolicyRuleTarget"
            Caller = "EndUser"
            Operations = @(
                "all"
                )
            Level = "Assignment"
            InheritableSettings = @(
            )
            EnforcedSettings = @(
        )
        }
    }

    Update-MgPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $Policy.Id -UnifiedRoleManagementPolicyRuleId 'Expiration_Admin_Eligibility' -BodyParameter $params
    
}
