# GitHub Secrets Setup Guide

This guide will help you configure the GitHub repository secrets required for automated deployment to Azure AKS.

## Prerequisites

Before you begin, make sure you have:
- Azure CLI installed and logged in (`az login`)
- An Azure subscription with necessary permissions
- Terraform infrastructure deployed (from the `infrastructure/` folder)
- Your GitHub repository: `uallknowmatt/aksreferenceimplementation`

## Required GitHub Secrets

You need to configure the following secrets in your GitHub repository:

### 1. Azure Authentication

**AZURE_CREDENTIALS**
- JSON output from Azure service principal
- Used for Azure login in GitHub Actions

### 2. Azure Container Registry (ACR)

**ACR_LOGIN_SERVER**
- Example: `myacr.azurecr.io`
- The full login server URL for your ACR

**ACR_NAME**
- Example: `myacr`
- The name of your Azure Container Registry

**ACR_USERNAME**
- The username for ACR authentication
- Usually the service principal client ID or ACR admin username

**ACR_PASSWORD**
- The password for ACR authentication
- Service principal secret or ACR admin password

### 3. Azure Kubernetes Service (AKS)

**AKS_CLUSTER_NAME**
- Example: `account-opening-aks-dev`
- The name of your AKS cluster

**AKS_RESOURCE_GROUP**
- Example: `account-opening-rg-dev`
- The resource group containing your AKS cluster

### 4. PostgreSQL Database

**POSTGRES_HOST**
- Example: `mypostgres.postgres.database.azure.com`
- The fully qualified hostname of your Azure PostgreSQL Flexible Server

**POSTGRES_USERNAME**
- Example: `dbadmin`
- The admin username for PostgreSQL

**POSTGRES_PASSWORD**
- The admin password for PostgreSQL
- This will be base64 encoded automatically by the workflow

### 5. Azure Managed Identity (Optional)

**MANAGED_IDENTITY_CLIENT_ID**
- The client ID of the managed identity (if using workload identity)
- Can be left as placeholder if not using workload identity

---

## Step-by-Step Setup

### Step 1: Deploy Infrastructure with Terraform

```powershell
cd infrastructure

# Initialize Terraform
terraform init

# Create a plan (review what will be created)
terraform plan -var-file="dev.tfvars" -out=tfplan

# Apply the plan (deploy resources)
terraform apply tfplan
```

### Step 2: Get Infrastructure Outputs

After Terraform completes, get the output values:

```powershell
# Get all outputs
terraform output

# Get specific values
$acrName = terraform output -raw acr_name
$acrLoginServer = terraform output -raw acr_login_server
$aksName = terraform output -raw aks_cluster_name
$aksRg = terraform output -raw aks_resource_group_name
$postgresHost = terraform output -raw postgres_fqdn
$postgresUser = terraform output -raw postgres_admin_username
$postgresPass = terraform output -raw postgres_admin_password
```

### Step 3: Create Azure Service Principal

Create a service principal for GitHub Actions:

```powershell
# Set variables
$subscriptionId = (az account show --query id -o tsv)
$resourceGroup = $aksRg

# Create service principal
az ad sp create-for-rbac `
  --name "github-actions-account-opening" `
  --role contributor `
  --scopes /subscriptions/$subscriptionId/resourceGroups/$resourceGroup `
  --sdk-auth
```

**Save the entire JSON output** - you'll use this for `AZURE_CREDENTIALS`.

### Step 4: Get ACR Credentials

#### Option A: Use Service Principal (Recommended)

```powershell
# Grant ACR push/pull permissions to the service principal
$spAppId = "<SERVICE_PRINCIPAL_APP_ID_FROM_STEP_3>"

az role assignment create `
  --assignee $spAppId `
  --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.ContainerRegistry/registries/$acrName `
  --role AcrPush

# Use service principal credentials
$acrUsername = $spAppId
$acrPassword = "<SERVICE_PRINCIPAL_SECRET_FROM_STEP_3>"
```

#### Option B: Use ACR Admin Account

```powershell
# Enable admin account (if not already enabled)
az acr update --name $acrName --admin-enabled true

# Get admin credentials
$acrCreds = az acr credential show --name $acrName | ConvertFrom-Json
$acrUsername = $acrCreds.username
$acrPassword = $acrCreds.passwords[0].value
```

### Step 5: Grant AKS Permissions to Service Principal

```powershell
# Grant AKS permissions to the service principal
$spAppId = "<SERVICE_PRINCIPAL_APP_ID>"

az role assignment create `
  --assignee $spAppId `
  --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.ContainerService/managedClusters/$aksName `
  --role "Azure Kubernetes Service Cluster User Role"
```

### Step 6: Add Secrets to GitHub

Go to your GitHub repository:
1. Navigate to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each secret:

