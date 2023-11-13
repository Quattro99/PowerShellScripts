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

"For more information about these settings, see [Spoof settings](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about?view=o365-worldwide#spoof-settings). To configure these settings, see [Configure anti-phishing policies in EOP](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-eop-configure?view=o365-worldwide)." (Microsoft, 23.09.2023)

"The spoof settings are inter-related, but the **Show first contact safety tip** setting has no dependency on spoof settings." (Microsoft, 23.09.2023)

"Quarantine policies define what users are able to do to quarantined messages, and whether users receive quarantine notifications. For more information, see [Anatomy of a quarantine policy](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-policies?view=o365-worldwide#anatomy-of-a-quarantine-policy)." (Microsoft, 23.09.2023)

"Although the **Apply quarantine policy** value appears unselected when you create an anti-phishing policy in the Defender portal, the quarantine policy named DefaultFullAccessPolicy¹ is used if you don't select a quarantine policy. This policy enforces the historical capabilities for messages that were quarantined as spoof as described in the table [here](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-end-user?view=o365-worldwide). When you later view or edit the quarantine policy settings, the quarantine policy name is shown." (Microsoft, 23.09.2023)

"Admins can create or use quarantine policies with more restrictive or less restrictive capabilities. For instructions, see [Create quarantine policies in the Microsoft 365 Defender portal](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-policies?view=o365-worldwide#step-1-create-quarantine-policies-in-the-microsoft-365-defender-portal)." (Microsoft, 23.09.2023)

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
¹ As described in [Full access permissions and quarantine notifications](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/quarantine-policies?view=o365-worldwide#full-access-permissions-and-quarantine-notifications), your organization might use NotificationEnabledPolicy instead of DefaultFullAccessPolicy in the default security policy or in new custom security policies that you create. The only difference between these two quarantine policies is quarantine notifications are turned on in NotificationEnabledPolicy and turned off in DefaultFullAccessPolicy.