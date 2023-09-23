<#
.Synopsis
  The script is designed to automatically apply recommended settings for EOP and MDO to a customer's Office 365 tenant.x
.DESCRIPTION
  The script aims to configure various security settings to enhance the security posture of the Office 365 environment, following Microsoft's best practices.
.INPUTS
   The script references two external URLs for additional information and context on the recommended settings:
   - https://call4cloud.nl/2020/07/lock-stock-and-office-365-atp-automation/
   - https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide
.OUTPUTS
   The script applies specific security settings in EOP and MDO for the target tenant. However, it does not generate any direct output.
.NOTES
   ===========================================================================
	 Created on:   	20.09.2023
	 Created by:   	Michele Blum
	 Filename:     	ach-standard-auto-mdo_eop.ps1
	===========================================================================
.COMPONENT
   The script utilizes the Exchange Online Management module to interact with Exchange Online.
.ROLE
   The script is relevant for roles related to Security, Exchange Online and Microsoft Defender.
.FUNCTIONALITY
   The primary functionality of the script is to automatically deploy standard Microsoft best-practice settings for EOP and MDO to a customer's Office 365 tenant. These settings enhance email security and protection against threats.
   The script performs a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Office 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
   This script is a valuable tool for administrators tasked with securing an Office 365 environment efficiently and in line with recommended security practices
#>


#----- Local Variables -----#
# Name of the PowerShell module to isntall & import
$module = "ExchangeOnlineManagement"

# csa user 
## !!!Please change before use it!!!
$csa = "aadm-michele.blum@vqjtg.onmicrosoft.com"

# Connect to a customer tenant over the onmicrosoft domain via GDAP permissions
## !!!Please change before use it!!!
$custonmicrosoft = "customer.onmicrosoft.com"

# Fill all accepted domains of the tenant in a variable
$domains = Get-AcceptedDomain 

# Fill all the accepted domain names (just the names) of the tenant in a variable
$domainname = $domains.name


#----- main-function -----#
## !!! Please change the function before running. Not every fucntion can be run on every tenant!!!
### Change array of the $domain variable
function main {
   authentication
   enableorgcustomization
   defaultsharingpermission
   adminauditlog
   disableimappop
   disableexternalforwarding
}


#----- authentication-function -----#
function authentication {
# Check if the PowerShell module is installed on the local computer
If (-not (Get-Module -ListAvailable -Name $module)) {

   Write-Host "Exchange Online Management Module not installed. Module will be installed"

   # Install the module, if not installed, to the scope of the currentuser
   Install-Module $module -Scope CurrentUser -Force

   # Import the module
   Import-Module $module

   # Connect to the exo tenant with your exo admin and security admin (gdap organization)
   Connect-ExchangeOnline -UserPrincipalName $csa # -DelegatedOrganization $custonmicrosoft
   }

Else {

   Write-Host "Exchange Online Management Module already installed."

   # Import the module
   Import-Module $module

   # Connect to the exo tenant with your exo admin and security admin (gdap organization)
   Connect-ExchangeOnline -UserPrincipalName $csa # -DelegatedOrganization $custonmicrosoft
   }
   
}


#----- enableorgcustomization-function -----#
function enableorgcustomization {
   If (Get-OrganizationConfig | Where-Object isDehydrated -eq $true)
   {
      Write-Host "Organization Customization is not enabled. Changing the setting."
      Enable-OrganizationCustomization
   }
   Else {
      Write-Host "Organization Customization already enabled."
   }
}


#----- defaultsharingpermission-function -----#
function defaultsharingpermission {
# Default Sharing Policy Calendar 
## Double check this setting with the customer and the tenant (German vs. English)
   Set-SharingPolicy -Identity "Standardfreigaberichtlinie" -Domains @{Remove="Anonymous:CalendarSharingFreeBusyReviewer", "Anonymous:CalendarSharingFreeBusySimple", "Anonymous:CalendarSharingFreeBusyDetail"} 
   Set-SharingPolicy -Identity "Standardfreigaberichtlinie" -Domains "*:CalendarSharingFreeBusySimple" 
}


