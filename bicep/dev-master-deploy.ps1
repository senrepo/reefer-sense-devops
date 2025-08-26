# dev-master-deploy.ps1
# Runs all module deployments for DEV environment
# Uses $PSScriptRoot to handle relative paths safely

Write-Host "=== Starting DEV Deployment ===" -ForegroundColor Cyan

# --- Network ---
Write-Host "=== Starting Network deployment ===" -ForegroundColor Yellow
& "$PSScriptRoot\network\dev-deploy.ps1"

# --- Service Bus ---
Write-Host "=== Starting Service Bus deployment ===" -ForegroundColor Yellow
& "$PSScriptRoot\service-bus\dev-deploy.ps1"

Write-Host "=== DEV Deployment Completed Successfully ===" -ForegroundColor Green
