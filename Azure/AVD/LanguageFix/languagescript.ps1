# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"CHRegion.xml`""
 
# Set Timezone
& tzutil /s "W. Europe Standard Time"
 
# Set languages/culture
Set-Culture de-CH
