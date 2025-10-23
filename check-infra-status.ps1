# ============================================
# Check Infrastructure Status
# ============================================
# This script shows current status and estimated costs

Write-Host "📊 Development Infrastructure Status" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray
Write-Host ""

$resourceGroup = "rg-account-opening-dev-eus2"
$aksName = "aks-account-opening-dev-eus2"
$pgName = "psql-account-opening-dev-eus2"

# Get status
Write-Host "🔍 Fetching current status..." -ForegroundColor Yellow
$aksState = az aks show -g $resourceGroup -n $aksName --query "powerState.code" -o tsv 2>$null
$pgState = az postgres flexible-server show -g $resourceGroup -n $pgName --query "state" -o tsv 2>$null

# Display status
Write-Host ""
Write-Host "☸️  AKS Cluster:" -ForegroundColor Cyan
if ($aksState -eq "Running") {
    Write-Host "   Status: Running ✅" -ForegroundColor Green
} elseif ($aksState -eq "Stopped") {
    Write-Host "   Status: Stopped ⏸️" -ForegroundColor Gray
} else {
    Write-Host "   Status: $aksState" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🗄️  PostgreSQL Database:" -ForegroundColor Cyan
if ($pgState -eq "Ready") {
    Write-Host "   Status: Running ✅" -ForegroundColor Green
} elseif ($pgState -eq "Stopped") {
    Write-Host "   Status: Stopped ⏸️" -ForegroundColor Gray
} else {
    Write-Host "   Status: $pgState" -ForegroundColor Yellow
}

# Calculate costs
Write-Host ""
Write-Host "💰 Current Cost Estimate:" -ForegroundColor Yellow

if ($aksState -eq "Running" -and $pgState -eq "Ready") {
    Write-Host "   State: RUNNING 🟢" -ForegroundColor Green
    Write-Host ""
    Write-Host "   • Per hour: ~`$0.068" -ForegroundColor White
    Write-Host "   • Per day: ~`$1.63" -ForegroundColor White
    Write-Host "   • Per week: ~`$11.40" -ForegroundColor White
    Write-Host "   • Per month (24/7): ~`$49" -ForegroundColor White
    Write-Host ""
    Write-Host "   💡 To save costs, stop when not in use:" -ForegroundColor Cyan
    Write-Host "      ./stop-infra.ps1" -ForegroundColor Gray
} elseif ($aksState -eq "Stopped" -and $pgState -eq "Stopped") {
    Write-Host "   State: STOPPED 🟡" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   • Per month: ~`$1 (storage only)" -ForegroundColor Green
    Write-Host "   • Savings: ~`$48/month! 💚" -ForegroundColor Green
    Write-Host ""
    Write-Host "   ✅ All data is preserved and safe" -ForegroundColor White
    Write-Host ""
    Write-Host "   🚀 To start infrastructure:" -ForegroundColor Cyan
    Write-Host "      ./start-infra.ps1" -ForegroundColor Gray
} else {
    Write-Host "   State: MIXED ⚠️" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Some services running, some stopped" -ForegroundColor White
    Write-Host "   Estimated cost: `$10-30/month" -ForegroundColor Yellow
}

# Get node count and details if running
if ($aksState -eq "Running") {
    Write-Host ""
    Write-Host "🖥️  AKS Resources:" -ForegroundColor Cyan
    
    try {
        $nodes = kubectl get nodes --no-headers 2>$null | Measure-Object
        if ($nodes.Count -gt 0) {
            Write-Host "   Nodes: $($nodes.Count)" -ForegroundColor White
            kubectl get nodes 2>$null
            
            Write-Host ""
            Write-Host "📦 Running Pods:" -ForegroundColor Cyan
            $pods = kubectl get pods -A --no-headers 2>$null | Measure-Object
            Write-Host "   Total pods: $($pods.Count)" -ForegroundColor White
        } else {
            Write-Host "   ⚠️  No nodes found. Cluster may still be starting..." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ⚠️  Cannot connect to cluster. Run:" -ForegroundColor Yellow
        Write-Host "      az aks get-credentials -g $resourceGroup -n $aksName --overwrite-existing" -ForegroundColor Gray
    }
}

# Show quick actions
Write-Host ""
Write-Host "⚡ Quick Actions:" -ForegroundColor Cyan
Write-Host "   Start: ./start-infra.ps1" -ForegroundColor Gray
Write-Host "   Stop:  ./stop-infra.ps1" -ForegroundColor Gray
Write-Host "   Check: ./check-infra-status.ps1" -ForegroundColor Gray

Write-Host ""
