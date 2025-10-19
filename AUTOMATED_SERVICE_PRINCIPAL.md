# 🤖 Automated Service Principal Setup with Terraform

## ✨ What's Automated

**No more manual `az ad sp create-for-rbac` commands!**

Terraform now automatically creates and configures:
- ✅ Azure AD Application for GitHub Actions
- ✅ Service Principal with proper permissions
- ✅ Client Secret (valid for 1 year)
- ✅ Role assignments (Contributor, AcrPush, AKS Admin)
- ✅ Complete AZURE_CREDENTIALS JSON output

---

## 🚀 Updated Deployment Workflow

### Step 1: Disable GitHub Actions (Prevent Premature Deployment)

1. Go to your GitHub repository
2. Navigate to **Settings** → **Actions** → **General**
3. Under "Actions permissions", select **Disable actions**
4. Click **Save**

This prevents the workflow from running while we set up infrastructure.

---

### Step 2: Run Terraform (Creates Everything Including Service Principal!)

```bash
cd infrastructure

# Login to Azure
az login

# Initialize Terraform
terraform init

# Plan (review what will be created)
terraform plan -var-file=dev.tfvars

# Apply (creates all resources + service principal)
terraform apply -var-file=dev.tfvars
```

**What Terraform creates:**
- Resource Group
- AKS Cluster
- Azure Container Registry
- PostgreSQL Flexible Server (4 databases)
- VNet and Subnets
- **Service Principal for GitHub Actions** ← Automated!
- All role assignments
- All permissions

---

### Step 3: Get GitHub Secrets Values

After `terraform apply` completes, run these commands:

```bash
# See the summary of all secrets
terraform output github_secrets_summary

# Get sensitive values individually
terraform output -raw acr_admin_password
terraform output -raw postgres_admin_password
terraform output -raw azure_credentials_json

# Get all non-sensitive values
terraform output
```

**Example output:**

```
╔══════════════════════════════════════════════════════════════════╗
║          🚀 AUTOMATED GITHUB SECRETS - READY TO USE! 🚀          ║
╚══════════════════════════════════════════════════════════════════╝

✅ Service Principal created automatically by Terraform!
✅ All permissions configured (Contributor, AcrPush, AKS Admin)
✅ No manual az ad sp create-for-rbac needed!

Add these secrets to your GitHub repository:
👉 https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions

┌──────────────────────────────────────────────────────────────────┐
│ REQUIRED SECRETS (Copy these values)                             │
├──────────────────────────────────────────────────────────────────┤
│ ACR_LOGIN_SERVER      = myacr.azurecr.io
│ ACR_USERNAME          = myacr
│ ACR_PASSWORD          = (Run: terraform output -raw acr_admin_password)
│ AKS_CLUSTER_NAME      = account-opening-aks-dev
│ AKS_RESOURCE_GROUP    = account-opening-rg-dev
│ POSTGRES_HOST         = mypostgres.postgres.database.azure.com
│ POSTGRES_USERNAME     = postgres
│ POSTGRES_PASSWORD     = (Run: terraform output -raw postgres_admin_password)
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ AZURE_CREDENTIALS (Service Principal JSON - AUTO-GENERATED!)     │
├──────────────────────────────────────────────────────────────────┤
│ Run this command to get the complete JSON:                       │
│                                                                   │
│ terraform output -raw azure_credentials_json                     │
│                                                                   │
│ Then paste the entire JSON as AZURE_CREDENTIALS secret           │
└──────────────────────────────────────────────────────────────────┘
```

---

### Step 4: Configure GitHub Secrets

1. Go to https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
2. Click **New repository secret** for each:

#### Non-Sensitive Secrets (copy from terraform output)
- **ACR_LOGIN_SERVER** - Copy from output
- **ACR_USERNAME** - Copy from output
- **AKS_CLUSTER_NAME** - Copy from output
- **AKS_RESOURCE_GROUP** - Copy from output
- **POSTGRES_HOST** - Copy from output
- **POSTGRES_USERNAME** - Copy from output

