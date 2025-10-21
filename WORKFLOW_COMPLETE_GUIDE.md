# GitHub Actions Workflow - Complete Guide

## Overview

This workflow properly orchestrates the deployment of Azure infrastructure and applications in the correct order:

1. **Job 1: Deploy Infrastructure** - Creates all Azure resources using Terraform
2. **Job 2: Build & Push Images** - Builds microservices and pushes to ACR (created in Job 1)
3. **Job 3: Deploy to AKS** - Deploys applications to Kubernetes (created in Job 1)

## Why This Structure?

### ❌ Previous Problem
The old workflow tried to read Terraform outputs **before** creating infrastructure:
```yaml
- terraform init
- terraform output  # ERROR: No outputs found! Infrastructure doesn't exist yet!
```

### ✅ New Solution
The workflow now follows the correct sequence:
```yaml
Job 1: terraform apply → Creates infrastructure
       terraform output → Reads values from CREATED resources
       
Job 2: Uses outputs from Job 1 → Builds and pushes images
       
Job 3: Uses outputs from Job 1 → Deploys to Kubernetes
```

## Workflow Structure

### Job 1: terraform-deploy
**Purpose**: Create all Azure infrastructure

**Steps**:
1. ✅ Azure Login (OIDC)
2. ✅ Terraform Init - Download providers
3. ✅ Terraform Validate - Check configuration syntax
4. ✅ Terraform Plan - Preview changes (saves to tfplan file)
5. ✅ Terraform Apply - **CREATE INFRASTRUCTURE**
6. ✅ Terraform Output - Read values from created resources

**Outputs** (passed to Job 2 and Job 3):
- `acr_login_server` - ACR URL (e.g., bankaccountregistrydev.azurecr.io)
- `acr_name` - ACR name (e.g., bankaccountregistrydev)
- `aks_cluster_name` - AKS cluster name
- `aks_resource_group` - Resource group name
- `postgres_host` - PostgreSQL server FQDN
- `managed_identity_client_id` - Workload identity for pods

**What Gets Created**:
- Resource Group
- Virtual Network & Subnets
- Azure Container Registry (ACR)
- AKS Cluster with Workload Identity
- PostgreSQL Flexible Server with databases
- Network Security Groups
- Log Analytics Workspace
- Role Assignments

### Job 2: build-and-push
**Purpose**: Build microservices and push Docker images to ACR

**Depends On**: `terraform-deploy` (needs ACR to exist)

**Steps**:
1. ✅ Azure Login (OIDC)
2. ✅ Set up JDK 17 with Maven cache
3. ✅ Build all microservices: `mvn clean package -DskipTests`
4. ✅ Login to ACR (uses `acr_name` from Job 1)
5. ✅ Build Docker images for all 4 services
6. ✅ Push images to ACR

**Images Built**:
- `customer-service:${GITHUB_SHA}`
- `document-service:${GITHUB_SHA}`
- `account-service:${GITHUB_SHA}`
- `notification-service:${GITHUB_SHA}`

### Job 3: deploy-to-aks
**Purpose**: Deploy applications to Kubernetes

**Depends On**: `terraform-deploy` (needs AKS) AND `build-and-push` (needs images)

**Steps**:
1. ✅ Azure Login (OIDC)
2. ✅ Set AKS context (uses cluster name and resource group from Job 1)
3. ✅ Replace placeholders in k8s manifests:
   - `<ACR_LOGIN_SERVER>` → Actual ACR URL
   - `<TAG>` → Git commit SHA
   - `<MANAGED_IDENTITY_CLIENT_ID>` → Workload identity
   - `<POSTGRES_HOST>` → PostgreSQL FQDN
4. ✅ Deploy ConfigMaps and Secrets
5. ✅ Deploy Kubernetes Services
6. ✅ Deploy Applications (Deployments)
7. ✅ Wait for rollout completion (5 min timeout per service)
8. ✅ Display deployment summary

## Job Dependencies

```
terraform-deploy (Job 1)
       ├─────────┬─────────┐
       ↓         ↓         ↓
       │    build-and-push (Job 2)
       │         ↓
       └────→ deploy-to-aks (Job 3)
```

**Why This Order**:
- Job 2 needs ACR (created in Job 1) to push images
- Job 3 needs AKS (created in Job 1) AND images (pushed in Job 2)

## Key Improvements

### 1. Terraform Validation
```yaml
- name: Terraform Validate
  run: terraform validate
```
Catches configuration errors before apply!

### 2. Terraform Plan Saved
```yaml
- name: Terraform Plan
  run: terraform plan -var-file=dev.tfvars -out=tfplan

- name: Terraform Apply
  run: terraform apply -auto-approve tfplan
```
- Plan saves to file: `tfplan`
- Apply uses saved plan (not re-planning)
- More reliable and faster

### 3. Better Logging
Each step includes descriptive echo statements:
```yaml
echo "Building customer-service..."
echo "✅ All images pushed to ACR!"
```

### 4. Manual Trigger
```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:  # Add this!
```
Allows manual workflow runs for testing!

## Environment Variables

```yaml
env:
  IMAGE_TAG: ${{ github.sha }}        # Git commit SHA
  TF_WORKING_DIR: ./infrastructure    # Terraform files location
  ENVIRONMENT: dev                    # Use dev.tfvars
```

