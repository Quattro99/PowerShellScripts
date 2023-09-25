# Recomended EOP / MDO standard settings of Microsoft

The primary functionality of the script is to automatically deploy standard Microsoft best-practice settings for EOP and MDO to a customer's Office 365 tenant. These settings enhance email security and protection against threats.
The script performs a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Office 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
This script is a valuable tool for administrators tasked with securing an Office 365 environment efficiently and in line with recommended security practices.

With this script you can deploy the standard settings to a customer tenant: https://github.com/Quattro99/PowerShellScripts/blob/6b7a612432729f86e163a7094f971042d02e387d/Exchange%20Online/EOP_MDO/xxx-standard-auto-mdo_eop.ps1


## Description of the script

### local variables
| Commandlet | Value | Description | 
| ------------- | ------------- | ------------- | 
| $module1  | "ExchangeOnlineManagement" | The name of the PowerShell module that has to be installed for this script |
| $csa  | xxx | Exchange Online administrator for example csa-mbl@domain.onmicrosoft.com |
| $custonmicrosoft | customer.onmicrosoft.com | The onmicrosoft domain of the customer. **The value *customer* has to be changed before running the script** |
| $sharedmailboxname | "Quarantäne - xxx" |  |
| $sharedMailboxAlias | "quarantine" |  |
| $sharedMailboxEmail | "quarantine@domain.tld" |  |
| $LogPath | xxx |  |