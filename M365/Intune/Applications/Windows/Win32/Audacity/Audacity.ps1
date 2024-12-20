﻿####################################################################
###                                                              ###
###    This script is for app Installtion/uninstallation only    ###  
###                                                              ###
####################################################################

#Scenarios: App Installation, App Uninstall
#
#Keep scripting clean with error handling
#
# Error Codes: 0 = success, 1 = error/failure
#
#
# MSI install example:
# msiexec /i "applikation.msi" /qn /parameter
#
#
# EXE install example: 
#
# $application = "app.exe"
# $argument = '/quiet /parameter2'
#
# $Result = Start-Process $Application -Wait -PassThru -ArgumentList $Argument
# $ExitCode = $Result.ExitCode
#
#
#------- Parameters and preferences -----------

[CmdletBinding()]
Param (
   [Parameter(Mandatory=$false)]
   [Switch]$Remove
)
#Action preferences
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#--------Logging Configuration--------#
if($PSCommandPath){
    $LogName = (split-path $PSCommandPath -Leaf) -replace ".ps1",""
}
else{
    $LogName = "Current"
}

$LogFullname = "{0}\{1}\{2}-{3}.log" -f $env:ProgramData, "Microsoft\IntuneManagementExtension\Logs", $LogName ,$(get-Date -f "yyyyMMdd-HHmmss")


#Start logging
Start-Transcript -Path $LogFullname
#-------- Install / Uninstall --------------
Try {
# -remove  = uninstall , This workflow is triggered by the uninstallation command in intune
If ($Remove){

            ##### Add processname ############
            Write-Verbose "Stop Application"
            Get-Process "ProcessName" -ErrorAction Ignore | Stop-Process

            Write-Verbose "Remove Application"
            $Application = "%ProgramFiles%\Audacity\unins000.exe"
            $Argument = '/VERYSILENT /NORESTART'

            $Result = Start-Process $Application -Wait -PassThru -ArgumentList $Argument
            $ExitCode = $Result.ExitCode
            Write-Verbose "Installation successfull. ExitCode: $ExitCode"
 
    }
#This workflow is triggered by the installation command in intune
Else{
             
             $Application = "audacity-win-3.4.2-64bit.exe"
             $Argument = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'

             $Result = Start-Process $Application -Wait -PassThru -ArgumentList $Argument
             $ExitCode = $Result.ExitCode
             Write-Verbose "Installation successfull. ExitCode: $ExitCode"
			 Copy-Item -Path ".\audacity.cfg" -Destination "%appdata%\audacity" -Recurse
            
  }
}
Catch{
    #catch Error 
    Write-Verbose "Catch Error installing or uninstalling. Exit with Exitcode: 1"
    $Exitcode = 1
}
#-------- Exit App----------
if($ExitCode -eq $null -or $ExitCode -eq "1"){
    Write-Error "Exit with Exitcode $Exitcode"
    #stop logging
    Stop-Transcript
    Exit 1
}
else{
    Write-Output "Exit with Exitcode $Exitcode"
    #stop logging
    Stop-Transcript
    Exit $ExitCode
}