#----- adminauditlog-function -----#
function adminauditlog {
# Set admin audit log 
   Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true 
}


#----- disableimappop-function -----#
function disableimappop {
# Disable IMAP & POP service in the sandard configuration settings if a new mailbox will be deployed (be carefull with that, some services might not work anymore)
## Double check this setting with the customer and the tenant
   Get-CASMailboxPlan | Set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false 

# Disable IMAP & POP service on all mailboxes (be carefull with that, some services might not work anymore)
## Double check this setting with the customer and the tenant
   Get-CASMailbox | Set-CASMailbox -PopEnabled $false -ImapEnabled $false
}


#----- disableexternalforwarding-function -----#
function disableexternalforwarding {
# Block Client Forwarding Rules (be careful with that, some services might not work anymore)
## Double check this setting with the customer and the tenant
   New-TransportRule -name "Client Rules To External Block" -Priority 0 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText "Das automatische weiterleiten von Mails an externe Adressen ist nicht gestattet. Bitte kontaktieren sie Ihre IT."
   Set-RemoteDomain * -AutoForwardEnabled $false  
}


#----- antiphishingpolicy-function -----#
function antiphishpolicy {
# Configure the standard Anti-phishing policy and rule: 
   New-AntiPhishPolicy -Name "ach Standard - Anti-Phishing Policy" -Enabled $True -ImpersonationProtectionState Automatic -EnableTargetedUserProtection $True -EnableMailboxIntelligenceProtection $True -EnableTargetedDomainsProtection $True -EnableOrganizationDomainsProtection $True -EnableMailboxIntelligence $True -EnableFirstContactSafetyTips $False -EnableSimilarUsersSafetyTips $True -EnableSimilarDomainsSafetyTips $True -EnableUnusualCharactersSafetyTips $True -TargetedUserProtectionAction Quarantine -TargetedUserQuarantineTag DefaultFullAccessWithNotificationPolicy -MailboxIntelligenceProtectionAction MoveToJmf -MailboxIntelligenceQuarantineTag DefaultFullAccessPolicy -TargetedDomainProtectionAction Quarantine -TargetedDomainQuarantineTag DefaultFullAccessWithNotificationPolicy -AuthenticationFailAction MoveToJmf -SpoofQuarantineTag DefaultFullAccessPolicy -EnableSpoofIntelligence $True -EnableViaTag $True -EnableUnauthenticatedSender $True -HonorDmarcPolicy $True -DmarcRejectAction Reject -DmarcQuarantineAction Quarantine -PhishThresholdLevel 3
   New-AntiPhishRule -Name "ach Standard - Anti-Phishing Rule" -AntiPhishPolicy "ach Standard - Anti-Phishing Policy" -RecipientDomainIs $domains[0]  
}


