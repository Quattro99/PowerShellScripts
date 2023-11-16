<#
.Synopsis
  The script is designed to automatically apply recommended settings for EOP and MDO to a customer's Microsoft 365 tenant.x
.DESCRIPTION
  The script aims to configure various security settings to enhance the security posture of the Microsoft 365 environment, following Microsoft's best practices.
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
	 Filename:     	xxx-standard-auto-mdo_eop.ps1
	===========================================================================
.COMPONENT
   The script utilizes the Exchange Online Management module to interact with Exchange Online.
.ROLE
   The script is relevant for roles related to Security, Exchange Online and Microsoft Defender.
.FUNCTIONALITY
   The primary functionality of the script is to automatically deploy standard Microsoft best-practice settings for EOP and MDO to a customer's Microsoft 365 tenant. These settings enhance email security and protection against threats.
   The script performs a series of actions, including creating and configuring Safe Links and Safe Attachments policies, setting up anti-phishing policies, configuring MDO settings for Microsoft 365 apps, defining spam and malware filter policies, adjusting sharing policies, enabling audit logs, disabling IMAP and POP access, and blocking client forwarding rules. Finally, it disconnects from the Exchange Online session.
   This script is a valuable tool for administrators tasked with securing an Microsoft 365 environment efficiently and in line with recommended security practices
#>


#----- Local variables -----#
# Name of the PowerShell module to install & import
$module1 = "ExchangeOnlineManagement"
$module2 = "O365CentralizedAddInDeployment"

# csa username
$csa = Read-Host -Prompt "Enter your csa username"

# Connect to a customer tenant over the onmicrosoft domain via GDAP permissions
$custommicrosoft = $csa = Read-Host -Prompt "Enter the onmicrosoft address of the customer eq. customer.onmicrosoft.com"

# Organisation language
$language = Read-Host -Prompt "Enter the language of the tenant eq. English or Deutsch (can be checked in the Entra ID Properties notification language)"

# Shared Mailbox for quarantine e-mails
$sharedmailboxname = Read-Host -Prompt "Enter the Shared Mailbox name eq. Quarantaene - xxx"
$sharedMailboxAlias = Read-Host -Prompt "Enter the Shared Mailbox alias eq. quarantine"
$sharedMailboxEmail = Read-Host -Prompt "Enter the Shared Mailbox mail address eq. quarantine@domain.tld"
$sharedmailboxesaccess = Read-Host -Prompt "Enter who should have access to the quarantine mailbox eq. 'michele.blum@domain.tdl', 'flavio.meyer@domain.tdl'"

# Spoofing Protection; Users that have to be protected against spoofing (CEO, CFO etc.)
$targeteduserstoprotect = Read-Host -Prompt "Enter user which have to be protcted against spoofing .eq 'DisplayName1;EmailAddress1','DisplayName2;EmailAddress2',...'DisplayNameN;EmailAddressN'"

# Log path for script output
$LogPath = Read-Host -Prompt "Specify the log path for the script"

# Defines the blocked file extensions of the anti maleware policy
$filetypes = ".ace",".apk",".app",".appx",".ani",".arj",".bat",".cab",".cmd",".com",".deb",".dex",".dll",".docm",".elf",".exe",".hta",".img",".iso",".jar",".jnlp",".kext",".lha",".lib",".library",".lnk",".lzh",".macho",".msc",".msi",".msix",".msp",".mst",".pif",".ppa",".ppam",".reg",".rev",".scf",".scr",".sct",".sys",".uif",".vb",".vbe",".vbs",".vxd",".wsc",".wsf",".wsh",".xll",".xz",".z"


#----- main-function -----#
## !!! Please change the function before running. Not every fucntion can be run on every tenant!!!
### Change array of the $domain variable if there are more than one accepted domain
function main () {
  exoauthentication
  enableorgcustomization
  defaultsharingpermission
  adminauditlog
  disableimappop
  disableexternalforwarding
  createsharedmailbox
  # Fill all accepted domains of the tenant in a variable
  $domains = Get-AcceptedDomain | Where-Object {$_.DomainName -notlike '*onmicrosoft.com*'}
  antiphishpolicy
  antispampolicy
  malewarefilterpolicy
  safeattachmentpolicy
  safelinkspolicy
  globalquarantinesettings
  mdoaddin
  exodisconnect
}


