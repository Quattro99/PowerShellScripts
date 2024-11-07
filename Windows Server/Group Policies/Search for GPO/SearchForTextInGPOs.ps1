<#
.SYNOPSIS
   This script checks for Group Policies (GPOs) in the domain that contain specific settings.
.DESCRIPTION
   The script retrieves a list of GPOs from the Active Directory domain and checks each GPO's report for the presence of a string.
.INPUTS
   None. This script does not require any input parameters.
.OUTPUTS
   Displays the names and statuses of GPOs that match the search criteria in the console.
.NOTES
   ===========================================================================
   Created on:   		07.11.2024
   Created by:   		Michele Blum
   Filename:     		SearchForTextInGPOs.ps1
   ===========================================================================
.COMPONENT
   Active Directory
.ROLE
   System Administration
.FUNCTIONALITY
   Checks for specific GPO settings in the domain.
#>

# Set the string to search for in the GPOs
$String = "ENTER A STRING TO SEARCH FOR"

# Get the user's domain and the nearest domain controller
$Domain = $env:USERDNSDOMAIN
$NearestDC = (Get-ADDomainController -Discover -NextClosestSite).Name

# Logging configuration
$logFilePath = "C:\Temp\SearchForTextInGPOs.txt"

# Start logging the output to the log file
Start-Transcript -Path $logFilePath -Append
Write-Host "Starting GPO check for '$String'..." -ForegroundColor Green

# Get a list of all GPOs from the domain
$GPOs = Get-GPO -All -Domain $Domain -Server $NearestDC | Sort DisplayName

# Iterate through each GPO and check its XML report for the specified string
foreach ($GPO in $GPOs) {
    Write-Host "Working on GPO: $($GPO.DisplayName)" -ForegroundColor Yellow
    
    # Get the current GPO report in XML format
    $CurrentGPOReport = Get-GPOReport -Guid $GPO.Id -ReportType Xml -Domain $Domain -Server $NearestDC

    # Check if the report contains the specified string
    if ($CurrentGPOReport -match [regex]::Escape($String)) {
        Write-Host "A Group Policy matching ""$($String)"" has been found:" -ForegroundColor Green
        Write-Host "-  GPO Name: $($GPO.DisplayName)" -ForegroundColor Green
        Write-Host "-  GPO Id: $($GPO.Id)" -ForegroundColor Green
        Write-Host "-  GPO Status: $($GPO.GpoStatus)" -ForegroundColor Green
    }
} 

# Log completion message
Write-Host "GPO check completed." -ForegroundColor Green

# End the transcript to capture all output
Stop-Transcript