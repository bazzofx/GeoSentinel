#INSTALL
$ErrorActionPreference = "Stop"
Try{
$path = $env:PSModulePath.split(";")[0]
Copy-Item -Recurse ".\GeoSentinel\" $path
Write-Host "Installation completed" -ForegroundColor Green
}
Catch{write-host "[INFO] -Failed to install, please copy the Geosentinel Folder to`n$path" -foregroundColor Yellow
Write-Host "[SUCCESS] - GeoSentinel Module imported successfully" -ForegroundColor Green }
Start-Sleep -Seconds 2
Try{
Import-Module GeoSentinel
Write-Host "[SUCCESS] - Module imported completed" -ForegroundColor Gree
Write-Host "[  INFO ]    - Run GeoSentinel -help for instructions" -ForegroundColor Gree

}
Catch{
Write-Host "[INFO] - Installation completed, please import module manually run`n import-module GeoSentinel"  -foregroundColor Yellow }