```
Name: AZURE_CREDENTIALS
Value: <ENTIRE_JSON_OUTPUT_FROM_STEP_3>

Name: ACR_LOGIN_SERVER
Value: <ACR_LOGIN_SERVER>

Name: ACR_NAME
Value: <ACR_NAME>

Name: ACR_USERNAME
Value: <ACR_USERNAME>

Name: ACR_PASSWORD
Value: <ACR_PASSWORD>

Name: AKS_CLUSTER_NAME
Value: <AKS_CLUSTER_NAME>

Name: AKS_RESOURCE_GROUP
Value: <RESOURCE_GROUP_NAME>

Name: POSTGRES_HOST
Value: <POSTGRES_FQDN>

Name: POSTGRES_USERNAME
Value: <POSTGRES_ADMIN_USERNAME>

Name: POSTGRES_PASSWORD
Value: <POSTGRES_ADMIN_PASSWORD>

Name: MANAGED_IDENTITY_CLIENT_ID
Value: <LEAVE_EMPTY_OR_ADD_IF_USING_WORKLOAD_IDENTITY>
```

### Step 7: Verify Secrets

In your repository, verify all secrets are configured:
- Go to **Settings** → **Secrets and variables** → **Actions**
- You should see all 11 secrets listed

---

## Deployment Process

Once secrets are configured, deployment is automatic:

1. **Commit and Push Changes**
   ```powershell
   git add .
   git commit -m "Add dev profile and updated k8s configurations"
   git push origin main
   ```

2. **Monitor GitHub Actions**
   - Go to: https://github.com/uallknowmatt/aksreferenceimplementation/actions
   - Click on the running workflow
   - Watch each step complete

3. **Verify Deployment**
   ```powershell
   # Connect to AKS cluster
   az aks get-credentials --resource-group $aksRg --name $aksName

   # Check pods
   kubectl get pods

   # Check services (get external IPs)
   kubectl get services

   # Check logs
   kubectl logs -l app=customer-service
   kubectl logs -l app=document-service
   kubectl logs -l app=account-service
   kubectl logs -l app=notification-service
   ```

---

## Troubleshooting

### Issue: "Error: InvalidAuthenticationTokenTenant"
**Solution:** Make sure the service principal has correct permissions for the subscription and resource group.

### Issue: "unauthorized: authentication required" (Docker push)
**Solution:** Verify ACR credentials are correct and the service principal has AcrPush role.

### Issue: "error: You must be logged in to the server (Unauthorized)"
**Solution:** Service principal needs "Azure Kubernetes Service Cluster User Role" on the AKS cluster.

### Issue: Pods stuck in "ImagePullBackOff"
**Solution:** 
1. Check ACR is accessible from AKS
2. Verify image names and tags in deployment files
3. Ensure AKS has permissions to pull from ACR

### Issue: Pods crash with database connection errors
**Solution:**
1. Verify PostgreSQL firewall rules allow AKS traffic
2. Check POSTGRES_HOST, POSTGRES_USERNAME, POSTGRES_PASSWORD secrets
3. Verify databases exist in PostgreSQL server

---

## Quick Reference - PowerShell Commands

```powershell
# Get Terraform outputs
cd infrastructure
terraform output

# Get AKS credentials
az aks get-credentials --resource-group <RG_NAME> --name <AKS_NAME>

# Check deployment status
kubectl get all

# Get service external IPs
kubectl get services

# View pod logs
kubectl logs <POD_NAME>

# Restart deployment
kubectl rollout restart deployment/<SERVICE_NAME>

# Delete and redeploy
kubectl delete -f k8s/
kubectl apply -f k8s/
```

---

## Security Best Practices

1. **Use Service Principal (not admin credentials)** for production
2. **Rotate secrets regularly** (every 90 days recommended)
3. **Use Azure Key Vault** to store secrets (advanced setup)
4. **Enable RBAC** on AKS cluster
5. **Use Workload Identity** instead of service principals (Azure recommended)
6. **Limit service principal scope** to specific resource groups
7. **Enable audit logging** on AKS and ACR

---

## Next Steps After Deployment

1. **Configure Custom Domain** - Point your domain to the service LoadBalancer IPs
2. **Setup TLS/SSL** - Add ingress controller with Let's Encrypt certificates
3. **Configure Monitoring** - Setup Azure Monitor, Application Insights, and Log Analytics
4. **Setup Alerts** - Configure alerts for pod failures, high CPU/memory usage
5. **Deploy Frontend** - Deploy React frontend to Azure Static Web Apps or AKS
6. **Configure Auto-Scaling** - Setup Horizontal Pod Autoscaler (HPA)
7. **Implement CI/CD for Dev/Staging/Prod** - Create separate workflows for each environment

---

## Estimated Costs

**Monthly costs for this deployment (approximate):**

- AKS (2 nodes, Standard_D2s_v3): $140
- PostgreSQL Flexible Server (Burstable B1ms): $15
- Azure Container Registry (Basic): $5
- Load Balancers (4 services): $20
- Egress traffic: $5
- **Total: ~$185/month**

*Costs may vary based on region and actual usage*

---

## Support

If you encounter issues:
1. Check GitHub Actions logs for detailed error messages
2. Review AKS pod logs: `kubectl logs <pod-name>`
3. Check Azure Portal for resource status
4. Review this guide's troubleshooting section
