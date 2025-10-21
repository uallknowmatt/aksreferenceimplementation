# OIDC Setup Verification Guide (Azure CLI)

This guide shows you how to verify your OIDC setup using **Azure CLI only** - no need to navigate the Azure Portal!

---

## 🎯 Quick Verification Commands

Run these commands to verify your complete OIDC setup:

### 1. Verify You're Logged Into Azure

```bash
az account show
```

**What to check:**
```json
{
  "id": "d8797220-f5cf-4668-a271-39ce114bb150",  ← Your subscription ID
  "name": "Azure subscription 1",
  "tenantId": "c742e0a4-0cf9-4202-aec8-f4b52ecf17cf"  ← Your tenant ID
}
```

---

### 2. Verify App Registration Exists

```bash
az ad app list --display-name "github-actions-oidc" --query "[].{Name:displayName, ClientId:appId}" -o table
```

**Expected output:**
```
Name                 ClientId
-------------------  ------------------------------------
github-actions-oidc  dee4be7b-818b-4a94-8de2-4992da57b9c6
```

**What it means:**
- App registration exists in Azure AD
- Client ID is what GitHub Actions will use to authenticate

---

### 3. Verify Service Principal Exists

```bash
az ad sp list --display-name "github-actions-oidc" --query "[].{Name:displayName, AppId:appId, ObjectId:id}" -o table
```

**Expected output:**
```
Name                 AppId                                 ObjectId
-------------------  ------------------------------------  ------------------------------------
github-actions-oidc  dee4be7b-818b-4a94-8de2-4992da57b9c6  f9e8d7c6-b5a4-3210-9876-543210fedcba
```

**What it means:**
- Service principal (the "account" that can do things) exists
- AppId matches the app registration
- ObjectId is the service principal's unique ID (different from AppId)

---

### 4. Verify Federated Credential (OIDC Trust)

```bash
az ad app federated-credential list --id dee4be7b-818b-4a94-8de2-4992da57b9c6 --query "[].{Name:name, Issuer:issuer, Subject:subject, Audiences:audiences}" -o table
```

**Expected output:**
```
Name                 Issuer                                        Subject                                                           Audiences
-------------------  --------------------------------------------  ----------------------------------------------------------------  -------------------------
github-actions-main  https://token.actions.githubusercontent.com   repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main  ['api://AzureADTokenExchange']
```

**What it means:**
- Azure trusts GitHub's OIDC tokens
- Only YOUR specific repo (uallknowmatt/aksreferenceimplementation) can authenticate
- Only the "main" branch can authenticate
- This is the CORE of OIDC security!

---

### 5. Verify Role Assignment (Permissions)

```bash
az role assignment list --assignee dee4be7b-818b-4a94-8de2-4992da57b9c6 --query "[].{Role:roleDefinitionName, Scope:scope}" -o table
```

**Expected output:**
```
Role         Scope
-----------  ---------------------------------------------------------------
Contributor  /subscriptions/d8797220-f5cf-4668-a271-39ce114bb150
```

**What it means:**
- Service principal has "Contributor" role (can create/manage resources)
- Scope is entire subscription (can work anywhere in the subscription)
- This is what allows Terraform to create infrastructure

---

### 6. Verify GitHub Secrets

```bash
gh secret list -R uallknowmatt/aksreferenceimplementation
```

**Expected output:**
```
NAME                   UPDATED           
AZURE_CLIENT_ID        2025-10-19T22:54:10Z
AZURE_SUBSCRIPTION_ID  2025-10-19T22:54:12Z
AZURE_TENANT_ID        2025-10-19T22:54:12Z
```

**What it means:**
- All 3 required secrets are configured in GitHub
- GitHub Actions can authenticate to Azure using OIDC

---

## 📋 Complete Verification Script

Save this as `verify-oidc-cli.sh` (Bash) or `verify-oidc-cli.ps1` (PowerShell):

### Bash Version

