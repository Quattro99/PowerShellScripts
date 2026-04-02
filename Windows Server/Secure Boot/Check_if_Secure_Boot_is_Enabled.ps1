# Initialize result object in preparation for checking Secure Boot state 

$result = [PSCustomObject]@{ 

   SecureBootEnabled = $null 

} 

  

try { 

   $result.SecureBootEnabled = Confirm-SecureBootUEFI -ErrorAction Stop 

   Write-Output "Secure Boot enabled: $($result.SecureBootEnabled)" 

} catch { 

   $result.SecureBootEnabled = $null 

   Write-Warning "Unable to determine Secure Boot status: $_" 

} 