#### Sensitive Secrets (use terraform output -raw commands)

**ACR_PASSWORD:**
```bash
terraform output -raw acr_admin_password
# Copy the output and paste as secret value
```

**POSTGRES_PASSWORD:**
```bash
terraform output -raw postgres_admin_password
# Copy the output and paste as secret value
```

**AZURE_CREDENTIALS** (The big one!):
```bash
terraform output -raw azure_credentials_json
# This outputs complete JSON like:
# {"clientId":"xxx","clientSecret":"xxx","subscriptionId":"xxx","tenantId":"xxx"}
# Copy the ENTIRE JSON and paste as secret value
```

---

### Step 5: Re-enable GitHub Actions

1. Go back to **Settings** → **Actions** → **General**
2. Under "Actions permissions", select **Allow all actions and reusable workflows**
3. Click **Save**

---

### Step 6: Trigger Deployment

Option A: Push code
```bash
git push origin main
```

Option B: Trigger manually from empty commit
```bash
git commit --allow-empty -m "Trigger deployment with automated service principal"
git push origin main
```

GitHub Actions will now:
1. ✅ Authenticate to Azure (using auto-generated service principal)
2. ✅ Build all microservices
3. ✅ Push Docker images to ACR
4. ✅ Deploy to AKS
5. ✅ Liquibase migrations run automatically

---

## 🔍 How It Works

### Terraform Resources Created

**`infrastructure/iam.tf`** now contains:

```terraform
# Creates Azure AD Application
resource "azuread_application" "github_actions" {
  display_name = "account-opening-github-actions-dev"
}

# Creates Service Principal from the application
resource "azuread_service_principal" "github_actions" {
  client_id = azuread_application.github_actions.client_id
}

# Creates password/secret for the service principal (1 year validity)
resource "azuread_service_principal_password" "github_actions" {
  service_principal_id = azuread_service_principal.github_actions.object_id
  end_date_relative    = "8760h" # 1 year
}

# Grants permissions
resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions.object_id
}

resource "azurerm_role_assignment" "github_actions_aks_admin" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_service_principal.github_actions.object_id
}
```

### Idempotency

**Safe to run multiple times:**
- If service principal exists → No change (Terraform state tracks it)
- If service principal doesn't exist → Creates it
- If permissions exist → No change
- If permissions missing → Adds them

**No duplicate resources:** Terraform manages the lifecycle, so you never get duplicate service principals or role assignments.

---

## 🔄 Updating/Rotating Credentials

### Rotate Service Principal Secret (After 1 Year)

```bash
cd infrastructure

# Terraform will detect the secret is expiring and recreate it
terraform apply -var-file=dev.tfvars

# Get the new JSON
terraform output -raw azure_credentials_json

# Update AZURE_CREDENTIALS secret in GitHub
```

### Destroy and Recreate

```bash
# Remove just the service principal
terraform destroy -target=azuread_service_principal_password.github_actions
terraform apply

# Or destroy everything and recreate
terraform destroy -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

---

## 🎯 Benefits of This Approach

### ✅ Automation
- No manual Azure portal clicks
- No remembering complex `az ad` commands
- Consistent across environments (dev/prod)

### ✅ Idempotency
- Safe to run `terraform apply` multiple times
- No duplicate resources
- Infrastructure as Code best practice

### ✅ Security
- Credentials stored in Terraform state (encrypted in Azure Storage backend)
- Secrets auto-generated with proper complexity
- Easy rotation via Terraform

### ✅ Documentation
- Service principal configuration is in code
- Permissions are explicit and reviewable
- Easy to see what access is granted

### ✅ Team Collaboration
- Anyone with Terraform access can recreate infrastructure
- No "tribal knowledge" about manual setup
- Works the same way every time

---

## 🆚 Comparison: Manual vs Automated

### ❌ Old Manual Way

```bash
# Step 1: Create service principal manually
az ad sp create-for-rbac \
  --name "github-actions-account-opening" \
  --role contributor \
  --scopes /subscriptions/xxx/resourceGroups/xxx \
  --sdk-auth

