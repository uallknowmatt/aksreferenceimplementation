# ============================================
# Stop Development Infrastructure
# ============================================
# This script stops your AKS cluster and PostgreSQL database
# Cost when stopped: ~$1/month (storage only)
# Saves: ~$48/month!

Write-Host "🛑 Stopping Development Infrastructure..." -ForegroundColor Yellow
Write-Host ""

$resourceGroup = "rg-account-opening-dev-eus2"
$aksName = "aks-account-opening-dev-eus2"
$pgName = "psql-account-opening-dev-eus2"

# Check if already stopped
Write-Host "📊 Checking current status..." -ForegroundColor Cyan
$aksState = az aks show -g $resourceGroup -n $aksName --query "powerState.code" -o tsv 2>$null
$pgState = az postgres flexible-server show -g $resourceGroup -n $pgName --query "state" -o tsv 2>$null

if ($aksState -eq "Stopped" -and $pgState -eq "Stopped") {
    Write-Host "✅ Infrastructure is already stopped!" -ForegroundColor Green
    Write-Host ""
    Write-Host "💰 Current cost: ~`$1/month (storage only)" -ForegroundColor Green
    exit 0
}

# Stop AKS cluster
Write-Host ""
Write-Host "☸️  Stopping AKS cluster..." -ForegroundColor Cyan
Write-Host "   This takes about 1-2 minutes..."
if ($aksState -ne "Stopped") {
    az aks stop -g $resourceGroup -n $aksName --no-wait
}

# Stop PostgreSQL database
Write-Host ""
Write-Host "🗄️  Stopping PostgreSQL database..." -ForegroundColor Cyan
Write-Host "   This takes about 1-2 minutes..."
if ($pgState -ne "Stopped") {
    az postgres flexible-server stop -g $resourceGroup -n $pgName --no-wait
}

# Wait for both to stop
Write-Host ""
Write-Host "⏳ Waiting for services to stop..." -ForegroundColor Yellow

$maxWait = 300  # 5 minutes max
$elapsed = 0
$interval = 10

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval
    
    $aksState = az aks show -g $resourceGroup -n $aksName --query "powerState.code" -o tsv 2>$null
    $pgState = az postgres flexible-server show -g $resourceGroup -n $pgName --query "state" -o tsv 2>$null
    
    Write-Host "   [$elapsed s] AKS: $aksState | PostgreSQL: $pgState" -ForegroundColor Gray
    
    if ($aksState -eq "Stopped" -and $pgState -eq "Stopped") {
        break
    }
}

if ($aksState -eq "Stopped" -and $pgState -eq "Stopped") {
    Write-Host ""
    Write-Host "✅ Infrastructure stopped successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Status:" -ForegroundColor Cyan
    Write-Host "   ☸️  AKS Cluster: Stopped" -ForegroundColor Gray
    Write-Host "   🗄️  PostgreSQL: Stopped" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💰 Cost Savings:" -ForegroundColor Green
    Write-Host "   • While stopped: ~`$1/month (storage only)" -ForegroundColor White
    Write-Host "   • Savings: ~`$48/month! 💚" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨ Benefits:" -ForegroundColor Cyan
    Write-Host "   ✅ All data is preserved" -ForegroundColor White
    Write-Host "   ✅ Kubernetes configs retained" -ForegroundColor White
    Write-Host "   ✅ Database data safe" -ForegroundColor White
    Write-Host "   ✅ Container images in ACR remain" -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 To start again, run:" -ForegroundColor Yellow
    Write-Host "   ./start-infra.ps1" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠️  Shutdown is taking longer than expected..." -ForegroundColor Yellow
    Write-Host "   Check status with:" -ForegroundColor White
    Write-Host "   az aks show -g $resourceGroup -n $aksName --query powerState" -ForegroundColor Gray
    Write-Host "   az postgres flexible-server show -g $resourceGroup -n $pgName --query state" -ForegroundColor Gray
}
