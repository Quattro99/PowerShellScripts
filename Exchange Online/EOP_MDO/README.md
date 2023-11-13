# Recomended EOP / MDO standard & strict settings of Microsoft

The primary functionality of the scripts are to automatically deploy standard or strict Microsoft best-practice settings for EOP and MDO to a customer's Microsoft 365 tenant. These settings enhance email security and protection against threats.
The scripts perform a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Microsoft 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
These scripts are a valuable tool for administrators tasked with securing a Microsoft 365 environment efficiently and in line with recommended security practices.

*"**Exchange Online Protection (EOP)** is the core of security for Microsoft 365 subscriptions and helps keep malicious emails from reaching your employee's inboxes. But with new, more sophisticated attacks emerging every day, improved protections are often required. **Microsoft Defender for Office 365** Plan 1 or Plan 2 contain additional features that give more layers of security, control, and investigation."* (Microsoft, 23.09.2023)

*"Although we empower security administrators to customize their security settings, there are two security levels in EOP and Microsoft Defender for Office 365 that we recommend: **Standard** and **Strict**. Although customer environments and needs are different, these levels of filtering help prevent unwanted mail from reaching your employees' Inbox in most situations."* (Microsoft, 23.09.2023)


* With this script you can deploy the standard settings to a customer tenant: [xxx-standard-auto-mdo_eop.ps1]
* With this script you can deploy the strict settings to a customer tenant: [xxx-srict-auto-mdo_eop.ps1]

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