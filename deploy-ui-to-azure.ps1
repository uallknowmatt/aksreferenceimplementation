# Deploy the React UI to Azure AKS
# This script builds the frontend Docker image, pushes to ACR, and deploys to AKS

param(
    [string]$ResourceGroup = "rg-account-opening-dev-eus2",
    [string]$AcrName = "acraccountopeningdeveus2",
    [string]$AksName = "aks-account-opening-dev-eus2"
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Deploying React UI to Azure AKS" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get ACR login server
Write-Host "📦 Getting ACR information..." -ForegroundColor Yellow
$acrLoginServer = az acr show --name $AcrName --resource-group $ResourceGroup --query loginServer -o tsv
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get ACR information" -ForegroundColor Red
    exit 1
}
Write-Host "✅ ACR Login Server: $acrLoginServer" -ForegroundColor Green
Write-Host ""

# Step 2: Build and push the Docker image
Write-Host "🔨 Building frontend Docker image..." -ForegroundColor Yellow
$imageTag = git rev-parse --short HEAD
$imageName = "$acrLoginServer/frontend-ui:$imageTag"

Push-Location frontend\account-opening-ui
docker build -t $imageName .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build Docker image" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✅ Docker image built successfully" -ForegroundColor Green
Write-Host ""

# Step 3: Login to ACR and push image
Write-Host "📤 Pushing image to ACR..." -ForegroundColor Yellow
az acr login --name $AcrName
docker push $imageName
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to push image to ACR" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✅ Image pushed to ACR successfully" -ForegroundColor Green
Pop-Location
Write-Host ""

# Step 4: Get AKS credentials
Write-Host "🔐 Getting AKS credentials..." -ForegroundColor Yellow
az aks get-credentials --name $AksName --resource-group $ResourceGroup --overwrite-existing
Write-Host "✅ AKS credentials updated" -ForegroundColor Green
Write-Host ""

# Step 5: Update Kubernetes manifests with image details
Write-Host "📝 Updating Kubernetes manifests..." -ForegroundColor Yellow
$deploymentContent = Get-Content k8s\frontend-ui-deployment.yaml -Raw
$deploymentContent = $deploymentContent -replace '<ACR_LOGIN_SERVER>', $acrLoginServer
$deploymentContent = $deploymentContent -replace '<TAG>', $imageTag
$deploymentContent | Set-Content k8s\frontend-ui-deployment-temp.yaml

# Step 6: Deploy to AKS
Write-Host "🚀 Deploying to AKS..." -ForegroundColor Yellow
kubectl apply -f k8s\frontend-ui-deployment-temp.yaml
kubectl apply -f k8s\frontend-ui-service.yaml

# Clean up temp file
Remove-Item k8s\frontend-ui-deployment-temp.yaml

Write-Host "✅ Deployment completed" -ForegroundColor Green
Write-Host ""

# Step 7: Wait for LoadBalancer IP
Write-Host "⏳ Waiting for LoadBalancer External IP..." -ForegroundColor Yellow
Write-Host "This may take 2-3 minutes..." -ForegroundColor Gray
Write-Host ""

$maxAttempts = 60
$attempt = 0
$externalIp = ""

while ($attempt -lt $maxAttempts -and $externalIp -eq "") {
    $attempt++
    $externalIp = kubectl get svc frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    
    if ($externalIp -eq "") {
        Write-Host "  Attempt $attempt/$maxAttempts - Still pending..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}

Write-Host ""
if ($externalIp -ne "") {
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "✅ DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🌐 Access your application at:" -ForegroundColor Yellow
    Write-Host "   http://$externalIp" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 Cost Information:" -ForegroundColor Cyan
    Write-Host "   LoadBalancer: ~`$20/month" -ForegroundColor Yellow
    Write-Host "   Total (with infrastructure): ~`$69/month running" -ForegroundColor Yellow
    Write-Host "   With start/stop: ~`$2-3/month average" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 API endpoints are proxied through the UI:" -ForegroundColor Cyan
    Write-Host "   http://$externalIp/api/customer" -ForegroundColor White
    Write-Host "   http://$externalIp/api/document" -ForegroundColor White
    Write-Host "   http://$externalIp/api/account" -ForegroundColor White
    Write-Host "   http://$externalIp/api/notification" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⚠️  LoadBalancer IP not assigned yet" -ForegroundColor Yellow
    Write-Host "Run this command to check status:" -ForegroundColor Gray
    Write-Host "   kubectl get svc frontend-ui" -ForegroundColor White
    Write-Host ""
}

Write-Host "To stop infrastructure and save costs:" -ForegroundColor Cyan
Write-Host "   .\stop-infra.ps1" -ForegroundColor White
Write-Host ""
