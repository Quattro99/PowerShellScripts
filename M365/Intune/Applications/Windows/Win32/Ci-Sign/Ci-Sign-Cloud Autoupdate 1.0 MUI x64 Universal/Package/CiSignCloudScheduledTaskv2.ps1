####################################################################
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
Param(
    #Remove App
    [Parameter()]
    [switch]$Remove,

    [Parameter()]
    [string]$Path,

	
    #Write version file with this version, can be used for version detection
    [version]$Version
)

#Action preferences
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#variablen nullen
$ScheduledTaskName = $null
$ScheduledTaskFolder = $null
$ScheduledTaskDescripton = $null
$ScheduledTaskPrincipal = $null
$tagfolder = $null
$checkfolder = $null
$CheckTasks = $null

#variables
$ScheduledTaskName = "CI-Sign Cloud Autoupdate v2"
$ScheduledTaskFolder = "\Achermann\"
$ScheduledTaskDescripton = "Update Outlook signature"
$ScheduledTaskPrincipal = "$env:userdomain" + "\" + "$env:USERNAME"
$tagfolder = Join-Path $env:LOCALAPPDATA "Achermann ict-services\$ScheduledTaskName\"

$InstallPath = Join-Path $env:LOCALAPPDATA "Achermann ict-services\$ScheduledTaskName"
$ScheduledTaskFolder = "\{0}\" -f $ScheduledTaskFolder.Trim("\") 

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

#functions
Function Enable-ScheduledTaskHistory{

    Try{
        Write-Verbose "Enable Scheduled Task history"
        $LogName = 'Microsoft-Windows-TaskScheduler/Operational'
        $LogConfiguration = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $LogName
        $LogConfiguration.IsEnabled = $true
        $LogConfiguration.SaveChanges()
    }
    catch{
        Write-Error $_.Exception.Message
    }

}


#-------- Install / Uninstall --------------
Try {
# -remove  = uninstall , This workflow is triggered by the uninstallation command in intune
If ($Remove){

        Write-Verbose "Uninstall"

            if(Get-ScheduledTask -TaskName $ScheduledTaskName -TaskPath "$ScheduledTaskFolder" -ErrorAction Ignore){
                Write-Verbose "Remove scheduled task $ScheduledTaskName"
                Stop-ScheduledTask -TaskName $ScheduledTaskName -TaskPath $ScheduledTaskFolder -ErrorAction Stop    
                Unregister-ScheduledTask -TaskName $ScheduledTaskName -TaskPath $ScheduledTaskFolder -ErrorAction Stop -Confirm:$false
            }

            if(Test-Path $tagfolder){
                Remove-Item -Path $tagfolder -Recurse -Force -ErrorAction Stop
            }
            $exitcode = 0
 
    }
#This workflow is triggered by the installation command in intune
Else{
             
    #cleanup old Tasks

    $CheckTasks = Get-ScheduledTask "*CI-sign*"
    $taskname = $CheckTasks.Taskname

    if($CheckTasks -ne $null){
     Write-Verbose "Cleaning up old tasks"
      foreach($task in $CheckTasks.taskname){
      Unregister-ScheduledTask -TaskName $task -Confirm:$false
      }  
    }
    Else {
        Write-Verbose "Nothing to be done."
    }

    #check folder or create folder
    $checkfolder = Test-Path -Path "$tagfolder"

    if($checkfolder -eq $true){
        Write-Verbose "Cleanup old tag files..."
        Remove-Item -Path "$tagfolder" -Recurse -Force -Confirm:$false
    }
    Else{
        Write-Verbose "Creating Tag folder..." 
        New-Item -Path "$env:LOCALAPPDATA\Achermann ict-services\" -Name "$ScheduledTaskName" -ItemType Directory
    }

    Write-Verbose "Install"    
  
    #region create scheduled task

    Write-Verbose "Create scheduled task $ScheduledTaskFolder$ScheduledTaskName $ScheduledTaskCommand."

    $Action = New-ScheduledTaskAction -Execute "$path"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    #Bug in cmdlet parameter validation, can't define daily repetition and interval in the same command :-S
    $Trigger =  New-ScheduledTaskTrigger -AtLogOn -User $ScheduledTaskPrincipal -ErrorAction Stop 
    Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName $ScheduledTaskName -TaskPath $ScheduledTaskFolder -Description $ScheduledTaskDescripton -ErrorAction Stop -Verbose:$false | Out-Null
    #endregion


    #region Write version if task creation was successfull
    if(Get-ScheduledTask -TaskPath $ScheduledTaskFolder -TaskName $ScheduledTaskName ){        
        Write-Verbose "Write version file $(Join-Path $InstallPath $Version.ToString())"
        New-Item -Path $tagfolder -Name $Version.ToString() -Value $Version.ToString() -Type File -Force -ErrorAction Stop
        $exitcode = 0

        Start-Sleep -Seconds 10
    }
    else{
        
        Write-Error "Scheduled Task ""$ScheduledTaskFolder$ScheduledTaskName"" not exists, tag file was not created."
        $Exitcode = 1
    }    
  
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