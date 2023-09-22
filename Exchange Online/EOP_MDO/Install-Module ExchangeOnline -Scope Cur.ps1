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

   Write-Host "Exchange Online Management Module nicht vorhanden. Modul wird nun installiert"

   # Install the module, if not installed, to the scope of the currentuser
   Install-Module $module -Scope CurrentUser -Force

   # Import the module
   Import-Module $module

   # Connect to the exo tenant with your exo admin and security admin (gdap organization)
   Connect-ExchangeOnline -UserPrincipalName $csa # -DelegatedOrganization $custonmicrosoft
   }

Else {

   Write-Host "Exchange Online Management Module ist bereits vorhanden."

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
# Block Client Forwarding Rules (be carefull with that, some services might not work anymore)
## Double check this setting with the customer and the tenant
New-TransportRule -name "Client Rules To External Block" -Priority 0 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText "Das automatische weiterleiten von Mails an externe Adressen ist nicht gestattet. Bitte kontaktieren sie Ihre IT."
Set-RemoteDomain * -AutoForwardEnabled $false  
}


#----- antiphishpolicy-function -----#
function antiphishpolicy {
# Configure the standard Anti-phish policy and rule: 
New-AntiPhishPolicy -Name "ach Standard - AntiPhish Policy" -Enabled $True -ImpersonationProtectionState Automatic -EnableTargetedUserProtection $True -EnableMailboxIntelligenceProtection $True -EnableTargetedDomainsProtection $True -EnableOrganizationDomainsProtection $True -EnableMailboxIntelligence $True -EnableFirstContactSafetyTips $False -EnableSimilarUsersSafetyTips $True -EnableSimilarDomainsSafetyTips $True -EnableUnusualCharactersSafetyTips $True -TargetedUserProtectionAction Quarantine -TargetedUserQuarantineTag DefaultFullAccessWithNotificationPolicy -MailboxIntelligenceProtectionAction MoveToJmf -MailboxIntelligenceQuarantineTag DefaultFullAccessPolicy -TargetedDomainProtectionAction Quarantine -TargetedDomainQuarantineTag DefaultFullAccessWithNotificationPolicy -AuthenticationFailAction MoveToJmf -SpoofQuarantineTag DefaultFullAccessPolicy -EnableSpoofIntelligence $True -EnableViaTag $True -EnableUnauthenticatedSender $True -HonorDmarcPolicy $True -DmarcRejectAction Reject -DmarcQuarantineAction Quarantine -PhishThresholdLevel 3
New-AntiPhishRule -Name "ach Standard - AntiPhish Rule" -AntiPhishPolicy "ach Standard - AntiPhish Policy" -RecipientDomainIs $domains[0]  
}





#Configure default Safe Links policy and rule: 
New-SafeLinksPolicy -Name "Safe Links Policy" -IsEnabled $true  -EnableSafeLinksForTeams $true  -scanurls $true -DeliverMessageAfterScan $true -DoNotAllowClickThrough $true -enableforinternalsenders $true -DoNotTrackUserClicks $false 
New-SafeLinksRule -Name "Safe Links Rule" -SafeLinksPolicy "Sa fe Links Policy" -RecipientDomainIs $domains[0] 

 #Configure default Safe Attachments policy and rule: 
New-SafeAttachmentPolicy -Name "Safe Attachment Policy" -Enable $true -Redirect $false -RedirectAddress $ITSupportEmail 
New-SafeAttachmentRule -Name "Safe Attachment Rule" -SafeAttachmentPolicy "Safe Attachment Policy" -RecipientDomainIs $domains[0] 



 #Configure ATP for Office 365 apps (Off by Default): 
Set-AtpPolicyForO365 -EnableATPForSPOTeamsODB $true -allowclickthrough $false -TrackClicks $true 

#Spamfiltersettings Office365 
Set-HostedContentFilterPolicy -Identity "Default" -SpamAction MoveToJmf -BulkSpamAction MoveToJmf -HighConfidenceSpamAction MoveToJmf -BulkThreshold 5 -IncreaseScoreWithBizOrInfoUrls On ` 
 -IncreaseScoreWithImageLinks On -IncreaseScoreWithNumericIps On -IncreaseScoreWithRedirectToOtherPort On -MarkAsSpamBulkMail On -MarkAsSpamEmbedTagsInHtml On -MarkAsSpamEmptyMessages On ` 
 -MarkAsSpamFormTagsInHtml On -MarkAsSpamFramesInHtml On -MarkAsSpamFromAddressAuthFail On -MarkAsSpamJavaScriptInHtml On -MarkAsSpamNdrBackscatter On -MarkAsSpamObjectTagsInHtml On ` 
 -MarkAsSpamSpfRecordHardFail On -MarkAsSpamWebBugsInHtml On -MarkAsSpamSensitiveWordList On -TestModeAction AddXHeader 

#Malwarefiltersettings Office365 
Set-MalwareFilterPolicy -Identity "Default" -Action DeleteAttachmentAndUseDefaultAlertText -EnableFileFilter $true -FileTypes ".cpl", ".ace", ".app",".docm",".exe",".jar",".reg",".scr",".vbe",".vbs",".bat",".msi", ` 
".ani", ".dll", ".lnf", ".mdb", ".ws", ".cmd", ".com", ".crt", ".dos", ".lns", ".ps1", ".wsh", ".wsc" -EnableExternalSenderNotifications $true -EnableInternalSenderNotifications $true 

# Disconnect from exo 
Disconnect-ExchangeOnline 