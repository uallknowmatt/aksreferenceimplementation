# Service Health Check Script
# Run this AFTER starting all backend services to verify they're working

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend Services Health Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$services = @(
    @{Name="Customer Service"; Port=8081; Url="http://localhost:8081/api/customers"},
    @{Name="Document Service"; Port=8082; Url="http://localhost:8082/api/documents"},
    @{Name="Account Service"; Port=8083; Url="http://localhost:8083/api/accounts"},
    @{Name="Notification Service"; Port=8084; Url="http://localhost:8084/api/notifications"}
)

Write-Host "Checking if services are running..." -ForegroundColor Yellow
Write-Host ""

$allGood = $true

foreach ($service in $services) {
    Write-Host "Testing $($service.Name) on port $($service.Port)..." -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri $service.Url -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  ✅ $($service.Name) is UP and responding" -ForegroundColor Green
        Write-Host "     Response: $(($response | ConvertTo-Json -Compress).Substring(0, [Math]::Min(100, ($response | ConvertTo-Json -Compress).Length)))" -ForegroundColor DarkGray
    }
    catch {
        $allGood = $false
        if ($_.Exception.Message -like "*Unable to connect*" -or $_.Exception.Message -like "*refused*") {
            Write-Host "  ❌ $($service.Name) is NOT running on port $($service.Port)" -ForegroundColor Red
            Write-Host "     Make sure the service is started" -ForegroundColor Yellow
        }
        elseif ($_.Exception.Response.StatusCode.value__ -eq 404) {
            Write-Host "  ⚠️  $($service.Name) is running but endpoint returned 404" -ForegroundColor Yellow
            Write-Host "     This might be normal if the endpoint doesn't exist yet" -ForegroundColor DarkGray
        }
        else {
            Write-Host "  ❌ $($service.Name) returned an error" -ForegroundColor Red
            Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor DarkRed
        }
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✅ ALL SERVICES ARE WORKING!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now test the UI at:" -ForegroundColor Yellow
    Write-Host "  http://localhost:3000" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Some services are not responding" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Make sure all services are started:" -ForegroundColor Yellow
    Write-Host "  1. Run: .\start-all-services.ps1" -ForegroundColor White
    Write-Host "  2. Wait for 'Started...Application' in each window" -ForegroundColor White
    Write-Host "  3. Run this script again" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
