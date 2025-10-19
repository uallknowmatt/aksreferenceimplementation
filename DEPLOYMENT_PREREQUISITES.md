# Azure Deployment Prerequisites

## ⚠️ IMPORTANT: Correct Order of Operations

**To avoid deployment failures, follow this exact order:**

1. ✅ **Create Service Principal** (for GitHub Actions authentication)
2. ✅ **Disable GitHub Actions temporarily** (prevent premature deployment)
3. ✅ **Run Terraform** to create Azure infrastructure
4. ✅ **Configure GitHub Secrets** with Terraform outputs
5. ✅ **Re-enable GitHub Actions**
6. ✅ **Push code** to trigger deployment

**Why this order?** If you push code before secrets are configured, the GitHub Actions workflow will fail because it can't authenticate to Azure or push to ACR.

---

## ✅ Completed Steps

1. **Liquibase Implementation** - ✅ Production-grade database migrations configured
2. **Dev Profiles** - ✅ All services configured for Azure PostgreSQL
3. **Kubernetes Manifests** - ✅ ConfigMaps, Secrets, Services, Deployments ready
4. **Terraform Configuration** - ✅ Infrastructure as Code validated
5. **GitHub Actions Workflow** - ✅ CI/CD pipeline configured

## ⚠️ Required: GitHub Secrets Configuration

The GitHub Actions workflow requires these secrets to be configured:

### Azure Container Registry (ACR)
- **ACR_LOGIN_SERVER** - Your ACR login server (e.g., `myacr.azurecr.io`)
- **ACR_USERNAME** - ACR admin username (or service principal app ID)
- **ACR_PASSWORD** - ACR admin password (or service principal password)

### Azure Kubernetes Service (AKS)
- **AKS_CLUSTER_NAME** - Name of your AKS cluster
- **AKS_RESOURCE_GROUP** - Azure resource group containing AKS

### Azure Authentication
- **AZURE_CREDENTIALS** - Service principal credentials in JSON format:
  ```json
  {
    "clientId": "<service-principal-app-id>",
    "clientSecret": "<service-principal-password>",
    "subscriptionId": "<azure-subscription-id>",
    "tenantId": "<azure-tenant-id>"
  }
  ```

### Azure Database for PostgreSQL
- **POSTGRES_HOST** - PostgreSQL server hostname (e.g., `mypostgres.postgres.database.azure.com`)
- **POSTGRES_USERNAME** - PostgreSQL admin username
- **POSTGRES_PASSWORD** - PostgreSQL admin password

### Managed Identity (Optional - for workload identity)
- **MANAGED_IDENTITY_CLIENT_ID** - Client ID of Azure Managed Identity (if using workload identity)

## 📋 Setup Instructions

### Step 1: Create Azure Service Principal FIRST

**⚠️ Do this BEFORE running Terraform or pushing code**

```bash
# Create service principal for GitHub Actions
az ad sp create-for-rbac --name "github-actions-aks" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP> \
  --sdk-auth

# This outputs JSON - copy the entire output for AZURE_CREDENTIALS secret
```

Save this output - you'll need it for GitHub Secrets.

### Step 2: Disable GitHub Actions Temporarily

**Important:** Prevent automatic deployment while setting up infrastructure:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Actions** → **General**
3. Under "Actions permissions", select **Disable actions**
4. Click **Save**

This prevents the workflow from running until infrastructure is ready.

### Step 3: Create Azure Resources with Terraform

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Create dev environment
terraform plan -var-file=dev.tfvars -out=dev.tfplan
terraform apply dev.tfplan

# Note the outputs - you'll need these for GitHub Secrets
terraform output
```

### Step 4: Get ACR Credentials

```bash
# Get ACR login server
az acr show --name <YOUR_ACR_NAME> --query loginServer --output tsv

# Enable admin user (if not already enabled)
az acr update --name <YOUR_ACR_NAME> --admin-enabled true

# Get ACR credentials
az acr credential show --name <YOUR_ACR_NAME>
```

### Step 5: Get PostgreSQL Connection Info

```bash
# Get PostgreSQL host
az postgres flexible-server show --name <POSTGRES_NAME> --resource-group <RG> \
  --query fullyQualifiedDomainName --output tsv

# PostgreSQL credentials were set during Terraform apply
# Check your terraform.tfvars or dev.tfvars for username/password
```

### Step 6: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each secret listed above
4. Paste the values obtained from previous steps

**Required Secrets:**
- ACR_LOGIN_SERVER (from Step 4)
- ACR_USERNAME (from Step 4)
- ACR_PASSWORD (from Step 4)
- AKS_CLUSTER_NAME (from Terraform output)
- AKS_RESOURCE_GROUP (from Terraform output)
- AZURE_CREDENTIALS (from Step 1)
- POSTGRES_HOST (from Step 5)
- POSTGRES_USERNAME (from your tfvars)
- POSTGRES_PASSWORD (from your tfvars)
- MANAGED_IDENTITY_CLIENT_ID (from Terraform output, optional)

### Step 7: Re-enable GitHub Actions

1. Go back to **Settings** → **Actions** → **General**
2. Under "Actions permissions", select **Allow all actions and reusable workflows**
3. Click **Save**

## 🚀 Deployment Workflow

Once infrastructure is created and secrets are configured:

1. **Verify all secrets are set**
   ```bash
   # Go to GitHub repo → Settings → Secrets → Actions
   # Confirm all 9-10 secrets are showing (values hidden)
   ```

2. **Push to main branch** - Triggers automatic deployment
   ```bash
   git push origin main
   # Or if already pushed, create empty commit to trigger:
   git commit --allow-empty -m "Trigger deployment"
   git push origin main
   ```

3. **Monitor GitHub Actions** - Watch deployment progress
   - Go to GitHub repo → Actions tab
   - View "Deploy to AKS" workflow
   - Check for successful build-and-push job
   - Check for successful deploy job

4. **Verify deployment** - Check pods in AKS
   ```bash
   az aks get-credentials --resource-group <RG> --name <AKS_NAME>
   kubectl get pods
   kubectl get services
   
   # Watch pods start up (Liquibase will run)
   kubectl logs -l app=customer-service -f
   ```

## ⚙️ Current Status

**Code Status**: ✅ Ready to deploy  
**Infrastructure**: ⏳ Awaiting Terraform apply  
**GitHub Secrets**: ⏳ Not configured  
**Deployment**: ⏳ Waiting for prerequisites  

## 🔧 Troubleshooting

### Workflow fails with "Input required: username"
- ACR_USERNAME secret is missing or empty
- Verify ACR admin is enabled: `az acr update --name <ACR> --admin-enabled true`
- Set ACR_USERNAME and ACR_PASSWORD secrets

### Cannot connect to PostgreSQL from pods
- Check firewall rules allow AKS subnet
- Verify POSTGRES_HOST, POSTGRES_USERNAME, POSTGRES_PASSWORD secrets
- Check ConfigMap environment variables are correct

### Liquibase fails during pod startup
- Check pod logs: `kubectl logs <pod-name>`
- Verify database exists and is accessible
- Ensure connection string format is correct

## 📖 Next Steps

1. **Run Terraform** to create Azure infrastructure
2. **Configure GitHub Secrets** with Terraform outputs
3. **Push code** to trigger deployment
4. **Monitor** pods and services
5. **Test** deployed services via ingress

---

**Note**: This deployment uses the **dev** profile, which expects:
- Azure PostgreSQL Flexible Server
- Separate databases: customerdb, documentdb, accountdb, notificationdb
- Liquibase migrations will run automatically on first pod startup
