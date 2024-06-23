## Open Windows PowerShell and navigate to the “Microsoft Azure Active Directory Connect” folder:
cd 'C:\Program Files\Microsoft Azure Active Directory Connect\'

## Import the Seamless SSO PowerShell module:
Import-Module .\AzureADSSO.psd1

## Now run the following command to authenticate with Azure AD using your AAD credentials:
New-AzureADSSOAuthenticationContext

## View current SSO status of AD forest. This is useful when you have multiple Active Directory forests synchronizing to the same Azure AD tenant:
Get-AzureADSSOStatus | ConvertFrom-Json

## Update the SSO account. Provide AD domnain admin credentials. Provide credentials like domain.tld\administrator:
Update-AzureADSSOForest
## There should not appear errors. If so, the change wasn't successful.

## Check if the password of the account has been succsessfully changed:
Get-ADComputer AZUREADSSOACC -Properties * | FL Name,PasswordLastSet