# Azure OIDC Setup Script (CLI-only method)
# This script creates a service principal with GitHub OIDC federation
# Run this once, then add the three IDs to GitHub secrets

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Azure OIDC Setup for GitHub Actions" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$APP_NAME = "github-actions-oidc"
$GITHUB_ORG = "uallknowmatt"
$GITHUB_REPO = "aksreferenceimplementation"
$GITHUB_BRANCH = "main"

# 1. Login check
Write-Host "Step 1: Checking Azure login..." -ForegroundColor Yellow
try {
    $null = az account show 2>$null
    Write-Host "✅ Already logged in to Azure" -ForegroundColor Green
} catch {
    Write-Host "Not logged in. Running 'az login'..." -ForegroundColor Yellow
    az login
}
Write-Host ""

# 2. Get Subscription and Tenant IDs
Write-Host "Step 2: Getting Azure account details..." -ForegroundColor Yellow
$SUBSCRIPTION_ID = az account show --query id -o tsv
$TENANT_ID = az account show --query tenantId -o tsv
Write-Host "✅ Subscription ID: $SUBSCRIPTION_ID" -ForegroundColor Green
Write-Host "✅ Tenant ID: $TENANT_ID" -ForegroundColor Green
Write-Host ""

# 3. Check if app already exists
Write-Host "Step 3: Checking if app registration exists..." -ForegroundColor Yellow
$EXISTING_APP_ID = az ad app list --display-name $APP_NAME --query [0].appId -o tsv

if ([string]::IsNullOrEmpty($EXISTING_APP_ID)) {
    Write-Host "Creating new app registration '$APP_NAME'..." -ForegroundColor Yellow
    az ad app create --display-name $APP_NAME | Out-Null
    $CLIENT_ID = az ad app list --display-name $APP_NAME --query [0].appId -o tsv
    Write-Host "✅ Created app registration" -ForegroundColor Green
    
    Write-Host "Creating service principal..." -ForegroundColor Yellow
    az ad sp create --id $CLIENT_ID | Out-Null
    Write-Host "✅ Created service principal" -ForegroundColor Green
} else {
    $CLIENT_ID = $EXISTING_APP_ID
    Write-Host "✅ App registration already exists (reusing)" -ForegroundColor Green
}
Write-Host "✅ Client ID: $CLIENT_ID" -ForegroundColor Green
Write-Host ""

# 4. Create or update federated credential
Write-Host "Step 4: Setting up GitHub OIDC federation..." -ForegroundColor Yellow
$CRED_NAME = "github-actions-main"
$EXISTING_CRED = az ad app federated-credential list --id $CLIENT_ID --query "[?name=='$CRED_NAME'].name" -o tsv

if ([string]::IsNullOrEmpty($EXISTING_CRED)) {
    Write-Host "Creating federated credential..." -ForegroundColor Yellow
    
    $federatedCredParams = @{
        name = $CRED_NAME
        issuer = "https://token.actions.githubusercontent.com"
        subject = "repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/$GITHUB_BRANCH"
        description = "GitHub Actions OIDC for main branch"
        audiences = @("api://AzureADTokenExchange")
    } | ConvertTo-Json -Compress
    
    az ad app federated-credential create --id $CLIENT_ID --parameters $federatedCredParams | Out-Null
    Write-Host "✅ Created federated credential" -ForegroundColor Green
} else {
    Write-Host "✅ Federated credential already exists (reusing)" -ForegroundColor Green
}
Write-Host ""

# 5. Assign Contributor role
Write-Host "Step 5: Assigning Contributor role..." -ForegroundColor Yellow
$EXISTING_ROLE = az role assignment list --assignee $CLIENT_ID --scope "/subscriptions/$SUBSCRIPTION_ID" --query "[?roleDefinitionName=='Contributor'].roleDefinitionName" -o tsv

if ([string]::IsNullOrEmpty($EXISTING_ROLE)) {
    Write-Host "Creating role assignment..." -ForegroundColor Yellow
    az role assignment create --assignee $CLIENT_ID --role Contributor --scope "/subscriptions/$SUBSCRIPTION_ID" | Out-Null
    Write-Host "✅ Assigned Contributor role" -ForegroundColor Green
} else {
    Write-Host "✅ Contributor role already assigned" -ForegroundColor Green
}
Write-Host ""