#----- exoauthentication-function -----#
function exoauthentication {
  # Check if the PowerShell module is installed on the local computer
  if (-not (Get-Module -ListAvailable -Name $module1)) {

    Write-Host "Exchange Online Management Module not installed. Module will be installed."

    # Install the module, if not installed, to the scope of the currentuser
    Install-Module $module1 -Scope CurrentUser -Force

    # Import the module
    Import-Module $module1
  }

  else {

    Write-Host "Exchange Online Management Module already installed."

    # Import the module
    Import-Module $module1
  }

    # Connect to the exo tenant with your exo admin and security admin (gdap organization)
    Connect-ExchangeOnline -UserPrincipalName $csa -DelegatedOrganization $custommicrosoft

}


#----- enableorgcustomization-function -----#
function enableorgcustomization {
  if (Get-OrganizationConfig | Where-Object isDehydrated -eq $true)
  {
    Write-Host "Organization Customization is not enabled. Changing the setting."
    Enable-OrganizationCustomization
  }
  else {
    Write-Host "Organization Customization already enabled."
  }
}


#----- defaultsharingpermission-function -----#
function defaultsharingpermission {
  # Default Sharing Policy Calendar 
  if ($language -eq "English")
  {
    Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{ Remove = "Anonymous:CalendarSharingFreeBusyReviewer","Anonymous:CalendarSharingFreeBusySimple","Anonymous:CalendarSharingFreeBusyDetail" }
    Set-SharingPolicy -Identity "Default Sharing Policy" -Domains "*:CalendarSharingFreeBusySimple"
  }
  else {
    Set-SharingPolicy -Identity "Standardfreigaberichtlinie" -Domains @{ Remove = "Anonymous:CalendarSharingFreeBusyReviewer","Anonymous:CalendarSharingFreeBusySimple","Anonymous:CalendarSharingFreeBusyDetail" }
    Set-SharingPolicy -Identity "Standardfreigaberichtlinie" -Domains "*:CalendarSharingFreeBusySimple"
  }

}


#----- adminauditlog-function -----#
function adminauditlog {
  # Set admin audit log 
  Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
}


#----- disableimappop-function -----#
function disableimappop {
  # Disable IMAP & POP service in the standard configuration settings if a new mailbox will be deployed (be careful with that, some services might not work anymore)
  ## Double check this setting with the customer and the tenant
  Get-CASMailboxPlan | Set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false

  # Disable IMAP & POP service on all mailboxes (be careful with that, some services might not work anymore)
  ## Double check this setting with the customer and the tenant
  Get-CASMailbox | Set-CASMailbox -PopEnabled $false -ImapEnabled $false

}


#----- disableexternalforwarding-function -----#
function disableexternalforwarding {
  # Block Client Forwarding Rules (be careful with that, some services might not work anymore)
  ## Double check this setting with the customer and the tenant
  if (Get-TransportRule | Where-Object {$_.Name -notlike '*External Block*'} )
    {
    New-TransportRule -Name "Client Rules To External Block" -Priority 0 -SentToScope NotInOrganization -FromScope InOrganization -MessageTypeMatches AutoForward -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText "Das automatische weiterleiten von Mails an externe Adressen ist nicht gestattet. Bitte kontaktieren sie Ihre IT."
    Set-RemoteDomain * -AutoForwardEnabled $false
    }
    else {
      Write-Host "External forwarding ist already disabled"
    }

}


#----- createsharedmailbox-function -----#
function createsharedmailbox {
  # Create Shared Mailbox for quarantine e-mails
  New-Mailbox -Shared -Name $sharedmailboxname -DisplayName $sharedmailboxname -Alias $sharedMailboxAlias -PrimarySmtpAddress $sharedMailboxEmail

    # Waiting 30 seconds for granting permissions on mailbox
    Write-Host "Waiting 15 seconds for granting permissions on mailbox"
    Start-Sleep -seconds 15

  # Adds permissions to the shared mailbox
    foreach ($sharedmailboxaccess in $sharedmailboxesaccess)
    {
    Add-MailboxPermission -Identity $sharedMailboxEmail -User $sharedmailboxaccess -AccessRights FullAccess -AutoMapping:$false
    }
    
  }