#----- antispampolicy-function -----#
function antispampolicy {
# Configure the standard Anti-spam policy and rule: 
   New-HostedContentFilterPolicy -Name "ach Standard - Anti-Spam Policy" -QuarantineRetentionPeriod 30 -TestModeAction None -IncreaseScoreWithImageLinks Off -IncreaseScoreWithNumericIps Off -IncreaseScoreWithRedirectToOtherPort Off -IncreaseScoreWithBizOrInfoUrls Off -MarkAsSpamEmptyMessages Off -MarkAsSpamJavaScriptInHtml Off -MarkAsSpamFramesInHtml Off -MarkAsSpamObjectTagsInHtml Off -MarkAsSpamEmbedTagsInHtml Off -MarkAsSpamFormTagsInHtml Off -MarkAsSpamWebBugsInHtml Off -MarkAsSpamSensitiveWordList Off -MarkAsSpamSpfRecordHardFail Off -MarkAsSpamFromAddressAuthFail Off -MarkAsSpamBulkMail On -MarkAsSpamNdrBackscatter Off -HighConfidenceSpamAction Quarantine -SpamAction MoveToJmf -DownloadLink $False -EnableRegionBlockList $False -EnableLanguageBlockList $False -BulkThreshold 6 -InlineSafetyTipsEnabled $True -BulkSpamAction MoveToJmf -PhishSpamAction Quarantine -SpamZapEnabled $True -PhishZapEnabled $True -HighConfidencePhishAction Quarantine -SpamQuarantineTag DefaultFullAccessPolicy -HighConfidenceSpamQuarantineTag DefaultFullAccessWithNotificationPolicy -PhishQuarantineTag DefaultFullAccessWithNotificationPolicy -HighConfidencePhishQuarantineTag AdminOnlyAccessPolicy -BulkQuarantineTag DefaultFullAccessPolicy
   New-HostedContentFilterRule -Name "ach Standard - Anti-Spam Policy" -HostedContentFilterPolicy "ach Standard - Anti-Spam Policy" -RecipientDomainIs $domains[0] 
}


#----- antimalewarepolicy-function -----#
function malewarefilterpolicy {
# Configure the standard Anti-maleware policy and rule: 
   New-MalwareFilterPolicy -Name "ach Standard - Anti-Malware Policy" -CustomNotifications $False -EnableExternalSenderAdminNotifications $False -EnableFileFilter $True -EnableInternalSenderAdminNotifications $False -FileTypeAction Reject -FileTypes ".ace", ".apk", ".app", ".appx", ".ani", ".arj", ".bat", ".cab", ".cmd", ".com", ".deb", ".dex", ".dll", ".docm", ".elf", ".exe", ".hta", ".img", ".iso", ".jar", ".jnlp", ".kext", ".lha", ".lib", ".library", ".lnk", ".lzh", ".macho", ".msc", ".msi", ".msix", ".msp", ".mst", ".pif", ".ppa", ".ppam", ".reg", ".rev", ".scf", ".scr", ".sct", ".sys", ".uif", ".vb", ".vbe", ".vbs", ".vxd", ".wsc", ".wsf", ".wsh", ".xll", ".xz", ".z" -QuarantineTag AdminOnlyAccessPolicy -ZapEnabled $True
   New-MalwareFilterRule -Name "ach Standard - Anti-Malware Policy" -MalwareFilterPolicy "ach Standard - Anti-Malware Policy" -RecipientDomainIs $domains[0]  
}


#----- safeattachmentpolicy-function -----#
function safeattachmentpolicy {
# Configure default Safe Attachments policy and rule: 
   New-SafeAttachmentPolicy -Name "ach Standard - Safe Attachment Policy" -Enable $True -Action Block -QuarantineTag AdminOnlyAccessPolicy -Redirect $False
   New-SafeAttachmentRule -Name "ach Standard - Safe Attachment Rule" -SafeAttachmentPolicy "ach Standard - Safe Attachment Policy" -RecipientDomainIs $domains[0]  
}


#----- safelinkspolicy-function -----#
function safelinkspolicy {
# Configure default Safe Links policy and rule: 
   New-SafeLinksPolicy -Name "ach Standard - Safe Links Policy" -EnableSafeLinksForEmail $True -EnableSafeLinksForTeams $True -EnableSafeLinksForOffice $True -TrackClicks $True -AllowClickThrough $False -ScanUrls $True -EnableForInternalSenders $True -DeliverMessageAfterScan $True -DisableUrlRewrite $False -EnableOrganizationBranding $False
    New-SafeLinksRule -Name "ach Standard - Safe Links Rule" -SafeLinksPolicy "ach Standard - Safe Links Policy" -RecipientDomainIs $domains[0]  
}



# Disconnect from exo 
Disconnect-ExchangeOnline 