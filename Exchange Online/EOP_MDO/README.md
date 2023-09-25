# Recomended EOP / MDO standard settings of Microsoft

The primary functionality of the script is to automatically deploy standard Microsoft best-practice settings for EOP and MDO to a customer's Microsoft 365 tenant. These settings enhance email security and protection against threats.
The script performs a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Microsoft 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
This script is a valuable tool for administrators tasked with securing an Microsoft 365 environment efficiently and in line with recommended security practices.

With this script you can deploy the standard settings to a customer tenant: https://github.com/Quattro99/PowerShellScripts/blob/6b7a612432729f86e163a7094f971042d02e387d/Exchange%20Online/EOP_MDO/xxx-standard-auto-mdo_eop.ps1


## Description of the script

### local variables
> [!IMPORTANT]
> Some values have to be changed before running the script. Those values are marked with a comment in the script.

| Commandlet | Value | Description | 
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

| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- | 
| function | main |  |
|  | exoauthentication | |
|  | enableorgcustomization | |
|  | defaultsharingpermission | |
|  | adminauditlog | |
|  | disableimappop | |
|  | disableexternalforwarding | |
|  | createsharedmailbox | |
| $domains | Get-AcceptedDomain | |
| $domainname | $domains.Name | |
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



### EOP anti-malware policy settings

Quarantine policies define what users are able to do to quarantined messages, and whether users receive quarantine notifications. The policy named AdminOnlyAccessPolicy enforces the historical capabilities for messages that were quarantined as malware. Users can't release their own messages that were quarantined as malware, regardless of how the quarantine policy is configured. If the policy allows users to release their own quarantined messages, users are instead allowed to _request_ the release of their quarantined malware messages.

|Security feature name|Standard|Comment|
|---|:---:|---|
|**Protection settings**|||
|**Enable the common attachments filter** (_EnableFileFilter_)|Selected (`$true`)|For the list of file types in the common attachments filter, follow this [link] (https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-malware-protection-about?view=o365-worldwide#common-attachments-filter-in-anti-malware-policies). The common attachments filter is on by default in new anti-malware policies that you create in the Defender portal. The common attachments filter is off by default in the default anti-malware policy and in new policies that you create in PowerShell.|
|Common attachment filter notifications: **When these file types are found** (_FileTypeAction_)|**Reject the message with a non-delivery report (NDR)** (`Reject`)||
|**Enable zero-hour auto purge for malware** (_ZapEnabled_)|Selected (`$true`)||
|**Quarantine policy** (_QuarantineTag_)|AdminOnlyAccessPolicy||
|**Admin notifications**|||
|**Notify an admin about undelivered messages from internal senders** (_EnableInternalSenderAdminNotifications_ and _InternalSenderAdminAddress_)|Not selected (`$false`)||
|**Notify an admin about undelivered messages from external senders** (_EnableExternalSenderAdminNotifications_ and _ExternalSenderAdminAddress_)|Not selected (`$false`)||
|**Customize notifications**|||
|**Use customized notification text** (_CustomNotifications_)|Not selected (`$false`)||
|**From name** (_CustomFromName_)|Blank||
|**From address** (_CustomFromAddress_)|Blank|||
|**Customize notifications for messages from internal senders**||These settings are used only if **Notify an admin about undelivered messages from internal senders** is selected.|
|**Subject** (_CustomInternalSubject_)|Blank||
|**Message** (_CustomInternalBody_)|Blank||
|**Customize notifications for messages from external senders**||These settings are used only if **Notify an admin about undelivered messages from external senders** is selected.|
|**Subject** (_CustomExternalSubject_)|Blank||
|**Message** (_CustomExternalBody_)|Blank||