#----- antiphishingpolicy-function -----#
function antiphishpolicy {
  # Configure the standard Anti-phishing policy and rule: 
  New-AntiPhishPolicy -Name "xxx Standard - Anti-Phishing Policy" -Enabled $True -EnableSpoofIntelligence $True -HonorDmarcPolicy $True -DmarcQuarantineAction Quarantine -DmarcRejectAction Reject -AuthenticationFailAction MoveToJmf -SpoofQuarantineTag DefaultFullAccessPolicy -EnableFirstContactSafetyTips $False -EnableUnauthenticatedSender $True -EnableViaTag $True -PhishThresholdLevel 3 -EnableTargetedUserProtection $True -TargetedUsersToProtect $targeteduserstoprotect -EnableOrganizationDomainsProtection $True -EnableTargetedDomainsProtection $False -EnableMailboxIntelligence $True -EnableMailboxIntelligenceProtection $True -TargetedUserProtectionAction Quarantine -TargetedUserQuarantineTag DefaultFullAccessWithNotificationPolicy -TargetedDomainProtectionAction Quarantine -TargetedDomainQuarantineTag DefaultFullAccessWithNotificationPolicy -MailboxIntelligenceProtectionAction MoveToJmf -MailboxIntelligenceQuarantineTag DefaultFullAccessPolicy -EnableSimilarUsersSafetyTips $True -EnableSimilarDomainsSafetyTips $True -EnableUnusualCharactersSafetyTips $True 
  New-AntiPhishRule -Name "xxx Standard - Anti-Phishing Rule" -AntiPhishPolicy "xxx Standard - Anti-Phishing Policy" -RecipientDomainIs $domains
}


#----- antispampolicy-function -----#
function antispampolicy {
  # Configure the standard Anti-spam inbound policy and rule: 
  New-HostedContentFilterPolicy -Name "xxx Standard - Anti-Spam Policy" -BulkThreshold 6 -MarkAsSpamBulkMail On -EnableLanguageBlockList $False -EnableRegionBlockList $False -TestModeAction None -SpamAction MoveToJmf -SpamQuarantineTag DefaultFullAccessPolicy -HighConfidenceSpamAction Quarantine -HighConfidenceSpamQuarantineTag DefaultFullAccessWithNotificationPolicy -PhishSpamAction Quarantine -PhishQuarantineTag DefaultFullAccessWithNotificationPolicy -HighConfidencePhishAction Quarantine -HighConfidencePhishQuarantineTag AdminOnlyAccessPolicy -BulkSpamAction MoveToJmf -BulkQuarantineTag DefaultFullAccessPolicy -QuarantineRetentionPeriod 30 -InlineSafetyTipsEnabled $True -PhishZapEnabled $True -SpamZapEnabled $True -IncreaseScoreWithImageLinks Off -IncreaseScoreWithNumericIps Off -IncreaseScoreWithRedirectToOtherPort Off -IncreaseScoreWithBizOrInfoUrls Off -MarkAsSpamEmptyMessages Off -MarkAsSpamObjectTagsInHtml Off -MarkAsSpamJavaScriptInHtml Off -MarkAsSpamFormTagsInHtml Off -MarkAsSpamFramesInHtml Off -MarkAsSpamWebBugsInHtml Off -MarkAsSpamEmbedTagsInHtml Off -MarkAsSpamSensitiveWordList Off -MarkAsSpamSpfRecordHardFail Off -MarkAsSpamFromAddressAuthFail Off -MarkAsSpamNdrBackscatter Off 
  New-HostedContentFilterRule -Name "xxx Standard - Anti-Spam Policy" -HostedContentFilterPolicy "xxx Standard - Anti-Spam Policy" -RecipientDomainIs $domains

  # Configure the standard Anti-spam outbound policy and rule:
  New-HostedOutboundSpamFilterPolicy -Name "xxx Standard - Anti-Spam Outbound Policy" -RecipientLimitExternalPerHour 500 -RecipientLimitInternalPerHour 1000 -RecipientLimitPerDay 1000 -ActionWhenThresholdReached BlockUser -AutoForwardingMode Automatic -BccSuspiciousOutboundMail $False 
  New-HostedOutboundSpamFilterRule -Name "xxx Standard - Anti-Spam Outbound Policy" -HostedOutboundSpamFilterPolicy "xxx Standard - Anti-Spam Outbound Policy" -SenderDomainIs $domains
}


#----- antimalewarepolicy-function -----#
function malewarefilterpolicy {
  # Configure the standard Anti-maleware policy and rule: 
  New-MalwareFilterPolicy -Name "xxx Standard - Anti-Malware Policy" -EnableFileFilter $True -FileTypes $filetypes -FileTypeAction Reject -ZapEnabled $True -QuarantineTag AdminOnlyAccessPolicy -EnableInternalSenderAdminNotifications $False -EnableExternalSenderAdminNotifications $False -CustomNotifications $False
  New-MalwareFilterRule -Name "xxx Standard - Anti-Malware Policy" -MalwareFilterPolicy "xxx Standard - Anti-Malware Policy" -RecipientDomainIs $domains
}


