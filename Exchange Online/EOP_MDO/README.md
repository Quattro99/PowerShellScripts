# Recomended EOP / MDO standard settings of Microsoft

The primary functionality of the script is to automatically deploy standard Microsoft best-practice settings for EOP and MDO to a customer's Microsoft 365 tenant. These settings enhance email security and protection against threats.
The script performs a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Microsoft 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
This script is a valuable tool for administrators tasked with securing an Microsoft 365 environment efficiently and in line with recommended security practices.

With this script you can deploy the standard settings to a customer tenant: [xxx-standard-auto-mdo_eop.ps1](https://github.com/Quattro99/PowerShellScripts/blob/6b7a612432729f86e163a7094f971042d02e387d/Exchange%20Online/EOP_MDO/xxx-standard-auto-mdo_eop.ps1)

<p>&nbsp;</p>
<p>&nbsp;</p>

## Description of the script

### local variables
> [!IMPORTANT]
> Some values have to be changed before running the script. Those values are marked with a comment in the script.

| Commandlet | Value | Comment | 
| ------------- | ------------- | ------------- | 
| $module1  | "ExchangeOnlineManagement" | The name of the PowerShell module that has to be installed for this script |
| $csa  | xxx | Exchange Online administrator for example csa-mbl@domain.onmicrosoft.com. **The value *xxx* has to be changed before running the script.** |
| $custonmicrosoft | customer.onmicrosoft.com | The onmicrosoft domain of the customer. **The value *customer* has to be changed before running the script.** |
| $sharedmailboxname | "Quarantäne - xxx" | Displayname of the shared mailbox. **The value *xxx* has to be changed before running the script.** |
| $sharedMailboxAlias | "quarantine" | E-Mail alias of the shared mailbox |
| $sharedMailboxEmail | "quarantine@domain.tld" | Primary smtp address of the shared mailbox |
| $LogPath | xxx | The local path for the logging functionality of the script. **The value *xxx* has to be changed before running the script.** |

<p>&nbsp;</p>

### main-function
> [!IMPORTANT]
> If you can't run every function for example *disableimappop* on a customer tenant, then you have to comment the function reference in the main function before running the script.

| Commandlet | Value | Comment | 
| ------------- | ------------- | ------------- | 
| function | main |  |
|  | exoauthentication | |
|  | enableorgcustomization | |
|  | defaultsharingpermission | |
|  | adminauditlog | |
|  | disableimappop | |
|  | disableexternalforwarding | |
|  | createsharedmailbox | |
| $domains | Get-AcceptedDomain | Get all accepted domains of the tenant |
| $domainname | $domains.Name | List each name of the domains in a local variable |
|  | antiphishpolicy | |
|  | antispampolicy | |
|  | malewarefilterpolicy | |
|  | safeattachmentpolicy | |
|  | safelinkspolicy | |
|  | globalquarantinesettings | |
|  | exodisconnect | |

<p>&nbsp;</p>

### exoauthentication-function
Installs the module, which is stored in the local variable, if not already installed. Further the authentication on the Microsoft 365 (GDAP enabled) tenant will proceed with your personal csa-user.

<p>&nbsp;</p>

### enableorgcustomization-function
Checks the tenant if the organization customization is activated. If not, the customisation will be activated

<p>&nbsp;</p>

### defaultsharingpermission-function
> [!IMPORTANT]
> Some values have to be changed before running the script. Please check if the sharing permission name is German or English.

This function sets the default sharing permissons of all calendars to "FreeBusySimple". 

<p>&nbsp;</p>

### adminauditlog-function
This function enables the admin audith logging functionality in EXO. A warning will be displayed if already active

<p>&nbsp;</p>

### disableimappop-function
> [!IMPORTANT]
> Check before running if you can deactivate this services!

This function disables the POP and IMAP services on all mailboxes and disables it for all in the future created mailboxes.

<p>&nbsp;</p>

### disableexternalforwarding-function
> [!IMPORTANT]
> Check before running if you can deactivate this services!

This function creates a transport rule and deactivates the opportunity to automatically forward mails to external recipients.

<p>&nbsp;</p>

### createsharedmailbox-function
This function creates a shared mailbox. This mailbox is later configured for the quarantine messages to each employee.

<p>&nbsp;</p>

### antiphishingpolicy-function (EOP anti-phishing policy settings)
In PowerShell, you use the [New-AntiPhishPolicy](/powershell/module/exchange/new-antiphishpolicy) and [Set-AntiPhishRule](/powershell/module/exchange/set-antiphishrule) cmdlets for anti-phising policy & rules settings.



### antispampolicy-function (EOP anti-spam policy settings)

In PowerShell, you use the [New-HostedContentFilterPolicy](/powershell/module/exchange/new-hostedcontentfilterpolicy) and [Set-HostedContentFilterRule](/powershell/module/exchange/set-hostedcontentfilterrule) cmdlets for anti-spam policy & rules settings.


Wherever you select **Quarantine message** as the action for a spam filter verdict, a **Select quarantine policy** box is available. Quarantine policies define what users are able to do to quarantined messages, and whether users receive quarantine notifications. 
If you _change_ the action of a spam filtering verdict to **Quarantine message** when you create anti-spam policies the Defender portal, the **Select quarantine policy** box is blank by default. A blank value means the default quarantine policy for that spam filtering verdict is used. These default quarantine policies enforce the historical capabilities for the spam filter verdict that quarantined the message. When you later view or edit the anti-spam policy settings, the quarantine policy name is shown.
Admins can create or use quarantine policies with more restrictive or less restrictive capabilities.

|Security feature name|Standard|Comment|
|---|:---:|---|
|**Bulk email threshold & spam properties**|||
|**Bulk email threshold** (_BulkThreshold_)|6||
|_MarkAsSpamBulkMail_|(`On`)|This setting is only available in PowerShell.|
|**Increase spam score** settings|Off|All of these settings are part of the Advanced Spam Filter (ASF).
|**Mark as spam** settings|Off|Most of these settings are part of ASF.|
|**Contains specific languages** (_EnableLanguageBlockList_ and _LanguageBlockList_)|**Off** (`$false` and Blank)||
|**From these countries** (_EnableRegionBlockList_ and _RegionBlockList_)|**Off** (`$false` and Blank)||
|**Test mode** (_TestModeAction_)|**None**|This setting is part of ASF.|
|**Actions**|||
|**Spam** detection action (_SpamAction_)|**Move message to Junk Email folder** (`MoveToJmf`)||
|**Quarantine policy** for **Spam** (_SpamQuarantineTag_)|DefaultFullAccessPolicy|The quarantine policy is meaningful only if spam detections are quarantined.|
|**High confidence spam** detection action (_HighConfidenceSpamAction_)|**Quarantine message** (`Quarantine`)||
|**Quarantine policy** for **High confidence spam** (_HighConfidenceSpamQuarantineTag_)DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if high confidence spam detections are quarantined.|
|**Phishing** detection action (_PhishSpamAction_)|**Quarantine message** (`Quarantine`)|The default value is **Move message to Junk Email folder** in the default anti-spam policy and in new anti-spam policies that you create in PowerShell. The default value is **Quarantine message** in new anti-spam policies that you create in the Defender portal.|
|**Quarantine policy** for **Phishing** (_PhishQuarantineTag_)|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if phishing detections are quarantined.|
|**High confidence phishing** detection action (_HighConfidencePhishAction_)|**Quarantine message** (`Quarantine`)|Users can't release their own messages that were quarantined as high confidence phishing, regardless of how the quarantine policy is configured. If the policy allows users to release their own quarantined messages, users are instead allowed to _request_ the release of their quarantined high-confidence phishing messages.|
|**Quarantine policy** for **High confidence phishing** (_HighConfidencePhishQuarantineTag_)|AdminOnlyAccessPolicy||
|**Bulk compliant level (BCL) met or exceeded** (_BulkSpamAction_)|**Move message to Junk Email folder** (`MoveToJmf`)||
|**Quarantine policy** for **Bulk compliant level (BCL) met or exceeded** (_BulkQuarantineTag_)|DefaultFullAccessPolicy|The quarantine policy is meaningful only if bulk detections are quarantined.|
|**Retain spam in quarantine for this many days** (_QuarantineRetentionPeriod_)|30 days|This value also affects messages that are quarantined by anti-phishing policies.|
|**Enable spam safety tips** (_InlineSafetyTipsEnabled_)|Selected (`$true`)||
|Enable zero-hour auto purge (ZAP) for phishing messages (_PhishZapEnabled_)|Selected (`$true`)||
|Enable ZAP for spam messages (_SpamZapEnabled_)|Selected (`$true`)||

#### ASF settings in anti-spam policies
|Security feature name|Standard|Comment|
|---|:---:|---|
|**Image links to remote sites** (_IncreaseScoreWithImageLinks_)|Off||
|**Numeric IP address in URL** (_IncreaseScoreWithNumericIps_)|Off||
|**URL redirect to other port** (_IncreaseScoreWithRedirectToOtherPort_)|Off||
|**Links to .biz or .info websites** (_IncreaseScoreWithBizOrInfoUrls_)|Off||
|**Empty messages** (_MarkAsSpamEmptyMessages_)|Off||
|**Embed tags in HTML** (_MarkAsSpamEmbedTagsInHtml_)|Off||
|**JavaScript or VBScript in HTML** (_MarkAsSpamJavaScriptInHtml_)|Off||
|**Form tags in HTML** (_MarkAsSpamFormTagsInHtml_)|Off||
|**Frame or iframe tags in HTML** (_MarkAsSpamFramesInHtml_)|Off||
|**Web bugs in HTML** (_MarkAsSpamWebBugsInHtml_)|Off||
|**Object tags in HTML** (_MarkAsSpamObjectTagsInHtml_)|Off||
|**Sensitive words** (_MarkAsSpamSensitiveWordList_)|Off||
|**SPF record: hard fail** (_MarkAsSpamSpfRecordHardFail_)|Off||
|**Sender ID filtering hard fail** (_MarkAsSpamFromAddressAuthFail_)|Off||
|**Backscatter** (_MarkAsSpamNdrBackscatter_)|Off||
|**Test mode** (_TestModeAction_)|None|For ASF settings that support **Test** as an action, you can configure the test mode action to **None**, **Add default X-Header text**, or **Send Bcc message** (`None`, `AddXHeader`, or `BccMessage`). |

> [!NOTE]
> ASF adds `X-CustomSpam:` X-header fields to messages _after_ the messages have been processed by Exchange mail flow rules (also known as transport rules), so you can't use mail flow rules to identify and act on messages that were filtered by ASF.


### antimalewarepolicy-function (EOP anti-malware policy settings)

In PowerShell, you use the [New-MalwareFilterPolicy](/powershell/module/exchange/new-malwarefilterpolicy) and [Set-MalwareFilterrule](/powershell/module/exchange/set-malwarefilterrule) cmdlets for anti-malware policy & rules settings.

Quarantine policies define what users are able to do to quarantined messages, and whether users receive quarantine notifications. The policy named AdminOnlyAccessPolicy enforces the historical capabilities for messages that were quarantined as malware. Users can't release their own messages that were quarantined as malware, regardless of how the quarantine policy is configured. If the policy allows users to release their own quarantined messages, users are instead allowed to _request_ the release of their quarantined malware messages.

|Security feature name|Standard|Comment|
|---|:---:|---|
|**Protection settings**|||
|**Enable the common attachments filter** (_EnableFileFilter_)|Selected (`$true`)|For the list of file types in the common attachments filter, follow this [link](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-malware-protection-about?view=o365-worldwide#common-attachments-filter-in-anti-malware-policies). The common attachments filter is on by default in new anti-malware policies that you create in the Defender portal. The common attachments filter is off by default in the default anti-malware policy and in new policies that you create in PowerShell.|
|Common attachment filter notifications: **When these file types are found** (_FileTypeAction_)|**Reject the message with a non-delivery report (NDR)** (`Reject`)||
|**Enable zero-hour auto purge for malware** (_ZapEnabled_)|Selected (`$true`)||
|**Quarantine policy** (_QuarantineTag_)|AdminOnlyAccessPolicy||
|**Admin notifications**|||
|**Notify an admin about undelivered messages from internal senders** (_EnableInternalSenderAdminNotifications_ and _InternalSenderAdminAddress_)|Not selected (`$false`)||
|**Notify an admin about undelivered messages from external senders** (_EnableExternalSenderAdminNotifications_ and _ExternalSenderAdminAddress_)|Not selected (`$false`)||


### safeattachmentpolicy-function (Safe Attachments policy settings)

In PowerShell, you use the [New-SafeAttachmentPolicy](/powershell/module/exchange/new-safeattachmentpolicy) and [Set-SafeAttachmentPolicy](/powershell/module/exchange/set-safelinkspolicy) cmdlets for these settings.

Quarantine policies define what users are able to do to quarantined messages, and whether users receive quarantine notifications. The policy named AdminOnlyAccessPolicy enforces the historical capabilities for messages that were quarantined as malware.Users can't release their own messages that were quarantined as malware by Safe Attachments, regardless of how the quarantine policy is configured. If the policy allows users to release their own quarantined messages, users are instead allowed to _request_ the release of their quarantined malware messages.

|Security feature name|Standard|Comment|
|---|:---:|---|
|**Safe Attachments unknown malware response** (_Enable_ and _Action_)|**Block** (`-Enable $true` and `-Action Block`)|When the _Enable_ parameter is $false, the value of the _Action_ parameter doesn't matter.|
|**Quarantine policy** (_QuarantineTag_)|AdminOnlyAccessPolicy|
|**Redirect attachment with detected attachments** : **Enable redirect** (_Redirect_ and _RedirectAddress_)|Not selected and no email address specified. (`-Redirect $false` and _RedirectAddress_ is blank)|Redirection of messages is available only when the **Safe Attachments unknown malware response** value is **Monitor** (`-Enable $true` and `-Action Allow`).|


### safelinkspolicy-function (Safe Links policy settings)
In PowerShell, you use the [New-SafeLinksPolicy](/powershell/module/exchange/new-safelinkspolicy) and [Set-SafeLinksPolicy](/powershell/module/exchange/set-safelinkspolicy) cmdlets for Safe Links policy settings.

|Security feature name|Standard|Comment|
|---|:---:|---|
|**URL & click protection settings**|||
|**Email**||The settings in this section affect URL rewriting and time of click protection in email messages.|
|**On: Safe Links checks a list of known, malicious links when users click links in email. URLs are rewritten by default.** (_EnableSafeLinksForEmail_)|Selected (`$true`)|
|**Apply Safe Links to email messages sent within the organization** (_EnableForInternalSenders_)|Selected (`$true`)|
|**Apply real-time URL scanning for suspicious links and links that point to files** (_ScanUrls_)|Selected (`$true`)|
|**Wait for URL scanning to complete before delivering the message** (_DeliverMessageAfterScan_)|Selected (`$true`)|
|**Do not rewrite URLs, do checks via Safe Links API only** (_DisableURLRewrite_)|Not selected (`$false`)| In new Safe Links policies that you create in the Defender portal, this setting is selected by default. In new Safe Links policies that you create in PowerShell, the default value of the _DisableURLRewrite_ parameter is `$false`.|
|**Teams**||The setting in this section affects time of click protection in Microsoft Teams.|
|**On: Safe Links checks a list of known, malicious links when users click links in Microsoft Teams. URLs are not rewritten.** (_EnableSafeLinksForTeams_)|Selected (`$true`)|
|**Office 365 apps**||The setting in this section affects time of click protection in Office apps.|
|**On: Safe Links checks a list of known, malicious links when users click links in Microsoft Office apps. URLs are not rewritten.** (_EnableSafeLinksForOffice_)|Selected (`$true`)|Use Safe Links in supported Office 365 desktop and mobile (iOS and Android) apps.|
|**Click protection settings**|||
|**Track user clicks** (_TrackClicks_)|Selected (`$true`)||
|**Let users click through to the original URL** (_AllowClickThrough_)|Not selected (`$false`)|In new Safe Links policies that you create in the Defender portal, this setting is selected by default. In new Safe Links policies that you create in PowerShell, the default value of the _AllowClickThrough_ parameter is `$false`.|
|**Display the organization branding on notification and warning pages** (_EnableOrganizationBranding_)|Not selected (`$false`)||











The spoof settings are inter-related, but the **Show first contact safety tip** setting has no dependency on spoof settings.

|Security feature name|Standard|Comment|
|---|:---:|---|
|**Phishing threshold & protection**|||
|**Enable spoof intelligence** (_EnableSpoofIntelligence_)|Selected (`$true`)||
|**Actions**|||
|**Honor DMARC record policy when the message is detected as spoof** (_HonorDmarcPolicy_)|Selected (`$true`)|When this setting is turned on, you control what happens to messages where the sender fails explicit DMARC checks when the policy action in the DMARC TXT record is set to `p=quarantine` or `p=reject`.|
|**If the message is detected as spoof and DMARC Policy is set as p=quarantine** (_DmarcQuarantineAction_)|**Quarantine the message** (`Quarantine`)|This action is meaningful only when **Honor DMARC record policy when the message is detected as spoof** is turned on.|
|**If the message is detected as spoof and DMARC Policy is set as p=reject** (_DmarcRejectAction_)|**Reject the message** (`Reject`)|This action is meaningful only when **Honor DMARC record policy when the message is detected as spoof** is turned on.|
|**If the message is detected as spoof by spoof intelligence** (_AuthenticationFailAction_)|**Move the message to the recipients' Junk Email folders** (`MoveToJmf`)|This setting applies to spoofed senders that were automatically blocked as shown in the spoof intelligence insight or manually blocked in the Tenant Allow/Block List.|
|**Quarantine policy** for **Spoof** (_SpoofQuarantineTag_)|DefaultFullAccessPolicy|The quarantine policy is meaningful only if spoof detections are quarantined.|
|**Show first contact safety tip** (_EnableFirstContactSafetyTips_)|Not selected (`$false`)||
|**Show (?) for unauthenticated senders for spoof** (_EnableUnauthenticatedSender_)|Selected (`$true`)|Adds a question mark (?) to the sender's photo in Outlook for unidentified spoofed senders.|
|**Show "via" tag** (_EnableViaTag_)|Selected (`$true`)|Adds a via tag (chris@contoso.com via fabrikam.com) to the From address if it's different from the domain in the DKIM signature or the **MAIL FROM** address. |


#### Anti-phishing policy settings in Microsoft Defender for Office 365

EOP customers get basic anti-phishing as previously described, but Defender for Office 365 includes more features and control to help prevent, detect, and remediate against attacks. 

|Security feature name|Standard|Comment|
|---|:---:|---|
|**Phishing email threshold** (_PhishThresholdLevel_)|**3 - More aggressive** (`3`)||
|**Phishing threshold & protection**|||
|User impersonation protection: **Enable users to protect** (_EnableTargetedUserProtection_ and _TargetedUsersToProtect_)|Selected (`$true` and \<list of users\>)|We recommend adding users (message senders) in key roles. Internally, protected senders might be your CEO, CFO, and other senior leaders. Externally, protected senders could include council members or your board of directors.|
|Domain impersonation protection: **Enable domains to protect**|Not selected|Selected|Selected||
|**Include domains I own** (_EnableOrganizationDomainsProtection_)|Selected (`$true`)||
|**Include custom domains** (_EnableTargetedDomainsProtection_ and _TargetedDomainsToProtect_)|Selected (`$true` and \<list of domains\>)|We recommend adding domains (sender domains) that you don't own, but you frequently interact with.|
|**Add trusted senders and domains** (_ExcludedSenders_ and _ExcludedDomains_)|None|None|None|Depending on your organization, we recommend adding senders or domains that are incorrectly identified as impersonation attempts.|
|**Enable mailbox intelligence** (_EnableMailboxIntelligence_)|Selected (`$true`)||
|**Enable intelligence for impersonation protection** (_EnableMailboxIntelligenceProtection_)|Selected (`$true`)|This setting allows the specified action for impersonation detections by mailbox intelligence.|
|**Actions**|||
|**If a message is detected as user impersonation** (_TargetedUserProtectionAction_)|**Quarantine the message** (`Quarantine`)||
|**Quarantine policy** for **user impersonation** (_TargetedUserQuarantineTag_)|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if user impersonation detections are quarantined.|
|**If a message is detected as domain impersonation** (_TargetedDomainProtectionAction_)|**Quarantine the message** (`Quarantine`)||
|**Quarantine policy** for **domain impersonation** (_TargetedDomainQuarantineTag_)|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if domain impersonation detections are quarantined.|
|**If mailbox intelligence detects an impersonated user** (_MailboxIntelligenceProtectionAction_)|**Move the message to the recipients' Junk Email folders** (`MoveToJmf`)|
|**Quarantine policy** for **mailbox intelligence impersonation** (_MailboxIntelligenceQuarantineTag_)|DefaultFullAccessPolicy|The quarantine policy is meaningful only if mailbox intelligence detections are quarantined.|
|**Show user impersonation safety tip** (_EnableSimilarUsersSafetyTips_)|Selected (`$true`)||
|**Show domain impersonation safety tip** (_EnableSimilarDomainsSafetyTips_)|Selected (`$true`)||
|**Show user impersonation unusual characters safety tip** (_EnableUnusualCharactersSafetyTips_)|Selected (`$true`)||






New-AntiPhishPolicy -Name "xxx Standard - Anti-Phishing Policy" 
-Enabled $True 
-ImpersonationProtectionState Automatic 
-EnableTargetedUserProtection $True 
-EnableMailboxIntelligenceProtection $True 
-EnableTargetedDomainsProtection $True 
-EnableOrganizationDomainsProtection $True 
-EnableMailboxIntelligence $True 
-EnableFirstContactSafetyTips $False 
-EnableSimilarUsersSafetyTips $True 
-EnableSimilarDomainsSafetyTips $True 
-EnableUnusualCharactersSafetyTips $True 
-TargetedUserProtectionAction Quarantine 
-TargetedUserQuarantineTag DefaultFullAccessWithNotificationPolicy 
-MailboxIntelligenceProtectionAction MoveToJmf 
-MailboxIntelligenceQuarantineTag DefaultFullAccessPolicy 
-TargetedDomainProtectionAction Quarantine 
-TargetedDomainQuarantineTag DefaultFullAccessWithNotificationPolicy 
-AuthenticationFailAction MoveToJmf 
-SpoofQuarantineTag DefaultFullAccessPolicy 
-EnableSpoofIntelligence $True 
-EnableViaTag $True 
-EnableUnauthenticatedSender $True 
-HonorDmarcPolicy $True 
-DmarcRejectAction Reject 
-DmarcQuarantineAction Quarantine 
-PhishThresholdLevel 3








#### EOP outbound spam policy settings

To create and configure outbound spam policies, see [Configure outbound spam filtering in EOP](outbound-spam-policies-configure.md).

For more information about the default sending limits in the service, see [Sending limits](/office365/servicedescriptions/exchange-online-service-description/exchange-online-limits#sending-limits-1).

> [!NOTE]
> Outbound spam policies are not part of Standard or Strict preset security policies. The **Standard** and **Strict** values indicate our **recommended** values in the default outbound spam policy or custom outbound spam policies that you create.

|Security feature name|Default|Recommended<br>Standard|Recommended<br>Strict|Comment|
|---|:---:|:---:|:---:|---|
|**Set an external message limit** (_RecipientLimitExternalPerHour_)|0|500|400|The default value 0 means use the service defaults.|
|**Set an internal message limit** (_RecipientLimitInternalPerHour_)|0|1000|800|The default value 0 means use the service defaults.|
|**Set a daily message limit** (_RecipientLimitPerDay_)|0|1000|800|The default value 0 means use the service defaults.|
|**Restriction placed on users who reach the message limit** (_ActionWhenThresholdReached_)|**Restrict the user from sending mail until the following day** (`BlockUserForToday`)|**Restrict the user from sending mail** (`BlockUser`)|**Restrict the user from sending mail** (`BlockUser`)||
|**Automatic forwarding rules** (_AutoForwardingMode_)|**Automatic - System-controlled** (`Automatic`)|**Automatic - System-controlled** (`Automatic`)|**Automatic - System-controlled** (`Automatic`)|
|**Send a copy of outbound messages that exceed these limits to these users and groups** (_BccSuspiciousOutboundMail_ and _BccSuspiciousOutboundAdditionalRecipients_)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|We have no specific recommendation for this setting. <br><br> This setting works only in the default outbound spam policy. It doesn't work in custom outbound spam policies that you create.|
|**Notify these users and groups if a sender is blocked due to sending outbound spam** (_NotifyOutboundSpam_ and _NotifyOutboundSpamRecipients_)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|The default [alert policy](/purview/alert-policies) named **User restricted from sending email** already sends email notifications to members of the **TenantAdmins** (**Global admins**) group when users are blocked due to exceeding the limits in policy. **We strongly recommend that you use the alert policy rather than this setting in the outbound spam policy to notify admins and other users**. For instructions, see [Verify the alert settings for restricted users](removing-user-from-restricted-users-portal-after-spam.md#verify-the-alert-settings-for-restricted-users).|

#### Global settings for Safe Attachments

> [!NOTE]
> The global settings for Safe Attachments are set by the **Built-in protection** preset security policy, but not by the **Standard** or **Strict** preset security policies. Either way, admins can modify these global Safe Attachments settings at any time.
>
> The **Default** column shows the values before the existence of the **Built-in protection** preset security policy. The **Built-in protection** column shows the values that are set by the **Built-in protection** preset security policy, which are also our recommended values.

To configure these settings, see [Turn on Safe Attachments for SharePoint, OneDrive, and Microsoft Teams](safe-attachments-for-spo-odfb-teams-configure.md) and [Safe Documents in Microsoft 365 E5](safe-documents-in-e5-plus-security-about.md).

In PowerShell, you use the [Set-AtpPolicyForO365](/powershell/module/exchange/set-atppolicyforo365) cmdlet for these settings.

|Security feature name|Default|Built-in protection|Comment|
|---|:---:|:---:|---|
|**Turn on Defender for Office 365 for SharePoint, OneDrive, and Microsoft Teams** (_EnableATPForSPOTeamsODB_)|Off (`$false`)|On (`$true`)|To prevent users from downloading malicious files, see [Use SharePoint Online PowerShell to prevent users from downloading malicious files](safe-attachments-for-spo-odfb-teams-configure.md#step-2-recommended-use-sharepoint-online-powershell-to-prevent-users-from-downloading-malicious-files).|
|**Turn on Safe Documents for Office clients** (_EnableSafeDocs_)|Off (`$false`)|On (`$true`)|This feature is available and meaningful only with licenses that aren't included in Defender for Office 365 (for example, Microsoft 365 A5 or Microsoft 365 E5 Security). For more information, see [Safe Documents in Microsoft 365 A5 or E5 Security](safe-documents-in-e5-plus-security-about.md).|
|**Allow people to click through Protected View even if Safe Documents identified the file as malicious** (_AllowSafeDocsOpen_)|Off (`$false`)|Off (`$false`)|This setting is related to Safe Documents.|
