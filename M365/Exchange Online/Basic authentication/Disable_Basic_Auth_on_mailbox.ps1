$AdminUPN = ""
$Identity = ""

Connect-ExchangeOnline -UserPrincipalName $AdminUPN

$Users = Get-CASMailbox -ResultSize unlimited
$Users | where {$_.SmtpClientAuthenticationDisabled -eq $false}

foreach ($user in $users)
{
    Set-CASMailbox -Identity $Identity -PopEnabled $True -ImapEnabled $True -MAPIEnabled $True -ActiveSyncEnabled $True -EWSEnabled $True -SmtpClientAuthenticationDisabled $false
}