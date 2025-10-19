# Bootstrap Script - Quick Setup
# Run this ONCE to create the initial AZURE_CREDENTIALS for GitHub

Write-Host "🚀 Starting Bootstrap Process..." -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
try {
    $azVersion = az --version 2>$null
    Write-Host "✅ Azure CLI installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found. Install from: https://aka.ms/InstallAzureCLIDirect" -ForegroundColor Red
    exit 1
}

# Check Terraform
try {
    $tfVersion = terraform --version 2>$null
    Write-Host "✅ Terraform installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform not found. Install from: https://www.terraform.io/downloads" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Azure Login
Write-Host "🔐 Checking Azure login..." -ForegroundColor Yellow
$accountInfo = az account show 2>$null | ConvertFrom-Json

if (-not $accountInfo) {
    Write-Host "⚠️  Not logged in to Azure. Running 'az login'..." -ForegroundColor Yellow
    az login
    $accountInfo = az account show | ConvertFrom-Json
}

Write-Host "✅ Logged in to Azure" -ForegroundColor Green
Write-Host "   Subscription: $($accountInfo.name)" -ForegroundColor Cyan
Write-Host "   Subscription ID: $($accountInfo.id)" -ForegroundColor Cyan
Write-Host ""

# Confirm subscription
$confirmation = Read-Host "Is this the correct subscription? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "❌ Please set the correct subscription with: az account set --subscription <subscription-id>" -ForegroundColor Red
    exit 1
}

$subscriptionId = $accountInfo.id
$tenantId = $accountInfo.tenantId

Write-Host ""
Write-Host "📝 OPTION 1: Use Your Azure Login (Recommended)" -ForegroundColor Cyan
Write-Host "   - Simplest approach" -ForegroundColor Gray
Write-Host "   - Uses your current Azure CLI login" -ForegroundColor Gray
Write-Host "   - No service principal creation needed" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 OPTION 2: Create Bootstrap Service Principal" -ForegroundColor Cyan
Write-Host "   - Creates temporary service principal" -ForegroundColor Gray
Write-Host "   - Can be deleted after bootstrap" -ForegroundColor Gray
Write-Host "   - More isolated permissions" -ForegroundColor Gray
Write-Host ""

$option = Read-Host "Choose option (1 or 2)"

if ($option -eq "2") {
    # Create bootstrap service principal
    Write-Host ""
    Write-Host "🔧 Creating bootstrap service principal..." -ForegroundColor Yellow
    
    $spName = "terraform-bootstrap-sp-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        $sp = az ad sp create-for-rbac `
            --name $spName `
            --role "Contributor" `
            --scopes "/subscriptions/$subscriptionId" `
            | ConvertFrom-Json
        
        Write-Host "✅ Bootstrap service principal created" -ForegroundColor Green
        Write-Host "   App ID: $($sp.appId)" -ForegroundColor Cyan
        Write-Host ""
        
        # Set environment variables
        Write-Host "🔐 Setting environment variables for Terraform..." -ForegroundColor Yellow
        $env:ARM_CLIENT_ID = $sp.appId
        $env:ARM_CLIENT_SECRET = $sp.password
        $env:ARM_SUBSCRIPTION_ID = $subscriptionId
        $env:ARM_TENANT_ID = $tenantId
        
        Write-Host "✅ Environment variables set" -ForegroundColor Green
        Write-Host ""
        
        # Grant User Access Administrator (needed to create service principals)
        Write-Host "🔧 Granting User Access Administrator role (needed for Terraform to create service principals)..." -ForegroundColor Yellow
        az role assignment create `
            --assignee $sp.appId `
            --role "User Access Administrator" `
            --scope "/subscriptions/$subscriptionId" `
            --output none 2>$null
        
        Write-Host "✅ Additional permissions granted" -ForegroundColor Green
        Write-Host ""
        
        # Wait for propagation
        Write-Host "⏳ Waiting 30 seconds for role assignments to propagate..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
    } catch {
        Write-Host "❌ Failed to create service principal: $_" -ForegroundColor Red
        Write-Host "   Try Option 1 instead (use your Azure login)" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "✅ Using your Azure CLI login for Terraform" -ForegroundColor Green
    Write-Host "   (No bootstrap service principal needed)" -ForegroundColor Gray
    Write-Host ""
}

# Run Terraform
Write-Host "🏗️  Running Terraform to create infrastructure..." -ForegroundColor Yellow
Write-Host "   This will take 10-15 minutes. Get some coffee! ☕" -ForegroundColor Gray
Write-Host ""

cd infrastructure

# Initialize Terraform
Write-Host "   → terraform init" -ForegroundColor Gray
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform init failed" -ForegroundColor Red
    exit 1
}

# Apply Terraform
Write-Host ""
Write-Host "   → terraform apply -var-file=dev.tfvars" -ForegroundColor Gray
Write-Host ""
terraform apply -var-file=dev.tfvars -auto-approve

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform apply failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Infrastructure created successfully!" -ForegroundColor Green
Write-Host ""

# Get the GitHub Actions credentials
Write-Host "🔑 Getting GitHub Actions credentials..." -ForegroundColor Yellow
Write-Host ""

$azureCredentials = terraform output -raw azure_credentials_json

Write-Host "✅ Service principal credentials retrieved!" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📋 COPY THIS JSON TO GITHUB SECRETS" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host $azureCredentials -ForegroundColor White
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Save to file for convenience
$credentialsFile = "azure_credentials.json"
$azureCredentials | Out-File -FilePath $credentialsFile -Encoding UTF8
Write-Host "💾 Credentials also saved to: $credentialsFile" -ForegroundColor Cyan
Write-Host ""

# Instructions
Write-Host "📖 NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to: https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions" -ForegroundColor White
Write-Host "2. Click 'New repository secret'" -ForegroundColor White
Write-Host "3. Name: AZURE_CREDENTIALS" -ForegroundColor White
Write-Host "4. Value: Paste the JSON above" -ForegroundColor White
Write-Host "5. Click 'Add secret'" -ForegroundColor White
Write-Host ""
Write-Host "✨ That's it! Only 1 secret to configure!" -ForegroundColor Green
Write-Host ""

# Show summary
Write-Host "📊 Infrastructure Summary:" -ForegroundColor Yellow
terraform output github_secrets_summary

Write-Host ""

# Cleanup option
if ($option -eq "2") {
    Write-Host "🧹 CLEANUP (Optional):" -ForegroundColor Yellow
    Write-Host "   The bootstrap service principal is no longer needed." -ForegroundColor Gray
    Write-Host "   To delete it, run:" -ForegroundColor Gray
    Write-Host "   az ad sp delete --id $($sp.appId)" -ForegroundColor White
    Write-Host ""
}

Write-Host "🎉 Bootstrap complete! Check DEPLOYMENT_PREREQUISITES.md for next steps." -ForegroundColor Green
Write-Host ""
