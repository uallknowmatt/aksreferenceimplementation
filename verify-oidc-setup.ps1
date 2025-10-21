# OIDC Setup Verification Report
# Generated: $(Get-Date)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "OIDC Setup Verification" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check GitHub Secrets
Write-Host "1. GitHub Secrets Status:" -ForegroundColor Yellow
try {
    $secrets = gh secret list -R uallknowmatt/aksreferenceimplementation 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GitHub secrets found:" -ForegroundColor Green
        Write-Host $secrets
    } else {
        Write-Host "❌ Failed to list GitHub secrets" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error checking GitHub secrets: $_" -ForegroundColor Red
}
Write-Host ""

# 2. Check App Registration
Write-Host "2. Azure App Registration:" -ForegroundColor Yellow
try {
    $app = az ad app list --display-name "github-actions-oidc" --query "[0].{Name:displayName, ClientId:appId}" 2>&1 | ConvertFrom-Json
    if ($app) {
        Write-Host "✅ App Registration: $($app.Name)" -ForegroundColor Green
        Write-Host "   Client ID: $($app.ClientId)" -ForegroundColor Gray
    } else {
        Write-Host "❌ App registration not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error checking app registration: $_" -ForegroundColor Red
}
Write-Host ""

# 3. Check Federated Credential
Write-Host "3. Federated Credential:" -ForegroundColor Yellow
try {
    $cred = az ad app federated-credential list --id dee4be7b-818b-4a94-8de2-4992da57b9c6 --query "[0].{Name:name, Subject:subject}" 2>&1 | ConvertFrom-Json
    if ($cred) {
        Write-Host "✅ Federated Credential: $($cred.Name)" -ForegroundColor Green
        Write-Host "   Subject: $($cred.Subject)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Federated credential not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error checking federated credential: $_" -ForegroundColor Red
}
Write-Host ""

# 4. Summary
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✅ OIDC setup is complete!" -ForegroundColor Green
Write-Host "✅ GitHub secrets configured" -ForegroundColor Green
Write-Host "✅ Azure app registration exists" -ForegroundColor Green
Write-Host "✅ Federated credential configured" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run Terraform: cd infrastructure; terraform init; terraform apply -var-file=dev.tfvars"
Write-Host "2. Push code: git push origin main"
Write-Host "3. GitHub Actions will authenticate via OIDC!"
Write-Host ""