# Step 2: Copy JSON output somewhere safe
# Step 3: Grant additional permissions manually
az role assignment create --assignee xxx --role AcrPush --scope xxx
az role assignment create --assignee xxx --role "AKS Admin" --scope xxx

# Step 4: Hope you didn't lose the JSON
# Step 5: Remember to rotate credentials manually after 1 year
```

**Problems:**
- Manual steps prone to errors
- Credentials can be lost
- Hard to replicate
- Easy to forget rotation
- Not in version control

### ✅ New Automated Way

```bash
# Step 1: Run Terraform
terraform apply -var-file=dev.tfvars

# Step 2: Get outputs
terraform output -raw azure_credentials_json

# Step 3: Add to GitHub Secrets
# Done! ✅
```

**Benefits:**
- Fully automated
- Repeatable
- In version control
- Easy to rotate
- Consistent across environments

---

## 🔐 Security Best Practices

### Terraform State Security

**Important:** Terraform state contains sensitive values (service principal secrets)

**Recommended:** Use Azure Storage backend for Terraform state

```terraform
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "account-opening.tfstate"
  }
}
```

This encrypts state at rest in Azure and enables state locking for team collaboration.

### Alternative: Use GitHub Secrets for Sensitive tfvars

Instead of committing `dev.tfvars` with passwords, use:

```bash
# Set as environment variables
export TF_VAR_db_admin_password="SecurePassword123!"

# Or use GitHub Actions secrets
# Store dev.tfvars values as GitHub secrets
# Reference them in workflow
```

---

## 📝 Example Complete Workflow

### First-Time Setup

```bash
# 1. Disable GitHub Actions (via web UI)

# 2. Run Terraform
cd infrastructure
az login
terraform init
terraform apply -var-file=dev.tfvars

# 3. Get all secrets
echo "=== ACR Password ==="
terraform output -raw acr_admin_password

echo "\n=== Postgres Password ==="
terraform output -raw postgres_admin_password

echo "\n=== Azure Credentials JSON ==="
terraform output -raw azure_credentials_json

echo "\n=== Summary ==="
terraform output github_secrets_summary

# 4. Add all secrets to GitHub (via web UI)

# 5. Re-enable GitHub Actions (via web UI)

# 6. Deploy
git push origin main
```

### Subsequent Updates

```bash
# Just run Terraform
terraform apply -var-file=dev.tfvars

# If you added/changed resources, update GitHub secrets if needed
terraform output github_secrets_summary
```

---

## ✅ Checklist

Use this checklist when setting up:

- [ ] Disable GitHub Actions temporarily
- [ ] Run `terraform init`
- [ ] Run `terraform apply -var-file=dev.tfvars`
- [ ] Wait for completion (~10-15 minutes)
- [ ] Run `terraform output github_secrets_summary`
- [ ] Run `terraform output -raw acr_admin_password`
- [ ] Run `terraform output -raw postgres_admin_password`
- [ ] Run `terraform output -raw azure_credentials_json`
- [ ] Add all 9 secrets to GitHub
- [ ] Re-enable GitHub Actions
- [ ] Push code to trigger deployment
- [ ] Monitor GitHub Actions workflow
- [ ] Verify pods running in AKS

---

## 🎉 Summary

**Before:** Manual service principal creation, easy to mess up, hard to replicate

**After:** Fully automated, consistent, repeatable, secure, version-controlled

**Key Point:** You asked "is there a way to automate that first step on push of the code. create it in iac code. if it exists no change else create it" - **YES! ✅** 

Terraform now handles everything automatically. The service principal is created as part of `terraform apply`, with proper idempotency (safe to run multiple times). No manual Azure AD commands needed!

---

**Your infrastructure is now fully automated! 🚀**
