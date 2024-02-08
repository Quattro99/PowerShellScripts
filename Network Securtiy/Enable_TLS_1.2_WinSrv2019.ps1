<#
.Synopsis
   This script enables TLS 1.2 protocol on a Windows Server.
.DESCRIPTION
   The script modifies registry settings to activate TLS 1.2 protocol in .NET Framework, WinHttp Settings, and SCHANNEL.
.INPUTS
   None. You do not need to provide any input when running this script.
.OUTPUTS
   None. This script does not output any data.
.NOTES
   ===========================================================================
	 Created on:   	08.02.2024
	 Created by:   	Michele Blum
	 Filename:     	Enable_TLS_1.2_WinSrv2019.ps1
	===========================================================================
    The script references two external URLs for additional information and context on the recommended settings:
    - https://thesecmaster.com/how-to-enable-tls-1-2-and-tls-1-3-on-windows-server/
    - https://thesecmaster.com/how-to-enable-tls-1-2-and-tls-1-3-on-windows-server/
.COMPONENT
    Windows Server
.ROLE
    System Administrator
.FUNCTIONALITY
    Network Security
#>


## Activate TLS 1.2 protocol in .net Framework
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type Dword
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type Dword

## Activate TLS 1.2 protocol for WinHttp Settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" /V "DefaultSecureProtocols" /T REG_DWORD /D 2048 /F
New-Item 'HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -Force
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" /V "DefaultSecureProtocols" /T REG_DWORD /D 2048 /F

## Create hive SCHANNEL TLS 1.2 for Client & Server
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2' -Force
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force

## Activate SCHANNEL TLS 1.2 protocol
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' –PropertyType 'DWORD' -Name 'DisabledByDefault' -Value '0'
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -PropertyType 'DWORD' -Name 'Enabled' -Value '1'
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' –PropertyType 'DWORD' -Name 'DisabledByDefault' -Value '0'
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' –PropertyType 'DWORD' -Name 'Enabled' -Value '1'