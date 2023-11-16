# Recomended EOP / MDO standard & strict settings of Microsoft

The primary functionality of the scripts are to automatically deploy standard or strict Microsoft best-practice settings for EOP and MDO to a customer's Microsoft 365 tenant. These settings enhance email security and protection against threats.
The scripts perform a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Microsoft 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
These scripts are a valuable tool for administrators tasked with securing a Microsoft 365 environment efficiently and in line with recommended security practices.

"**Exchange Online Protection (EOP)** is the core of security for Microsoft 365 subscriptions and helps keep malicious emails from reaching your employee's inboxes. But with new, more sophisticated attacks emerging every day, improved protections are often required. **Microsoft Defender for Office 365** Plan 1 or Plan 2 contain additional features that give more layers of security, control, and investigation." (Microsoft, 23.09.2023)

"Although we empower security administrators to customize their security settings, there are two security levels in EOP and Microsoft Defender for Office 365 that we recommend: **Standard** and **Strict**. Although customer environments and needs are different, these levels of filtering help prevent unwanted mail from reaching your employees' Inbox in most situations." (Microsoft, 23.09.2023)


* With this script you can deploy the standard settings to a customer tenant: [xxx-standard-auto-mdo_eop.ps1](https://github.com/Quattro99/PowerShellScripts/blob/main/Exchange%20Online/EOP_MDO/xxx-standard-auto-mdo_eop.ps1)
* With this script you can deploy the strict settings to a customer tenant: [xxx-srict-auto-mdo_eop.ps1](https://github.com/Quattro99/PowerShellScripts/blob/main/Exchange%20Online/EOP_MDO/xxx-strict-auto-mdo_eop.ps1)

## Description of the script
> [!IMPORTANT]
> The account which will be used for running the script has to have the following Entra ID Roles: Exchange Administrator, Security Administrator, User Administrator and Application Administrator

The following steps have to be done before running the scripts: 
*   Activate the Entra ID Roles via PIM for your account, which will run the script. Or just take a GA ;)
*   Exclude in the main-function some functions if they can't be run on the tenant for example:  
    *   defaultsharingpermission = Sets the default calendar sharing permission to CalendarSharingFreeBusySimple.
    *   disableimappop = Disables the POP and IMAP services on all existing mailboxes and on the "template" mailbox.
    *   disableexternalforwarding = Creates a transport rule, which disables external forwarding of emails.
*   Start the script on your local device

The following steps have to be done during running the scripts:
1.  "Enter your username"
2.  "Enter the onmicrosoft address of the customer eq. customer.onmicrosoft.com"
3.  "Enter the language of the tenant eq. English or Deutsch (can be checked in the Entra ID Properties notification language)"
4.  "Enter the Shared Mailbox name eq. Quarantaene - xxx"
5.  "Enter the Shared Mailbox alias eq. quarantine"
6.  "Enter the Shared Mailbox mail address eq. quarantine@domain.tld"
7.  "Enter who should have access to the quarantine mailbox eq. 'michele.blum@domain.tdl', 'flavio.meyer@domain.tdl'"
8.  "Enter user which have to be protcted against spoofing .eq 'DisplayName1;EmailAddress1','DisplayName2;EmailAddress2',...'DisplayNameN;EmailAddressN'"
9.  "Specify the log path for the script"

## Anti-spam, anti-malware, and anti-phishing protection in EOP

Anti-spam, anti-malware, and anti-phishing are EOP features that can be configured by admins. The following standards for "Standard" or "Strict" settings are adopted to Microsoft best-practices.

### EOP anti-phishing policy settings
|Security feature name|Default|Standard|Strict|Comment|
|---|:---:|:---:|:---:|---|
|**Phishing threshold & protection**|||||
|**Enable spoof intelligence** (_EnableSpoofIntelligence_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)||
|**Actions**|||||
|**Honor DMARC record policy when the message is detected as spoof** (_HonorDmarcPolicy_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)|When this setting is turned on, you control what happens to messages where the sender fails explicit [DMARC](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dmarc-configure?view=o365-worldwide) checks when the policy action in the DMARC TXT record is set to `p=quarantine` or `p=reject`. For more information, see [Spoof protection and sender DMARC policies](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about?view=o365-worldwide#spoof-protection-and-sender-dmarc-policies).|
|**If the message is detected as spoof and DMARC Policy is set as p=quarantine** (_DmarcQuarantineAction_)|**Quarantine the message** (`Quarantine`)|**Quarantine the message** (`Quarantine`)|**Quarantine the message** (`Quarantine`)|This action is meaningful only when **Honor DMARC record policy when the message is detected as spoof** is turned on.|
|**If the message is detected as spoof and DMARC Policy is set as p=reject** (_DmarcRejectAction_)|**Reject the message** (`Reject`)|**Reject the message** (`Reject`)|**Reject the message** (`Reject`)|This action is meaningful only when **Honor DMARC record policy when the message is detected as spoof** is turned on.|
|**If the message is detected as spoof by spoof intelligence** (_AuthenticationFailAction_)|**Move the message to the recipients' Junk Email folders** (`MoveToJmf`)|**Move the message to the recipients' Junk Email folders** (`MoveToJmf`)|**Quarantine the message** (`Quarantine`)|This setting applies to spoofed senders that were automatically blocked as shown in the [spoof intelligence insight](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-spoofing-spoof-intelligence?view=o365-worldwide) or manually blocked in the [Tenant Allow/Block List](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/tenant-allow-block-list-email-spoof-configure?view=o365-worldwide#create-block-entries-for-spoofed-senders). <br><br> If you select **Quarantine the message** as the action for the spoof verdict, an **Apply quarantine policy** box is available.|
|**Quarantine policy** for **Spoof** (_SpoofQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if spoof detections are quarantined.|
|**Show first contact safety tip** (_EnableFirstContactSafetyTips_)|Not selected (`$false`)|Selected (`$false`)|Not selected (`$false`)|For more information, see [First contact safety tip](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about?view=o365-worldwide#first-contact-safety-tip).|
|**Show (?) for unauthenticated senders for spoof** (_EnableUnauthenticatedSender_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)|Adds a question mark (?) to the sender's photo in Outlook for unidentified spoofed senders. For more information, see [Unauthenticated sender indicators](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about?view=o365-worldwide#unauthenticated-sender-indicators).|
|**Show "via" tag** (_EnableViaTag_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)|Adds a via tag (chris@contoso.com via fabrikam.com) to the From address if it's different from the domain in the DKIM signature or the **MAIL FROM** address. <br><br> For more information, see [Unauthenticated sender indicators](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about?view=o365-worldwide#unauthenticated-sender-indicators).|
(Microsoft, 23.09.2023)

"¹ As described in [Full access permissions and quarantine notifications](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-policies?view=o365-worldwide#full-access-permissions-and-quarantine-notifications), your organization might use NotificationEnabledPolicy instead of DefaultFullAccessPolicy in the default security policy or in new custom security policies that you create. The only difference between these two quarantine policies is quarantine notifications are turned on in NotificationEnabledPolicy and turned off in DefaultFullAccessPolicy." (Microsoft, 23.09.2023)


### EOP anti-spam policy settings
|Security feature name|Default|Standard|Strict|Comment|
|---|:---:|:---:|:---:|---|
|**Bulk email threshold & spam properties**|||||
|**Bulk email threshold** (_BulkThreshold_)|7|6|5|For details, see [Bulk complaint level (BCL) in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-spam-bulk-complaint-level-bcl-about?view=o365-worldwide).|
|**Bulk email spam** (_MarkAsSpamBulkMail_)|(`On`)|(`On`)|(`On`)|This setting is only available in PowerShell.|
|**Increase spam score** settings||||All of these settings are part of the Advanced Spam Filter (ASF). For more information, see the [ASF settings in anti-spam policies](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide#asf-settings-in-anti-spam-policies) section in this article.|
|**Mark as spam** settings||||Most of these settings are part of ASF. For more information, see the [ASF settings in anti-spam policies](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide#asf-settings-in-anti-spam-policies) section in this article.|
|**Contains specific languages** (_EnableLanguageBlockList_ and _LanguageBlockList_)|**Off** (`$false` and Blank)|**Off** (`$false` and Blank)|**Off** (`$false` and Blank)|We have no specific recommendation for this setting. You can block messages in specific languages based on your business needs.|
|**From these countries** (_EnableRegionBlockList_ and _RegionBlockList_)|**Off** (`$false` and Blank)|**Off** (`$false` and Blank)|**Off** (`$false` and Blank)|We have no specific recommendation for this setting. You can block messages from specific countries/regions based on your business needs.|
|**Test mode** (_TestModeAction_)|**None**|**None**|**None**|This setting is part of ASF. For more information, see the [ASF settings in anti-spam policies](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide#asf-settings-in-anti-spam-policies) section in this article.|
|**Actions**|||||
|**Spam** detection action (_SpamAction_)|**Move message to Junk Email folder** (`MoveToJmf`)|**Move message to Junk Email folder** (`MoveToJmf`)|**Quarantine message** (`Quarantine`)||
|**Quarantine policy** for **Spam** (_SpamQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if spam detections are quarantined.|
|**High confidence spam** detection action (_HighConfidenceSpamAction_)|**Move message to Junk Email folder** (`MoveToJmf`)|**Quarantine message** (`Quarantine`)|**Quarantine message** (`Quarantine`)||
|**Quarantine policy** for **High confidence spam** (_HighConfidenceSpamQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessWithNotificationPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if high confidence spam detections are quarantined.|
|**Phishing** detection action (_PhishSpamAction_)|**Move message to Junk Email folder** (`MoveToJmf`)<sup>\*</sup>|**Quarantine message** (`Quarantine`)|**Quarantine message** (`Quarantine`)|<sup>\*</sup> The default value is **Move message to Junk Email folder** in the default anti-spam policy and in new anti-spam policies that you create in PowerShell. The default value is **Quarantine message** in new anti-spam policies that you create in the Defender portal.|
|**Quarantine policy** for **Phishing** (_PhishQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessWithNotificationPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if phishing detections are quarantined.|
|**High confidence phishing** detection action (_HighConfidencePhishAction_)|**Quarantine message** (`Quarantine`)|**Quarantine message** (`Quarantine`)|**Quarantine message** (`Quarantine`)|Users can't release their own messages that were quarantined as high confidence phishing, regardless of how the quarantine policy is configured. If the policy allows users to release their own quarantined messages, users are instead allowed to _request_ the release of their quarantined high-confidence phishing messages.|
|**Quarantine policy** for **High confidence phishing** (_HighConfidencePhishQuarantineTag_)|AdminOnlyAccessPolicy|AdminOnlyAccessPolicy|AdminOnlyAccessPolicy||
|**Bulk compliant level (BCL) met or exceeded** (_BulkSpamAction_)|**Move message to Junk Email folder** (`MoveToJmf`)|**Move message to Junk Email folder** (`MoveToJmf`)|**Quarantine message** (`Quarantine`)||
|**Quarantine policy** for **Bulk compliant level (BCL) met or exceeded** (_BulkQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if bulk detections are quarantined.|
|**Intra-Organizational messages to take action on** (_IntraOrgFilterState_)|**Default** (Default)|**Default** (Default)|**Default** (Default)|The value **Default** is the same as selecting **High confidence phishing messages**. Currently, in U.S. Government organizations (Microsoft 365 GCC, GCC High, and DoD), the value **Default** is the same as selecting **None**.|
|**Retain spam in quarantine for this many days** (_QuarantineRetentionPeriod_)|15 days|30 days|30 days|This value also affects messages that are quarantined by anti-phishing policies. For more information, see [Quarantine retention](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-about?view=o365-worldwide#quarantine-retention).|
|**Enable spam safety tips** (_InlineSafetyTipsEnabled_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)||
|Enable zero-hour auto purge (ZAP) for phishing messages (_PhishZapEnabled_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)||
|Enable ZAP for spam messages (_SpamZapEnabled_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)||
|**Allow & block list**|||||
|Allowed senders (_AllowedSenders_)|None|None|None||
|Allowed sender domains (_AllowedSenderDomains_)|None|None|None|Adding domains to the allowed domains list is a very bad idea. Attackers would be able to send you email that would otherwise be filtered out. <br><br> Use the [spoof intelligence insight](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-spoofing-spoof-intelligence?view=o365-worldwide) and the [Tenant Allow/Block List](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/tenant-allow-block-list-email-spoof-configure?view=o365-worldwide#spoofed-senders-in-the-tenant-allowblock-list) to review all senders who are spoofing sender email addresses in your organization's email domains or spoofing sender email addresses in external domains.|
|Blocked senders (_BlockedSenders_)|None|None|None||
|Blocked sender domains (_BlockedSenderDomains_)|None|None|None||
|**Image links to remote sites** (_IncreaseScoreWithImageLinks_)|Off|Off|Off||
|**Numeric IP address in URL** (_IncreaseScoreWithNumericIps_)|Off|Off|Off||
|**URL redirect to other port** (_IncreaseScoreWithRedirectToOtherPort_)|Off|Off|Off||
|**Links to .biz or .info websites** (_IncreaseScoreWithBizOrInfoUrls_)|Off|Off|Off||
|**Empty messages** (_MarkAsSpamEmptyMessages_)|Off|Off|Off||
|**Embed tags in HTML** (_MarkAsSpamEmbedTagsInHtml_)|Off|Off|Off||
|**JavaScript or VBScript in HTML** (_MarkAsSpamJavaScriptInHtml_)|Off|Off|Off||
|**Form tags in HTML** (_MarkAsSpamFormTagsInHtml_)|Off|Off|Off||
|**Frame or iframe tags in HTML** (_MarkAsSpamFramesInHtml_)|Off|Off|Off||
|**Web bugs in HTML** (_MarkAsSpamWebBugsInHtml_)|Off|Off|Off||
|**Object tags in HTML** (_MarkAsSpamObjectTagsInHtml_)|Off|Off|Off||
|**Sensitive words** (_MarkAsSpamSensitiveWordList_)|Off|Off|Off||
|**SPF record: hard fail** (_MarkAsSpamSpfRecordHardFail_)|Off|Off|Off||
|**Sender ID filtering hard fail** (_MarkAsSpamFromAddressAuthFail_)|Off|Off|Off||
|**Backscatter** (_MarkAsSpamNdrBackscatter_)|Off|Off|Off||
|**Test mode** (_TestModeAction_)|None|None|None|For ASF settings that support **Test** as an action, you can configure the test mode action to **None**, **Add default X-Header text**, or **Send Bcc message** (`None`, `AddXHeader`, or `BccMessage`). For more information, see [Enable, disable, or test ASF settings](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-spam-policies-asf-settings-about?view=o365-worldwide#enable-disable-or-test-asf-settings).|
(Microsoft, 23.09.2023)

"¹ As described in [Full access permissions and quarantine notifications](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-policies?view=o365-worldwide#full-access-permissions-and-quarantine-notifications), your organization might use NotificationEnabledPolicy instead of DefaultFullAccessPolicy in the default security policy or in new custom security policies that you create. The only difference between these two quarantine policies is quarantine notifications are turned on in NotificationEnabledPolicy and turned off in DefaultFullAccessPolicy." (Microsoft, 23.09.2023)

> [!NOTE]
> "ASF adds `X-CustomSpam:` X-header fields to messages _after_ the messages have been processed by Exchange mail flow rules (also known as transport rules), so you can't use mail flow rules to identify and act on messages that were filtered by ASF." (Microsoft, 23.09.2023)

#### EOP outbound spam policy settings
|Security feature name|Default|Recommended<br>Standard|Recommended<br>Strict|Comment|
|---|:---:|:---:|:---:|---|
|**Set an external message limit** (_RecipientLimitExternalPerHour_)|0|500|400|The default value 0 means use the service defaults.|
|**Set an internal message limit** (_RecipientLimitInternalPerHour_)|0|1000|800|The default value 0 means use the service defaults.|
|**Set a daily message limit** (_RecipientLimitPerDay_)|0|1000|800|The default value 0 means use the service defaults.|
|**Restriction placed on users who reach the message limit** (_ActionWhenThresholdReached_)|**Restrict the user from sending mail until the following day** (`BlockUserForToday`)|**Restrict the user from sending mail** (`BlockUser`)|**Restrict the user from sending mail** (`BlockUser`)||
|**Automatic forwarding rules** (_AutoForwardingMode_)|**Automatic - System-controlled** (`Automatic`)|**Automatic - System-controlled** (`Automatic`)|**Automatic - System-controlled** (`Automatic`)|
|**Send a copy of outbound messages that exceed these limits to these users and groups** (_BccSuspiciousOutboundMail_ and _BccSuspiciousOutboundAdditionalRecipients_)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|We have no specific recommendation for this setting. <br><br> This setting works only in the default outbound spam policy. It doesn't work in custom outbound spam policies that you create.|
|**Notify these users and groups if a sender is blocked due to sending outbound spam** (_NotifyOutboundSpam_ and _NotifyOutboundSpamRecipients_)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|Not selected (`$false` and Blank)|The default [alert policy](https://learn.microsoft.com/en-us/purview/alert-policies#threat-management-alert-policies) named **User restricted from sending email** already sends email notifications to members of the **TenantAdmins** (**Global admins**) group when users are blocked due to exceeding the limits in policy. **We strongly recommend that you use the alert policy rather than this setting in the outbound spam policy to notify admins and other users**. For instructions, see [Verify the alert settings for restricted users](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/outbound-spam-restore-restricted-users?view=o365-worldwide#verify-the-alert-settings-for-restricted-users).|
(Microsoft, 23.09.2023)

### EOP anti-malware policy settings
|Security feature name|Default|Standard|Strict|Comment|
|---|:---:|:---:|:---:|---|
|**Protection settings**|||||
|**Enable the common attachments filter** (_EnableFileFilter_)|Selected (`$true`)<sup>\*</sup>|Selected (`$true`)|Selected (`$true`)|For the list of file types in the common attachments filter, see [Common attachments filter in anti-malware policies](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-malware-protection-about?view=o365-worldwide#common-attachments-filter-in-anti-malware-policies). <br><br> <sup>\*</sup> The common attachments filter is on by default in new anti-malware policies that you create in the Defender portal. The common attachments filter is off by default in the default anti-malware policy and in new policies that you create in PowerShell.|
|Common attachment filter notifications: **When these file types are found** (_FileTypeAction_)|**Reject the message with a non-delivery report (NDR)** (`Reject`)|**Reject the message with a non-delivery report (NDR)** (`Reject`)|**Reject the message with a non-delivery report (NDR)** (`Reject`)||
|**Enable zero-hour auto purge for malware** (_ZapEnabled_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)||
|**Quarantine policy** (_QuarantineTag_)|AdminOnlyAccessPolicy|AdminOnlyAccessPolicy|AdminOnlyAccessPolicy||
|**Admin notifications**|||||
|**Notify an admin about undelivered messages from internal senders** (_EnableInternalSenderAdminNotifications_ and _InternalSenderAdminAddress_)|Not selected (`$false`)|Not selected (`$false`)|Not selected (`$false`)|We have no specific recommendation for this setting.|
|**Notify an admin about undelivered messages from external senders** (_EnableExternalSenderAdminNotifications_ and _ExternalSenderAdminAddress_)|Not selected (`$false`)|Not selected (`$false`)|Not selected (`$false`)|We have no specific recommendation for this setting.|
|**Customize notifications**||||No specific recommendations for these settings.|
(Microsoft, 23.09.2023)

## Microsoft Defender for Office 365 security
Additional security benefits come with a Microsoft Defender for Office 365 subscription. 

> [!IMPORTANT]
>
> - The default anti-phishing policy in Microsoft Defender for Office 365 provides [spoof protection](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about?view=o365-worldwide#spoof-settings) and mailbox intelligence for all recipients. However, the other available [impersonation protection](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide#impersonation-settings-in-anti-phishing-policies-in-microsoft-defender-for-office-365) features and [advanced settings](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide#advanced-settings-in-anti-phishing-policies-in-microsoft-defender-for-office-365) are not configured or enabled in the default policy. To enable all protection features, use one of the following methods:
>   - Turn on and use the Standard and/or Strict [preset security policies](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/preset-security-policies?view=o365-worldwide) and configure impersonation protection there.
>   - Modify the default anti-phishing policy.
>   - Create additional anti-phishing policies.
>
> - Although there's no default Safe Attachments policy or Safe Links policy, the **Built-in protection** preset security policy provides Safe Attachments protection and Safe Links protection to all recipients who aren't defined in the Standard preset security policy, the Strict preset security policy, or in custom Safe Attachments or Safe Links policies). For more information, see [Preset security policies in EOP and Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/preset-security-policies?view=o365-worldwide).
>
> - [Safe Attachments for SharePoint, OneDrive, and Microsoft Teams](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-attachments-for-spo-odfb-teams-about?view=o365-worldwide) protection and [Safe Documents](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-documents-in-e5-plus-security-about?view=o365-worldwide) protection have no dependencies on Safe Links policies. 
(Microsoft, 23.09.2023)

If your subscription includes Microsoft Defender for Office 365 or if you've purchased Defender for Office 365 as an add-on, set the following Standard or Strict configurations.

### Anti-phishing policy settings in Microsoft Defender for Office 365

"EOP customers get basic anti-phishing as previously described, but Defender for Office 365 includes more features and control to help prevent, detect, and remediate against attacks. To create and configure these policies, see [Configure anti-phishing policies in Defender for Office 365](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-mdo-configure?view=o365-worldwide)." (Microsoft, 23.09.2023)

#### Advanced settings in anti-phishing policies in Microsoft Defender for Office 365
|Security feature name|Default|Standard|Strict|Comment|
|---|:---:|:---:|:---:|---|
|**Phishing email threshold** (_PhishThresholdLevel_)|**1 - Standard** (`1`)|**3 - More aggressive** (`3`)|**4 - Most aggressive** (`4`)||
(Microsoft, 23.09.2023)

#### Impersonation settings in anti-phishing policies in Microsoft Defender for Office 365
|Security feature name|Default|Standard|Strict|Comment|
|---|:---:|:---:|:---:|---|
|**Phishing threshold & protection**|||||
|User impersonation protection: **Enable users to protect** (_EnableTargetedUserProtection_ and _TargetedUsersToProtect_)|Not selected (`$false` and none)|Selected (`$true` and \<list of users\>)|Selected (`$true` and \<list of users\>)|We recommend adding users (message senders) in key roles. Internally, protected senders might be your CEO, CFO, and other senior leaders. Externally, protected senders could include council members or your board of directors.|
|Domain impersonation protection: **Enable domains to protect**|Not selected|Selected|Selected||
|**Include domains I own** (_EnableOrganizationDomainsProtection_)|Off (`$false`)|Selected (`$true`)|Selected (`$true`)||
|**Include custom domains** (_EnableTargetedDomainsProtection_ and _TargetedDomainsToProtect_)|Off (`$false` and none)|Selected (`$true` and \<list of domains\>)|Selected (`$true` and \<list of domains\>)|We recommend adding domains (sender domains) that you don't own, but you frequently interact with.|
|**Add trusted senders and domains** (_ExcludedSenders_ and _ExcludedDomains_)|None|None|None|Depending on your organization, we recommend adding senders or domains that are incorrectly identified as impersonation attempts.|
|**Enable mailbox intelligence** (_EnableMailboxIntelligence_)|Selected (`$true`)|Selected (`$true`)|Selected (`$true`)||
|**Enable intelligence for impersonation protection** (_EnableMailboxIntelligenceProtection_)|Off (`$false`)|Selected (`$true`)|Selected (`$true`)|This setting allows the specified action for impersonation detections by mailbox intelligence.|
|**Actions**|||||
|**If a message is detected as user impersonation** (_TargetedUserProtectionAction_)|**Don't apply any action** (`NoAction`)|**Quarantine the message** (`Quarantine`)|**Quarantine the message** (`Quarantine`)||
|**Quarantine policy** for **user impersonation** (_TargetedUserQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessWithNotificationPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if user impersonation detections are quarantined.|
|**If a message is detected as domain impersonation** (_TargetedDomainProtectionAction_)|**Don't apply any action** (`NoAction`)|**Quarantine the message** (`Quarantine`)|**Quarantine the message** (`Quarantine`)||
|**Quarantine policy** for **domain impersonation** (_TargetedDomainQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessWithNotificationPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if domain impersonation detections are quarantined.|
|**If mailbox intelligence detects an impersonated user** (_MailboxIntelligenceProtectionAction_)|**Don't apply any action** (`NoAction`)|**Move the message to the recipients' Junk Email folders** (`MoveToJmf`)|**Quarantine the message** (`Quarantine`)||
|**Quarantine policy** for **mailbox intelligence impersonation** (_MailboxIntelligenceQuarantineTag_)|DefaultFullAccessPolicy¹|DefaultFullAccessPolicy|DefaultFullAccessWithNotificationPolicy|The quarantine policy is meaningful only if mailbox intelligence detections are quarantined.|
|**Show user impersonation safety tip** (_EnableSimilarUsersSafetyTips_)|Off (`$false`)|Selected (`$true`)|Selected (`$true`)||
|**Show domain impersonation safety tip** (_EnableSimilarDomainsSafetyTips_)|Off (`$false`)|Selected (`$true`)|Selected (`$true`)||
|**Show user impersonation unusual characters safety tip** (_EnableUnusualCharactersSafetyTips_)|Off (`$false`)|Selected (`$true`)|Selected (`$true`)||
(Microsoft, 23.09.2023)

¹ "As described in [Full access permissions and quarantine notifications](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-policies?view=o365-worldwide#full-access-permissions-and-quarantine-notifications), your organization might use NotificationEnabledPolicy instead of DefaultFullAccessPolicy in the default security policy or in new custom security policies that you create. The only difference between these two quarantine policies is quarantine notifications are turned on in NotificationEnabledPolicy and turned off in DefaultFullAccessPolicy." (Microsoft, 23.09.2023)

#### EOP anti-phishing policy settings in Microsoft Defender for Office 365

"These are the same settings that are available in [anti-spam policy settings in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide#eop-anti-spam-policy-settings)." (Microsoft, 23.09.2023)

