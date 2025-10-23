# Complete Local Development Startup Script
# This script starts PostgreSQL databases via Docker, then starts all backend services

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Development Environment Startup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "c:\genaiexperiments\accountopening"
cd $projectRoot

# Check if Docker is running
Write-Host "Step 1: Checking Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

Write-Host ""
Write-Host "Step 2: Starting PostgreSQL databases..." -ForegroundColor Yellow
Write-Host "Running: docker-compose up -d" -ForegroundColor Gray
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL containers started!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start Docker containers!" -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

Write-Host ""
Write-Host "Step 3: Waiting for databases to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check database health
Write-Host "Checking database health..." -ForegroundColor Gray
$healthy = $true
$dbs = @("customer-db", "document-db", "account-db", "notification-db")

foreach ($db in $dbs) {
    $health = docker inspect --format='{{.State.Health.Status}}' $db 2>$null
    if ($health -eq "healthy" -or $health -eq "") {
        Write-Host "  ✅ $db is ready" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $db status: $health" -ForegroundColor Yellow
        $healthy = $false
    }
}

if (-not $healthy) {
    Write-Host ""
    Write-Host "⚠️  Some databases are still starting up..." -ForegroundColor Yellow
    Write-Host "Waiting 15 more seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds 15
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 4: Building backend services..." -ForegroundColor Yellow
Write-Host ""

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
Write-Host "Step 5: Starting microservices..." -ForegroundColor Yellow
Write-Host ""

$services = @("customer-service", "document-service", "account-service", "notification-service")

foreach ($service in $services) {
    Write-Host "Starting $service..." -ForegroundColor Gray
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $projectRoot\$service; Write-Host 'Starting $service...' -ForegroundColor Cyan; mvn spring-boot:run"
    Start-Sleep -Seconds 3
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Environment is starting up!" -ForegroundColor Green
Write-Host ""
Write-Host "Docker PostgreSQL Databases:" -ForegroundColor Yellow
Write-Host "  - customer-db     → localhost:5432" -ForegroundColor White
Write-Host "  - document-db     → localhost:5433" -ForegroundColor White
Write-Host "  - account-db      → localhost:5434" -ForegroundColor White
Write-Host "  - notification-db → localhost:5435" -ForegroundColor White
Write-Host "  - pgAdmin         → http://localhost:5050" -ForegroundColor Cyan
Write-Host "    (Login: admin@accountopening.com / admin)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Microservices (starting in separate windows):" -ForegroundColor Yellow
Write-Host "  - Customer Service     → localhost:8081" -ForegroundColor White
Write-Host "  - Document Service     → localhost:8082" -ForegroundColor White
Write-Host "  - Account Service      → localhost:8083" -ForegroundColor White
Write-Host "  - Notification Service → localhost:8084" -ForegroundColor White
Write-Host ""
Write-Host "Wait for each service to show:" -ForegroundColor Yellow
Write-Host "  'Started [ServiceName]Application in X seconds'" -ForegroundColor White
Write-Host ""
Write-Host "Then start the frontend:" -ForegroundColor Yellow
Write-Host "  cd frontend\account-opening-ui" -ForegroundColor White
Write-Host "  npm start" -ForegroundColor White
Write-Host ""
Write-Host "To stop everything:" -ForegroundColor Yellow
Write-Host "  1. Close all service windows (Ctrl+C)" -ForegroundColor White
Write-Host "  2. Run: docker-compose down" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to close this window..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
