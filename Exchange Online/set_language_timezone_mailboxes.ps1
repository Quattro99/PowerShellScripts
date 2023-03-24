## Connect to Exchange Online
Connect-ExchangeOnline

## Get all mailboxes and set the regional configuration
Get-Mailbox -ResultSize unlimited | ? {$_.RecipientTypeDetails -eq "UserMailbox"} | Set-MailboxRegionalConfiguration -Language "de-CH" -DateFormat "dd.MM.yyyy" -TimeFormat "HH:mm" -TimeZone "W. Europe Standard Time" -LocalizeDefaultFolderName

## Get information to all mailboxes
Get-Mailbox | Get-MailboxRegionalConfiguration