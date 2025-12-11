# Windows Defender Exclusion Setup
# Run these commands in PowerShell as Administrator

# Add Flutter project build directories to exclusions
Add-MpPreference -ExclusionPath "e:\Flutter\smart_attend\build"
Add-MpPreference -ExclusionPath "e:\Flutter\smart_attend\.dart_tool"
Add-MpPreference -ExclusionPath "e:\Flutter\smart_attend\android\build"

# Add Gradle cache directory
Add-MpPreference -ExclusionPath "C:\Users\sumuk\.gradle"

# Add Pub cache directory
Add-MpPreference -ExclusionPath "C:\Users\sumuk\.pub-cache"

# Verify exclusions were added
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

Write-Host "Antivirus exclusions added successfully!" -ForegroundColor Green
Write-Host "This should significantly improve Flutter build times." -ForegroundColor Green