```bash
#!/bin/bash

CLIENT_ID="dee4be7b-818b-4a94-8de2-4992da57b9c6"
REPO="uallknowmatt/aksreferenceimplementation"

echo "========================================="
echo "OIDC Setup Verification"
echo "========================================="
echo ""

echo "1. Azure Login Status:"
az account show --query "{Subscription:name, SubscriptionId:id, TenantId:tenantId}" -o json
echo ""

echo "2. App Registration:"
az ad app list --display-name "github-actions-oidc" --query "[0].{Name:displayName, ClientId:appId}" -o json
echo ""

echo "3. Service Principal:"
az ad sp list --display-name "github-actions-oidc" --query "[0].{Name:displayName, AppId:appId}" -o json
echo ""

echo "4. Federated Credential:"
az ad app federated-credential list --id $CLIENT_ID --query "[0].{Name:name, Subject:subject}" -o json
echo ""

echo "5. Role Assignment:"
az role assignment list --assignee $CLIENT_ID --query "[0].{Role:roleDefinitionName, Scope:scope}" -o json
echo ""

echo "6. GitHub Secrets:"
gh secret list -R $REPO
echo ""

echo "========================================="
echo "✅ Verification Complete!"
echo "========================================="
```

### PowerShell Version

```powershell
$CLIENT_ID = "dee4be7b-818b-4a94-8de2-4992da57b9c6"
$REPO = "uallknowmatt/aksreferenceimplementation"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "OIDC Setup Verification" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Azure Login Status:" -ForegroundColor Yellow
az account show --query "{Subscription:name, SubscriptionId:id, TenantId:tenantId}" -o json | ConvertFrom-Json | Format-List
Write-Host ""

Write-Host "2. App Registration:" -ForegroundColor Yellow
az ad app list --display-name "github-actions-oidc" --query "[0].{Name:displayName, ClientId:appId}" -o json | ConvertFrom-Json | Format-List
Write-Host ""

Write-Host "3. Service Principal:" -ForegroundColor Yellow
az ad sp list --display-name "github-actions-oidc" --query "[0].{Name:displayName, AppId:appId}" -o json | ConvertFrom-Json | Format-List
Write-Host ""

Write-Host "4. Federated Credential:" -ForegroundColor Yellow
az ad app federated-credential list --id $CLIENT_ID --query "[0].{Name:name, Subject:subject}" -o json | ConvertFrom-Json | Format-List
Write-Host ""

Write-Host "5. Role Assignment:" -ForegroundColor Yellow
az role assignment list --assignee $CLIENT_ID --query "[0].{Role:roleDefinitionName, Scope:scope}" -o json | ConvertFrom-Json | Format-List
Write-Host ""

Write-Host "6. GitHub Secrets:" -ForegroundColor Yellow
gh secret list -R $REPO
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "✅ Verification Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
```

---

## 🔍 Deep Dive: Understanding Each Component

### App Registration vs Service Principal

**Analogy: Job Description vs Employee**

```
App Registration     = Job description (what the role does)
Service Principal    = Actual employee hired for that job
Federated Credential = Employee's ID badge (how they prove identity)
Role Assignment      = Office access permissions
```

**In Azure:**
- **App Registration**: Defines the application (in Azure AD)
  - Has a Client ID
  - Can have multiple authentication methods (passwords, certificates, OIDC)
  
- **Service Principal**: The actual identity that can do things
  - Created from app registration
  - Gets role assignments (permissions)
  - This is what actually runs and accesses resources

### Federated Credential Fields Explained

```json
{
  "name": "github-actions-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}
```

**Field by field:**

1. **`name`**: Friendly name for this credential
   - Just for your reference
   - Can have multiple federated credentials (e.g., one per branch)

2. **`issuer`**: Who generates the tokens? 
   - `https://token.actions.githubusercontent.com` = GitHub's token service
   - Azure will ONLY trust tokens from this URL
   - GitHub signs all workflow tokens with this issuer

3. **`subject`**: Who is allowed to authenticate?
   - Format: `repo:OWNER/REPO:ref:refs/heads/BRANCH`
   - `repo:uallknowmatt/aksreferenceimplementation` = Only this repo
   - `ref:refs/heads/main` = Only the main branch
   - Can also use: `environment:production`, `pull_request`, etc.

4. **`audiences`**: What is this token for?
   - `api://AzureADTokenExchange` = Azure's OIDC endpoint
   - Ensures token was meant for Azure (not someone else)

### Role Assignment Scope Levels

```
/subscriptions/{subscription-id}
└── Entire subscription (what we use)
    └── Can create/manage ANY resource type
    └── Can create resource groups
    └── Full flexibility for Terraform

/subscriptions/{subscription-id}/resourceGroups/{rg-name}
└── Single resource group only
    └── Can only work in this one resource group
    └── More restrictive, better for production

/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/{provider}/{resource}
└── Single specific resource
    └── Most restrictive
    └── Example: One specific VM or storage account
```

