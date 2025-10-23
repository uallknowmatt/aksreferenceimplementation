# Start port forwarding for all microservices
# This allows the React UI to connect to services running in AKS

Write-Host "🚀 Starting port forwarding for all microservices..." -ForegroundColor Cyan
Write-Host ""

# Function to start port forwarding in a new window
function Start-PortForward {
    param(
        [string]$ServiceName,
        [int]$LocalPort,
        [int]$RemotePort = 80
    )
    
    Write-Host "Starting port-forward: $ServiceName -> localhost:$LocalPort" -ForegroundColor Yellow
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
        `$host.UI.RawUI.WindowTitle = 'Port Forward: $ServiceName'
        Write-Host '==================================' -ForegroundColor Cyan
        Write-Host 'Port Forwarding: $ServiceName' -ForegroundColor Green
        Write-Host 'Local: http://localhost:$LocalPort' -ForegroundColor Yellow
        Write-Host 'Remote: $ServiceName:$RemotePort' -ForegroundColor Yellow
        Write-Host '==================================' -ForegroundColor Cyan
        Write-Host ''
        Write-Host 'Press Ctrl+C to stop port forwarding' -ForegroundColor Gray
        Write-Host ''
        kubectl port-forward svc/$ServiceName ${LocalPort}:${RemotePort}
"@
}

# Start port forwarding for each service
Start-PortForward -ServiceName "customer-service" -LocalPort 8081
Start-Sleep -Seconds 2

Start-PortForward -ServiceName "document-service" -LocalPort 8082
Start-Sleep -Seconds 2

Start-PortForward -ServiceName "account-service" -LocalPort 8083
Start-Sleep -Seconds 2

Start-PortForward -ServiceName "notification-service" -LocalPort 8084
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "✅ All port forwarding sessions started!" -ForegroundColor Green
Write-Host ""
Write-Host "Services are now accessible at:" -ForegroundColor Cyan
Write-Host "  • Customer Service:     http://localhost:8081" -ForegroundColor Yellow
Write-Host "  • Document Service:     http://localhost:8082" -ForegroundColor Yellow
Write-Host "  • Account Service:      http://localhost:8083" -ForegroundColor Yellow
Write-Host "  • Notification Service: http://localhost:8084" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Note: Account Service may not be working (database connection issue)" -ForegroundColor Red
Write-Host ""
Write-Host "Now you can start the UI:" -ForegroundColor Cyan
Write-Host "  cd frontend\account-opening-ui" -ForegroundColor White
Write-Host "  npm start" -ForegroundColor White
Write-Host ""
Write-Host "Or use the start.bat file:" -ForegroundColor Cyan
Write-Host "  cd frontend\account-opening-ui" -ForegroundColor White
Write-Host "  .\start.bat" -ForegroundColor White
Write-Host ""
Write-Host "To stop all port forwarding, close the PowerShell windows." -ForegroundColor Gray
