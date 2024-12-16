$identities = Get-Mailbox -resultsize unlimited


foreach ($identity in $identities) {

Get-MailboxPermission -Identity $identity | Select-Object Identity, User, AccessRights | Export-Csv -Path C:\temp\permissions.csv -NoTypeInformation -Append
}
