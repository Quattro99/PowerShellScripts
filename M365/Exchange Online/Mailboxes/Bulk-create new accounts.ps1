## Install module MSOnline
Install-Module MSOnline

## Import module MSOnline
Import-Module MSOnline

## Connect to the MsolService
Connect-MsolService


## Import CSV and creation of Useraccounts as well as export of all passwords
Import-Csv -Path "C:\Softlib\O365\NewAccounts.csv" | foreach {New-MsolUser -DisplayName $_.DisplayName -FirstName $_.FirstName -LastName $_.LastName -UserPrincipalName $_.UserPrincipalName -UsageLocation $_.UsageLocation -LicenseAssignment $_.AccountSkuId} | Export-Csv -Path "C:\Softlib\O365\NewAccountResults.csv" -Verbose