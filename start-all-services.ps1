# Backend Build and Start Script
# Run this to rebuild and start all backend services

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend Services Build & Start Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$services = @("customer-service", "document-service", "account-service", "notification-service")
$projectRoot = "c:\genaiexperiments\accountopening"

# Check if PostgreSQL is running
Write-Host "Checking PostgreSQL..." -ForegroundColor Yellow
$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue

if ($null -eq $pgService) {
    Write-Host "⚠️  PostgreSQL not found!" -ForegroundColor Yellow
    Write-Host "Please install PostgreSQL: https://www.postgresql.org/download/windows/" -ForegroundColor White
    Write-Host "Or run: .\setup-databases.ps1 after installing" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to continue anyway..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
} elseif ($pgService.Status -ne "Running") {
    Write-Host "⚠️  PostgreSQL is not running! Starting..." -ForegroundColor Yellow
    try {
        Start-Service $pgService.Name
        Write-Host "✅ PostgreSQL started" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to start PostgreSQL" -ForegroundColor Red
    }
} else {
    Write-Host "✅ PostgreSQL is running" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 1: Building all services..." -ForegroundColor Yellow
Write-Host ""

cd $projectRoot

Write-Host "Running: mvn clean compile -DskipTests" -ForegroundColor Gray
mvn clean compile -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed! Check errors above." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 2: Starting services in separate windows..." -ForegroundColor Yellow
Write-Host ""

# Start each service in a new window
foreach ($service in $services) {
    Write-Host "Starting $service..." -ForegroundColor Gray
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $projectRoot\$service; Write-Host 'Starting $service...' -ForegroundColor Cyan; mvn spring-boot:run"
    Start-Sleep -Seconds 3
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ All services are starting!" -ForegroundColor Green
Write-Host ""
Write-Host "4 PowerShell windows have been opened:" -ForegroundColor Yellow
Write-Host "  - Customer Service (port 8081)" -ForegroundColor White
Write-Host "  - Document Service (port 8082)" -ForegroundColor White
Write-Host "  - Account Service (port 8083)" -ForegroundColor White
Write-Host "  - Notification Service (port 8084)" -ForegroundColor White
Write-Host ""
Write-Host "Wait for each service to show:" -ForegroundColor Yellow
Write-Host "  'Started [ServiceName]Application in X seconds'" -ForegroundColor White
Write-Host ""
Write-Host "Then test at: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to close this window..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