# 6. Display results
Write-Host "==================================================" -ForegroundColor Green
Write-Host "✅ OIDC SETUP COMPLETE!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

# 7. Add secrets to GitHub automatically (if gh CLI is available)
Write-Host "Step 6: Adding secrets to GitHub..." -ForegroundColor Yellow
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue

if ($ghInstalled) {
    Write-Host "GitHub CLI detected! Attempting to add secrets automatically..." -ForegroundColor Yellow
    
    # Check if authenticated
    try {
        $ghAuth = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Authenticated to GitHub" -ForegroundColor Green
            
            # Add secrets
            Write-Host "Adding AZURE_CLIENT_ID..." -ForegroundColor Yellow
            echo $CLIENT_ID | gh secret set AZURE_CLIENT_ID -R "$GITHUB_ORG/$GITHUB_REPO"
            
            Write-Host "Adding AZURE_TENANT_ID..." -ForegroundColor Yellow
            echo $TENANT_ID | gh secret set AZURE_TENANT_ID -R "$GITHUB_ORG/$GITHUB_REPO"
            
            Write-Host "Adding AZURE_SUBSCRIPTION_ID..." -ForegroundColor Yellow
            echo $SUBSCRIPTION_ID | gh secret set AZURE_SUBSCRIPTION_ID -R "$GITHUB_ORG/$GITHUB_REPO"
            
            Write-Host ""
            Write-Host "==================================================" -ForegroundColor Green
            Write-Host "✅ SECRETS ADDED TO GITHUB AUTOMATICALLY!" -ForegroundColor Green
            Write-Host "==================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Verify at: https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions" -ForegroundColor Cyan
        } else {
            throw "Not authenticated"
        }
    } catch {
        Write-Host "⚠️  Not authenticated to GitHub CLI" -ForegroundColor Yellow
        Write-Host "Run 'gh auth login' first, then re-run this script" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "OR add manually:" -ForegroundColor Cyan
        Write-Host "https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Secret Name: AZURE_CLIENT_ID" -ForegroundColor Yellow
        Write-Host "Value: $CLIENT_ID" -ForegroundColor White
        Write-Host ""
        Write-Host "Secret Name: AZURE_TENANT_ID" -ForegroundColor Yellow
        Write-Host "Value: $TENANT_ID" -ForegroundColor White
        Write-Host ""
        Write-Host "Secret Name: AZURE_SUBSCRIPTION_ID" -ForegroundColor Yellow
        Write-Host "Value: $SUBSCRIPTION_ID" -ForegroundColor White
        Write-Host ""
    }
} else {
    Write-Host "⚠️  GitHub CLI (gh) not installed" -ForegroundColor Yellow
    Write-Host "Install from: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "OR add these THREE values to GitHub Secrets manually:" -ForegroundColor Cyan
    Write-Host "https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Secret Name: AZURE_CLIENT_ID" -ForegroundColor Yellow
    Write-Host "Value: $CLIENT_ID" -ForegroundColor White
    Write-Host ""
    Write-Host "Secret Name: AZURE_TENANT_ID" -ForegroundColor Yellow
    Write-Host "Value: $TENANT_ID" -ForegroundColor White
    Write-Host ""
    Write-Host "Secret Name: AZURE_SUBSCRIPTION_ID" -ForegroundColor Yellow
    Write-Host "Value: $SUBSCRIPTION_ID" -ForegroundColor White
    Write-Host ""
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "1. ✅ Azure OIDC configured"
Write-Host "2. ✅ GitHub secrets configured (or add manually above)"
Write-Host "3. Run: cd infrastructure; terraform init"
Write-Host "4. Run: terraform apply -var-file=dev.tfvars"
Write-Host "5. Push code: git push origin main"
Write-Host "6. GitHub Actions will use OIDC (no secrets!) ✅"
Write-Host ""
Write-Host "No rotation needed - tokens auto-expire! 🎉" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
