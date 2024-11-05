#requires -RunAsAdministrator
Param(
    [switch]$Remove
)

$VerbosePreference = "Continue"

#region log

#Determine log file path
if($PSCommandPath){
$LogName = (split-path $PSCommandPath -Leaf) -replace ".ps1",""
}
else{
$LogName = "Current"
}
$LogFullname = "{0}\{1}\{2}-{3}.log" -f $env:ProgramData, "Microsoft\IntuneManagementExtension\Logs", $LogName ,$(get-Date -f "yyyyMMdd-HHmmss")

Start-Transcript -Path $LogFullname | Out-Null
#endregion   

$MemRequestSoftReboot = 3010

if($Remove){

    Try{
        Write-Verbose "Uninstall"

        Write-Verbose "Stop wwphone Application"
        Get-Process wwphone -ErrorAction Ignore | Stop-Process -ErrorAction Stop -force

        $ProductCode = "{455B0927-47E7-49F7-8C1C-FCCB96B462E6}"
        $Application = "msiexec"
        $Argument = "/x ""$ProductCode""/qn"
        
        Write-Verbose "Execute: $Application $Argument"
        $Result = Start-Process $Application -ArgumentList $Argument -Wait -PassThru
        Write-Verbose "ExitCode: $($Result.ExitCode)"

        if($Result.ExitCode -eq 0){            
            Write-Host "Uninstall successfull"
            Stop-Transcript | Out-Null
            Exit 0
        }
        else{
        
            Write-Error "Uninstall failed with ExitCode $($Result.ExitCode)"
            Stop-Transcript | Out-Null
            Exit 1        
        }


    }
    catch{
        Write-Error $_.Exception.Message
        Stop-Transcript | Out-Null
        Exit 1
    }

}
else{

    Try{

        Write-Verbose "Install"

        $SetupPath = "$PSScriptRoot\Install\wwphone.msi"
        $Application = "msiexec"
        $Argument = "/i ""$SetupPath""/qn"
        
        Write-Verbose "Execute: $Application $Argument"
        $Result = Start-Process $Application -ArgumentList $Argument -Wait -PassThru
        Write-Verbose "ExitCode: $($Result.ExitCode)"

        if($Result.ExitCode -eq 0){

            $StartupFilePath = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\StartUp\wwphone.lnk"

            if (Test-Path $StartupFilePath) {
                Write-Verbose "Remove $StartupFilePath"
                Remove-Item $StartupFilePath
            }

            Write-Host "Install successfull"
            Stop-Transcript | Out-Null
            Exit 0
        }
        else{
        
            Write-Error "Install failed with ExitCode $($Result.ExitCode)"
            Stop-Transcript | Out-Null
            Exit 1        
        }
        
    }
    catch{
        Write-Error $_.Exception.Message
        Stop-Transcript | Out-Null
        Exit 1
    }

}