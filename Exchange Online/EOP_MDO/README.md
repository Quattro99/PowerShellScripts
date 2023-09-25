# Recomended EOP / MDO standard settings of Microsoft

The primary functionality of the script is to automatically deploy standard Microsoft best-practice settings for EOP and MDO to a customer's Microsoft 365 tenant. These settings enhance email security and protection against threats.
The script performs a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Microsoft 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
This script is a valuable tool for administrators tasked with securing an Microsoft 365 environment efficiently and in line with recommended security practices.

With this script you can deploy the standard settings to a customer tenant: https://github.com/Quattro99/PowerShellScripts/blob/6b7a612432729f86e163a7094f971042d02e387d/Exchange%20Online/EOP_MDO/xxx-standard-auto-mdo_eop.ps1


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

### exoauthentication-function
| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- | 

### enableorgcustomization-function
| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- | 

### defaultsharingpermission-function
> [!IMPORTANT]
> Some values have to be changed before running the script. Those values are marked with a comment in the script.

| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- |

### adminauditlog-function
| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- | 

### disableimappop-function
| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- |

### disableexternalforwarding-function
| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- | 

### createsharedmailbox-function
| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- | 


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