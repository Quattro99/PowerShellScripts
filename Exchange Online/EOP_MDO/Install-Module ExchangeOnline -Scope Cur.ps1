Install-Module ExchangeOnline -Scope CurrentUser

Import-Module ExchangeOnline

Connect-ExchangeOnline -Identity "csa-mbl@domain.tdl" -DelegatedOrganization "customer.onmicrosoft.com"

$domains = Get-AcceptedDomain 
$domainname = $domains.name 

$ITSupportEmail= "helpdesk@" 

#Configure default Safe Links policy and rule: 
New-SafeLinksPolicy -Name "Safe Links Policy" -IsEnabled $true  -EnableSafeLinksForTeams $true  -scanurls $true -DeliverMessageAfterScan $true -DoNotAllowClickThrough $true -enableforinternalsenders $true -DoNotTrackUserClicks $false 
New-SafeLinksRule -Name "Safe Links Rule" -SafeLinksPolicy "Safe Links Policy" -RecipientDomainIs $domains[0] 

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

# Disable Imap & POP 
Get-CASMailboxPlan | Set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false 

 #Block Client Forwarding Rules 
New-TransportRule -name "Client Rules To External Block" -Priority 0 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 ` 
 -RejectMessageReasonText $rejectMessageText 
Set-RemoteDomain –AutoForwardEnabled $false 

  
Disconnect-ExchangeOnline 