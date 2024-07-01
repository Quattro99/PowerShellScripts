Param(
    [int]$InactiveAccountInDay = 180,
    [int]$UnusedAccountInDay = 360,
    [int]$OutdatedPasswordInDay = 180
    )

Function New-AdAccountCheckItem {
    Param(
        [string]$Name,
        [Object[]]$Data
    )

    [pscustomobject]@{
        Name = $Name
        Count = $Data.Count
        SamAccountName = $Data | Select-Object -ExpandProperty SamAccountName
        Data  = $Data
    }
}

$DomainSID = Get-ADDomain | Select -expand DomainSID |Select -expand Value
$RootDomainSID = Get-ADDomain (Get-ADForest | Select -ExpandProperty RootDomain) | Select -expand DomainSID |Select -expand Value
$CriticalGroups = @("S-1-5-32-548","S-1-5-32-544","S-1-5-32-551","S-1-5-32-569","$DomainSID-517","$DomainSID-512","$RootDomainSID-519","$DomainSID-527","$DomainSID-526","S-1-5-32-550","S-1-5-32-552","$DomainSID-518","S-1-5-32-549")

$InactiveAccountDate = (Get-Date).AddDays($($InactiveAccountInDay*-1))
$UnusedAccountDate = (Get-Date).AddDays($($UnusedAccountInDay*-1))
$OutdatedPasswordDate = (Get-Date).AddDays($($OutdatedPasswordInDay*-1))

$User = Get-ADUser -Filter * -Properties *
$Computer = Get-ADComputer -Filter * -Properties *
$Admin = $User | ? Admincount -ge 1
$LegacySA = $User | ? {$_.Name -like "sa-*" -or $_.ServicePrincipalNames -ne $null}
$gMSA = Get-ADServiceAccount -Filter *
$CriticalGroupMember = $CriticalGroups | %{
    
    $CriticalGroupName = (Get-ADGroup $_ | Select -ExpandProperty SamAccountName)
    Get-ADGroupMember $_ -Recursive | %{
        [pscustomobject]@{
            Groupname = $CriticalGroupName
            SamAccountName = $_.SamAccountName
            DistinguishedName = $_.DistinguishedName
        }
    }
}

$Output = @()

Write-Host "Empty Password:"
$Output += New-AdAccountCheckItem -Name "Empty Password" -Data  $($User | ? Enabled -eq $true | ? PasswordLastSet -eq $null | Select SamAccountName, DistinguishedName)

Write-Host "Password Not Requried:"
$Output += New-AdAccountCheckItem -Name "Password Not Requried" -Data  $($User | ? PasswordNotRequired -eq $true  | ? Enabled -eq $true  | Select SamAccountName, DistinguishedName)

Write-Host "Password Never Expires"
$Output += New-AdAccountCheckItem -Name "Password Never Expires" -Data  $($User | ? Enabled -eq $true | ? PasswordNeverExpires -eq $true  | Select SamAccountName, DistinguishedName)

Write-Host "Outdated Password"
$Output += New-AdAccountCheckItem -Name "Outdated Password" -Data  $($LegacySA + $Admin | ? Enabled -EQ $true | ? PasswordLastSet -le $OutdatedPasswordDate | Select SamAccountName, PasswordLastSet, DistinguishedName)

Write-Host "Inactive User"
$Output += New-AdAccountCheckItem -Name "Inative User" -Data  $($User | ? Enabled -eq $true | ? isCriticalSystemObject -ne $true | ? LastLogonDate -le $InactiveDate | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Unused User"
$Output += New-AdAccountCheckItem -Name "Unused User" -Data  $($User | ? Enabled -eq $false | ? isCriticalSystemObject -ne $true | ? LastLogonDate -le $UnusedAccountDate | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Inactive Computer"
$Output += New-AdAccountCheckItem -Name "Inactive Computer" -Data  $($Computer | ? Enabled -eq $true | ? isCriticalSystemObject -ne $true | ? LastLogonDate -le $InactiveDate | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Unused Computer"
$Output += New-AdAccountCheckItem -Name "Unused Computer" -Data  $($Computer  | ? Enabled -eq $false | ? isCriticalSystemObject -ne $true | ? LastLogonDate -le $UnusedAccountDate | Select SamAccountName, LastLogonDate, DistinguishedName)

Write-Host "Suspicious Admin"
$Output += New-AdAccountCheckItem -Name "Suspicious Admin" -Data  $($Admin | ? {$CriticalGroupMember.SamAccountName -notcontains $_.SamAccountName} | Select SamAccountName, DistinguishedName)

Write-Host "High Privileged  service accounts"
$Output += New-AdAccountCheckItem -Name "High Privileged  service accounts" -Data  $($CriticalGroupMember | ? {($LegacySA + $gMSA).SamAccountName -notcontains $_.SamAccountName} | Select SamAccountName, Groupname, DistinguishedName)

Write-Host "High Privileged  user accounts"
$Output += New-AdAccountCheckItem -Name "High Privileged  user accounts" -Data  $($CriticalGroupMember | ? {($LegacySA + $gMSA).SamAccountName -notcontains $_.SamAccountName} | Select SamAccountName, Groupname, DistinguishedName)

$Output | %{
        $_.Data | Out-GridView -Title $_.Name
    }