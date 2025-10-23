# ============================================
# Start Development Infrastructure
# ============================================
# This script starts your AKS cluster and PostgreSQL database
# Estimated startup time: ~5 minutes
# Cost while running: ~$0.068/hour

Write-Host "🚀 Starting Development Infrastructure..." -ForegroundColor Green
Write-Host ""

$resourceGroup = "rg-account-opening-dev-eus2"
$aksName = "aks-account-opening-dev-eus2"
$pgName = "psql-account-opening-dev-eus2"

# Check if already running
Write-Host "📊 Checking current status..." -ForegroundColor Cyan
$aksState = az aks show -g $resourceGroup -n $aksName --query "powerState.code" -o tsv 2>$null
$pgState = az postgres flexible-server show -g $resourceGroup -n $pgName --query "state" -o tsv 2>$null

if ($aksState -eq "Running" -and $pgState -eq "Ready") {
    Write-Host "✅ Infrastructure is already running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "💰 Current cost: ~`$0.068/hour = ~`$1.63/day" -ForegroundColor Yellow
    exit 0
}

# Start PostgreSQL first (faster startup)
Write-Host ""
Write-Host "🗄️  Starting PostgreSQL database..." -ForegroundColor Cyan
Write-Host "   This takes about 2 minutes..."
if ($pgState -ne "Ready") {
    az postgres flexible-server start -g $resourceGroup -n $pgName --no-wait
}

# Start AKS cluster
Write-Host ""
Write-Host "☸️  Starting AKS cluster..." -ForegroundColor Cyan
Write-Host "   This takes about 3-5 minutes..."
if ($aksState -ne "Running") {
    az aks start -g $resourceGroup -n $aksName --no-wait
}

# Wait for both to be ready
Write-Host ""
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Yellow

$maxWait = 600  # 10 minutes max
$elapsed = 0
$interval = 15

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval
    
    $aksState = az aks show -g $resourceGroup -n $aksName --query "powerState.code" -o tsv 2>$null
    $pgState = az postgres flexible-server show -g $resourceGroup -n $pgName --query "state" -o tsv 2>$null
    
    Write-Host "   [$elapsed s] AKS: $aksState | PostgreSQL: $pgState" -ForegroundColor Gray
    
    if ($aksState -eq "Running" -and $pgState -eq "Ready") {
        break
    }
}

if ($aksState -eq "Running" -and $pgState -eq "Ready") {
    Write-Host ""
    Write-Host "✅ Infrastructure started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Status:" -ForegroundColor Cyan
    Write-Host "   ☸️  AKS Cluster: Running" -ForegroundColor Green
    Write-Host "   🗄️  PostgreSQL: Ready" -ForegroundColor Green
    Write-Host ""
    Write-Host "💰 Costs:" -ForegroundColor Yellow
    Write-Host "   • Per hour: ~`$0.068" -ForegroundColor White
    Write-Host "   • Per day (24h): ~`$1.63" -ForegroundColor White
    Write-Host "   • Per month (24/7): ~`$49" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Remember to stop when done to save costs!" -ForegroundColor Yellow
    Write-Host "   Run: ./stop-infra.ps1" -ForegroundColor Cyan
    Write-Host ""
    
    # Get AKS credentials
    Write-Host "🔑 Updating kubectl credentials..." -ForegroundColor Cyan
    az aks get-credentials -g $resourceGroup -n $aksName --overwrite-existing
    
    Write-Host ""
    Write-Host "✅ Ready to deploy! Run:" -ForegroundColor Green
    Write-Host "   kubectl get nodes" -ForegroundColor White
    Write-Host "   kubectl get pods -A" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "⚠️  Startup is taking longer than expected..." -ForegroundColor Yellow
    Write-Host "   Check status with:" -ForegroundColor White
    Write-Host "   az aks show -g $resourceGroup -n $aksName --query powerState" -ForegroundColor Gray
    Write-Host "   az postgres flexible-server show -g $resourceGroup -n $pgName --query state" -ForegroundColor Gray
}
