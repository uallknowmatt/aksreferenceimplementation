# PostgreSQL Database Setup Script for Windows
# Creates all required databases for the account opening system

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PostgreSQL Database Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Add PostgreSQL to PATH
$postgresPath = "C:\Program Files\PostgreSQL\15\bin"
if (Test-Path $postgresPath) {
    $env:PATH += ";$postgresPath"
    Write-Host "✅ PostgreSQL binaries found at: $postgresPath" -ForegroundColor Green
} else {
    Write-Host "❌ PostgreSQL not found at: $postgresPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check your PostgreSQL installation directory." -ForegroundColor Yellow
    Write-Host "Common locations:" -ForegroundColor Yellow
    Write-Host "  - C:\Program Files\PostgreSQL\15\bin" -ForegroundColor White
    Write-Host "  - C:\Program Files\PostgreSQL\14\bin" -ForegroundColor White
    Write-Host "  - C:\Program Files\PostgreSQL\16\bin" -ForegroundColor White
    Write-Host ""
    Write-Host "Or install PostgreSQL from: https://www.postgresql.org/download/windows/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

Write-Host ""
Write-Host "Checking PostgreSQL service..." -ForegroundColor Yellow

# Check if PostgreSQL service is running
$service = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Host "❌ PostgreSQL service not found!" -ForegroundColor Red
    Write-Host "Please install PostgreSQL from: https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

if ($service.Status -ne "Running") {
    Write-Host "⚠️  PostgreSQL service is not running. Attempting to start..." -ForegroundColor Yellow
    try {
        Start-Service $service.Name
        Start-Sleep -Seconds 2
        Write-Host "✅ PostgreSQL service started!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to start PostgreSQL service!" -ForegroundColor Red
        Write-Host "Please start it manually from Services." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit 1
    }
} else {
    Write-Host "✅ PostgreSQL service is running" -ForegroundColor Green
}

Write-Host ""
Write-Host "Testing PostgreSQL connection..." -ForegroundColor Yellow

# Test connection
$testConnection = psql -U postgres -c "SELECT version();" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cannot connect to PostgreSQL!" -ForegroundColor Red
    Write-Host ""
    Write-Host "This might be due to:" -ForegroundColor Yellow
    Write-Host "  1. Incorrect password" -ForegroundColor White
    Write-Host "  2. PostgreSQL not configured properly" -ForegroundColor White
    Write-Host ""
    Write-Host "Please verify:" -ForegroundColor Yellow
    Write-Host "  - Username: postgres" -ForegroundColor White
    Write-Host "  - Password: (check what you set during installation)" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

Write-Host "✅ Successfully connected to PostgreSQL" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creating Databases..." -ForegroundColor Yellow
Write-Host ""

$databases = @("customerdb", "documentdb", "accountdb", "notificationdb")

foreach ($db in $databases) {
    Write-Host "Creating $db..." -ForegroundColor Gray
    
    # Check if database exists
    $exists = psql -U postgres -t -c "SELECT 1 FROM pg_database WHERE datname='$db';" 2>&1
    
    if ($exists -match "1") {
        Write-Host "  ⚠️  $db already exists (skipping)" -ForegroundColor Yellow
    } else {
        # Create database
        psql -U postgres -c "CREATE DATABASE $db;" 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ $db created successfully" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Failed to create $db" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verifying Databases..." -ForegroundColor Yellow
Write-Host ""

$allDbsQuery = psql -U postgres -c "\l" 2>&1

foreach ($db in $databases) {
    if ($allDbsQuery -match $db) {
        Write-Host "  ✅ $db exists" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $db NOT found!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Database Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Databases created:" -ForegroundColor Yellow
Write-Host "  - customerdb     (Customer Service)" -ForegroundColor White
Write-Host "  - documentdb     (Document Service)" -ForegroundColor White
Write-Host "  - accountdb      (Account Service)" -ForegroundColor White
Write-Host "  - notificationdb (Notification Service)" -ForegroundColor White
Write-Host ""
Write-Host "Connection details:" -ForegroundColor Yellow
Write-Host "  Host: localhost" -ForegroundColor White
Write-Host "  Port: 5432" -ForegroundColor White
Write-Host "  Username: postgres" -ForegroundColor White
Write-Host "  Password: (your PostgreSQL password)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Start backend services: .\start-all-services.ps1" -ForegroundColor White
Write-Host "  2. Wait for all services to start" -ForegroundColor White
Write-Host "  3. Start frontend: cd frontend\account-opening-ui; npm start" -ForegroundColor White
Write-Host "  4. Test at: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "To manage databases visually, use pgAdmin 4 (included with PostgreSQL)" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