## Secrets Required

All configured via OIDC setup:
- `AZURE_CLIENT_ID` - App registration client ID
- `AZURE_TENANT_ID` - Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID` - Subscription ID

**NO PASSWORDS NEEDED!** 🎉

## Terraform State Management

### Current: Local State
The workflow currently uses **local state** stored in the GitHub Actions runner.

**Limitations**:
- ❌ State lost after workflow completes
- ❌ Can't run `terraform destroy` later
- ❌ No state locking
- ❌ Can't share state across workflows

### Recommended: Azure Storage Backend

To persist state, add `backend.tf`:

```terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatebankapps"
    container_name       = "tfstate"
    key                  = "aks-deployment.tfstate"
    use_oidc             = true  # Use OIDC authentication!
  }
}
```

**Benefits**:
- ✅ State persists across workflow runs
- ✅ State locking prevents concurrent modifications
- ✅ Team can share state
- ✅ Can run destroy operations
- ✅ State versioning and backup

**Setup Steps**:
```bash
# Create storage account for state (one time)
az group create --name terraform-state-rg --location eastus

az storage account create \
  --name tfstatebankapps \
  --resource-group terraform-state-rg \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob

az storage container create \
  --name tfstate \
  --account-name tfstatebankapps
```

Then update workflow to include backend config in terraform init.

## Testing Locally

### 1. Validate Configuration
```bash
cd infrastructure
terraform init
terraform validate
```

### 2. Plan (Dry Run)
```bash
terraform plan -var-file=dev.tfvars
```

### 3. Apply (If Ready)
```bash
terraform apply -var-file=dev.tfvars
```

### 4. Check Outputs
```bash
terraform output
```

## Troubleshooting

### Issue: "No outputs found"
**Cause**: Trying to read outputs before infrastructure exists
**Solution**: Run `terraform apply` first, then `terraform output`

### Issue: Workflow fails at terraform apply
**Check**:
1. Azure credentials valid? `az account show`
2. Permissions correct? Contributor role on subscription
3. Quotas sufficient? Check subscription limits
4. Variable files correct? Check `dev.tfvars`

### Issue: Images fail to push to ACR
**Check**:
1. ACR created? Check Job 1 outputs
2. Logged into ACR? Check `az acr login` step
3. Maven build succeeded? Check build step logs

### Issue: Kubernetes deployment fails
**Check**:
1. AKS created? Check Job 1 outputs
2. Images pushed? Check Job 2 logs
3. Manifests valid? Check placeholder replacement step
4. AKS credentials? Check `aks-set-context` step

## Monitoring Workflow

### View Workflow Runs
https://github.com/uallknowmatt/aksreferenceimplementation/actions

### Check Individual Job
Click on workflow run → Click job name → Expand steps

### Download Logs
Workflow page → "..." menu → Download logs

### Terraform Logs
Look for these sections in "Terraform Apply" step:
- `Plan: X to add, Y to change, Z to destroy`
- `Apply complete! Resources: X added, Y changed, Z destroyed`

### Docker Build Logs
Look for these in "Build and push images" step:
- `Successfully built <image-id>`
- `The push refers to repository`
- `<tag>: digest: sha256:...`

### Kubernetes Deployment Logs
Look for these in "Wait for deployments" step:
- `deployment "customer-service" successfully rolled out`
- Output from `kubectl get pods`
- Output from `kubectl get services`

## Next Steps After Successful Run

1. **Get AKS Credentials Locally**:
```bash
az aks get-credentials \
  --resource-group <resource-group-from-output> \
  --name <aks-cluster-from-output>
```

2. **Verify Pods Running**:
```bash
kubectl get pods
kubectl get services
```

3. **Check Liquibase Migrations**:
```bash
kubectl logs deployment/customer-service | grep -i liquibase
```

4. **Access Services**:
```bash
kubectl get services
# Note external IPs and ports
```

5. **View Logs**:
```bash
kubectl logs -f deployment/customer-service
```

## Workflow Best Practices

✅ **DO**:
- Use job dependencies (`needs:`) to control execution order
- Save terraform plan and apply saved plan
- Validate terraform before applying
- Use descriptive job and step names
- Add informative echo statements
- Use job outputs to pass data between jobs
- Enable manual workflow trigger (`workflow_dispatch`)

❌ **DON'T**:
- Try to read outputs before creating infrastructure
- Run terraform apply without validation
- Skip terraform plan step
- Use hardcoded values instead of outputs
- Ignore job dependencies

## Files Modified

- `.github/workflows/aks-deploy.yml` - **NEW** Complete restructure
- `.github/workflows/aks-deploy-old.yml` - Backup of broken workflow

## Rollback Plan

If new workflow fails, restore old one:
```bash
mv .github/workflows/aks-deploy.yml .github/workflows/aks-deploy-broken.yml
mv .github/workflows/aks-deploy-old.yml .github/workflows/aks-deploy.yml
git add .github/workflows
git commit -m "Rollback to old workflow"
git push origin main
```

---

**Status**: ✅ **READY TO DEPLOY**

The workflow is now properly structured to:
1. Create infrastructure first
2. Build and push images using created ACR
3. Deploy to AKS using created cluster

Push to GitHub to trigger the workflow!
