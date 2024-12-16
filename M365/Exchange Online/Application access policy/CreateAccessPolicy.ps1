<#
.SYNOPSIS
   This script restricts the access to an Azure Enterprise Application for a specific set of mailboxes by an application that uses APIs (Outlook REST, Microsoft Graph, or Exchange Web Services (EWS)). 
.DESCRIPTION
   To restrict access to the Azure Application, you have to define an Application Access Policy. Also, you have to define a policy because of the API permission Mail.Read or Mail.ReadWrite that are scope-based. 
.INPUTS
   - https://medium.com/medialesson/how-to-send-emails-in-net-with-the-microsoft-graph-a97b57430bbd
   - https://learn.microsoft.com/en-us/powershell/module/exchange/new-applicationaccesspolicy?view=exchange-ps#-policyscopegroupid
.OUTPUTS
   Access restriction to Azure Enterpise Application
.NOTES
   ===========================================================================
	 Created on:   	23.06.2023
	 Created by:   	Michele Blum
	 Filename:     	CreateAccessPolicy.ps1
	===========================================================================
.COMPONENT
   Exchange Online Management Module 
.ROLE
   Security
.FUNCTIONALITY
   Use the New-ApplicationAccessPolicy cmdlet to restrict or deny access to a specific set of mailboxes by an application that uses APIs (Outlook REST, Microsoft Graph, or Exchange Web Services (EWS)). These policies are complementary to the permission scopes that are declared by the application.
#>

## Install Module
Install-Module -Name ExchangeOnlineManagement

## Import Module
Import-Module ExchangeOnlineManagement

## Set execution policy
Set-ExecutionPolicy RemoteSigned

## Set variables
$adm = "upn of an Exchange Online Admin"
$appid = "App ID from the enterpise application that the access has to be resticted"
$groupid = "Group that should have access to the enterpise application"
$testmail = "E-mail address to test the access to the enterprise application"

## Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName $adm

## Get Application Access Policies
Get-ApplicationAccessPolicy | Format-List

## Add an Application Policy
New-ApplicationAccessPolicy -AppId $appid -PolicyScopeGroupId $groupid -AccessRight RestrictAccess -Description "Restrict this app to mail only via xyz"

## Get Application Access Policies
Get-ApplicationAccessPolicy | Format-List

## Test the Application Access Policie
Test-ApplicationAccessPolicy -Identity $testmail -AppId $appid