#----- safeattachmentpolicy-function -----#
function safeattachmentpolicy {
  # Configure global settings for Safe Attachments:
  Set-AtpPolicyForO365 "Default" -EnableATPForSPOTeamsODB $True -EnableSafeDocs $False -AllowSafeDocsOpen $False

  # Configure default Safe Attachments policy and rule: 
  New-SafeAttachmentPolicy -Name "xxx Standard - Safe Attachment Policy" -Enable $True -Action Block -QuarantineTag AdminOnlyAccessPolicy -Redirect $False
  New-SafeAttachmentRule -Name "xxx Standard - Safe Attachment Rule" -SafeAttachmentPolicy "xxx Standard - Safe Attachment Policy" -RecipientDomainIs $domains

}


#----- safelinkspolicy-function -----#
function safelinkspolicy {
  # Configure default Safe Links policy and rule: 
  New-SafeLinksPolicy -Name "xxx Standard - Safe Links Policy" -EnableSafeLinksForEmail $True -EnableForInternalSenders $True -ScanUrls $True -DeliverMessageAfterScan $True -DisableUrlRewrite $False -EnableSafeLinksForTeams $True -EnableSafeLinksForOffice $True -TrackClicks $True -AllowClickThrough $False -EnableOrganizationBranding $True
  New-SafeLinksRule -Name "xxx Standard - Safe Links Rule" -SafeLinksPolicy "xxx Standard - Safe Links Policy" -RecipientDomainIs $domains
}


#----- globalquarantinesettings-function -----#
function globalquarantinesettings {
  # Configure global quarantine settings: 
  Get-QuarantinePolicy -QuarantinePolicyType GlobalQuarantinePolicy | Set-QuarantinePolicy -EndUserSpamNotificationFrequency 7.00:00:00 -EndUserSpamNotificationFrequencyInDays 3 -EndUserSpamNotificationCustomFromAddress $sharedMailboxEmail -MultiLanguageCustomDisclaimer "WICHTIGER HINWEIS: Dies ist eine automatisch generierte E-Mail, die von unserem Quarantaenesystem erfasst wurde. Das Freigeben von E-Mails muss mit Bedacht und Vorsicht durchgefuehrt werden." -EsnCustomSubject "Ihr woechentlicher Quarantaene Auszug" -MultiLanguageSenderName $sharedmailboxname -MultiLanguageSetting "German" -OrganizationBrandingEnabled $True
}

#----- mdoaddin-function -----#
function mdoaddin{
  if (-not (Get-Module -ListAvailable -Name $module2)) {

    Write-Host "O365CentralizedAddInDeployment Module not installed. Module will be installed."

    # Install the module, if not installed, to the scope of the currentuser
    Install-Module $module2 -Scope CurrentUser -Force

    # Import the module
    Import-Module $module2
  }

  else {

    Write-Host "O365CentralizedAddInDeployment Module already installed."

    # Import the module
    Import-Module $module2
  }

  # Connect to the ms365 tenant with your ms365 user admin and application admin (gdap organization)
  Connect-OrganizationAddInService

  # Adds the Report Message add in to the tenant
  New-OrganizationAddIn -AssetId 'WA104381180' -Locale 'de-CH' -ContentMarket 'de-CH'

  # Waiting 30 seconds for granting permissions to the entier organisation
  Write-Host "Waiting 30 seconds for granting permissions to the entier organisation"
  Start-Sleep -seconds 30

  # Assigns the add in to all users
  Set-OrganizationAddInAssignments -ProductId 6046742c-3aee-485e-a4ac-92ab7199db2e -AssignToEveryone $true
}


#----- exodisconnect-function -----#
function exodisconnect {
  # Disconnect from exo 
  Disconnect-ExchangeOnline -Confirm:$false
}


#----- logging-function -----#
# Call local inforamtion of the runtime script
$prefix = $MyInvocation.MyCommand.Name
Start-Transcript -Path $LogPath -Append
$elapsed = (Get-Date) - $start
$runtimesec = $elapsed.TotalSeconds


#----- Entry point -----#
$start = $null
$start = Get-Date
main