---

## 🛠️ Troubleshooting Commands

### Problem: Can't find app registration

```bash
# List ALL apps (no filter)
az ad app list --query "[].{Name:displayName, ClientId:appId}" -o table

# Search by partial name
az ad app list --query "[?contains(displayName, 'github')].{Name:displayName, ClientId:appId}" -o table
```

### Problem: Service principal missing

```bash
# Create service principal from existing app
az ad sp create --id <CLIENT_ID>
```

### Problem: Federated credential not found

```bash
# List all federated credentials for an app
az ad app federated-credential list --id <CLIENT_ID>

# Create new federated credential
az ad app federated-credential create \
  --id <CLIENT_ID> \
  --parameters @federated-credential.json
```

### Problem: No role assignment

```bash
# List all role assignments for service principal
az role assignment list --assignee <CLIENT_ID> --all

# Create Contributor role at subscription level
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az role assignment create \
  --assignee <CLIENT_ID> \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### Problem: GitHub secrets not set

```bash
# Check if gh CLI is authenticated
gh auth status

# Add secrets manually
echo "<CLIENT_ID>" | gh secret set AZURE_CLIENT_ID -R <ORG>/<REPO>
echo "<TENANT_ID>" | gh secret set AZURE_TENANT_ID -R <ORG>/<REPO>
echo "<SUBSCRIPTION_ID>" | gh secret set AZURE_SUBSCRIPTION_ID -R <ORG>/<REPO>
```

---

## 📊 Quick Status Check (One-Liners)

```bash
# Check app exists
az ad app show --id dee4be7b-818b-4a94-8de2-4992da57b9c6 --query displayName -o tsv

# Check federated credential count
az ad app federated-credential list --id dee4be7b-818b-4a94-8de2-4992da57b9c6 --query "length(@)"

# Check role assignment scope
az role assignment list --assignee dee4be7b-818b-4a94-8de2-4992da57b9c6 --query "[0].scope" -o tsv

# Output: /subscriptions/d8797220-f5cf-4668-a271-39ce114bb150
```

---

## ✅ Success Criteria

Your OIDC setup is correct if ALL of these return values:

```bash
# 1. App registration exists
az ad app list --display-name "github-actions-oidc" --query "[0].appId" -o tsv
# Output: dee4be7b-818b-4a94-8de2-4992da57b9c6

# 2. Service principal exists
az ad sp list --display-name "github-actions-oidc" --query "[0].appId" -o tsv
# Output: dee4be7b-818b-4a94-8de2-4992da57b9c6

# 3. Federated credential exists
az ad app federated-credential list --id dee4be7b-818b-4a94-8de2-4992da57b9c6 --query "[0].name" -o tsv
# Output: github-actions-main

# 4. Role assignment exists
az role assignment list --assignee dee4be7b-818b-4a94-8de2-4992da57b9c6 --query "[0].roleDefinitionName" -o tsv
# Output: Contributor

# 5. GitHub secrets configured
gh secret list -R uallknowmatt/aksreferenceimplementation | wc -l
# Output: 3 (or 4 with header)
```

---

## 🚀 Next Steps After Verification

Once all verification checks pass:

1. **Run Terraform** to create infrastructure:
   ```bash
   cd infrastructure
   terraform init
   terraform apply -var-file=dev.tfvars
   ```

2. **Push code** to trigger GitHub Actions:
   ```bash
   git push origin main
   ```

3. **Watch GitHub Actions authenticate** via OIDC:
   - Go to: https://github.com/uallknowmatt/aksreferenceimplementation/actions
   - Click on workflow run
   - Look for "Azure Login via OIDC" step
   - Should succeed with no password!

---

## 📚 Additional Resources

- [Azure CLI Reference - az ad app](https://learn.microsoft.com/en-us/cli/azure/ad/app)
- [Azure CLI Reference - az ad sp](https://learn.microsoft.com/en-us/cli/azure/ad/sp)
- [Azure CLI Reference - az role assignment](https://learn.microsoft.com/en-us/cli/azure/role/assignment)
- [GitHub CLI Reference - gh secret](https://cli.github.com/manual/gh_secret)

---

**Your OIDC setup is production-ready! 🎉**
