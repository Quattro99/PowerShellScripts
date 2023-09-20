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

$module = ExchangeOnlineManagement
$csa = "csa-mbl@domain.tdl"
$custonmicrosoft = "customer.onmicrosoft.com"

function Authentication {
# Check if the PowerShell module is installed on the local computer
If (-not (Get-InstalledModule $module -ErrorAction silentlycontinue)) {

   # Install the module, if not installed, to the scope of the currentuser
   Install-Module $module -Scope CurrentUser

   # Import the module
   Import-Module $module

   # Connect to the exo tenant with your exo admin and security admin (gdap organization)
   Connect-ExchangeOnline -Identity $csa -DelegatedOrganization $custonmicrosoft
   }

Else {

   # Update the exo module to the latest version
   Update-Module $module

   # Import the module
   Import-Module $module

   # Connect to the exo tenant with your exo admin and security admin (gdap organization)
   Connect-ExchangeOnline -Identity $csa -DelegatedOrganization $custonmicrosoft
   }
   
}

$domains = Get-AcceptedDomain 
$domainname = $domains.name 

$ITSupportEmail= "helpdesk@" 

#Configure default Safe Links policy and rule: 
New-SafeLinksPolicy -Name "Safe Links Policy" -IsEnabled $true  -EnableSafeLinksForTeams $true  -scanurls $true -DeliverMessageAfterScan $true -DoNotAllowClickThrough $true -enableforinternalsenders $true -DoNotTrackUserClicks $false 
New-SafeLinksRule -Name "Safe Links Rule" -SafeLinksPolicy "Sa fe Links Policy" -RecipientDomainIs $domains[0] 

 #Configure default Safe Attachments policy and rule: 
New-SafeAttachmentPolicy -Name "Safe Attachment Policy" -Enable $true -Redirect $false -RedirectAddress $ITSupportEmail 
New-SafeAttachmentRule -Name "Safe Attachment Rule" -SafeAttachmentPolicy "Safe Attachment Policy" -RecipientDomainIs $domains[0] 

 #Configure the default Anti-phish policy and rule: 
New-AntiPhishPolicy -Name "AntiPhish Policy" -Enabled $true -EnableOrganizationDomainsProtection $true  -EnableSimilarUsersSafetyTips $true -EnableSimilarDomainsSafetyTips $true -EnableUnusualCharactersSafetyTips $true -AuthenticationFailAction Quarantine -EnableMailboxIntelligenceProtection $true -MailboxIntelligenceProtectionAction movetoJMF -PhishThresholdLevel 2 -TargetedUserProtectionAction movetoJMF -EnableTargetedDomainsProtection $true -TargetedDomainProtectionAction MovetoJMF -EnableAntispoofEnforcement $true 
New-AntiPhishRule -Name "AntiPhish Rule" -AntiPhishPolicy "AntiPhish Policy" -RecipientDomainIs $domains[0] 

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
  
#Default Sharing Policy Calendar 
Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove="Anonymous:CalendarSharingFreeBusyReviewer", "Anonymous:CalendarSharingFreeBusySimple", "Anonymous:CalendarSharingFreeBusyDetail"} 
Set-SharingPolicy -Identity "Default Sharing Policy" -Domains "*:CalendarSharingFreeBusySimple" 

 #Audit log for all users 
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true 

 Get-EXOMailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox"} ` 
 | Set-Mailbox -AuditEnabled $true -AuditLogAgeLimit 180 -AuditAdmin Update, MoveToDeletedItems, SoftDelete, HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission ` 
 -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf ` 
 -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems  

 Get-EXOMailbox -ResultSize Unlimited | Select Name, AuditEnabled, AuditLogAgeLimit | Out-Gridview 

<#
# Disable IMAP & POP service on all mailboxes (be carefull with that, some services might not work anymore)
# Double check this setting with the customer and the tenant
Get-CASMailboxPlan | Set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false 
#>

<#
# Block Client Forwarding Rules (be carefull with that, some services might not work anymore)
# Double check this setting with the customer and the tenant
New-TransportRule -name "Client Rules To External Block" -Priority 0 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 ` 
 -RejectMessageReasonText $rejectMessageText 
Set-RemoteDomain –AutoForwardEnabled $false 
#>

# Disconnect from exo 
Disconnect-ExchangeOnline 