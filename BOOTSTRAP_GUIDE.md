# Bootstrap Guide - Initial Setup (One-Time Only!)

## 🎯 Goal

Get the **AZURE_CREDENTIALS** secret into GitHub for the very first deployment.

**This is a ONE-TIME manual process.** After this, everything is automated!

---

## 📋 The Chicken-and-Egg Problem

- GitHub Actions needs `AZURE_CREDENTIALS` to run Terraform
- But Terraform creates the service principal that goes into `AZURE_CREDENTIALS`
- So how do we get started? 🤔

**Solution:** Use a **bootstrap service principal** to run Terraform the first time locally.

---

## 🚀 Step-by-Step Bootstrap Process

### Prerequisites

- ✅ Azure CLI installed: `az --version`
- ✅ Terraform installed: `terraform --version`
- ✅ Azure subscription with Owner or User Access Administrator permissions
- ✅ PowerShell (Windows) or Bash (Linux/Mac)

---

### Step 1: Login to Azure Locally

```powershell
# Login to your Azure subscription
az login

# Verify you're in the correct subscription
az account show

# If not, set the correct subscription
az account set --subscription "<your-subscription-id>"
```

---

### Step 2: Create Bootstrap Service Principal (Manual - One Time!)

This service principal is **only for the initial Terraform run**. It won't be used after setup.

```powershell
# Create a service principal for local Terraform use
az ad sp create-for-rbac `
  --name "terraform-bootstrap-sp" `
  --role "Contributor" `
  --scopes "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
```

**Output example:**
```json
{
  "appId": "12345678-1234-1234-1234-123456789abc",
  "displayName": "terraform-bootstrap-sp",
  "password": "super-secret-password-xyz",
  "tenant": "87654321-4321-4321-4321-cba987654321"
}
```

**Save this output!** You'll need it in the next step.

---

### Step 3: Set Environment Variables for Terraform

**Windows PowerShell:**

```powershell
cd c:\genaiexperiments\accountopening\infrastructure

# Set environment variables (use values from Step 2)
$env:ARM_CLIENT_ID = "12345678-1234-1234-1234-123456789abc"
$env:ARM_CLIENT_SECRET = "super-secret-password-xyz"
$env:ARM_SUBSCRIPTION_ID = "<your-subscription-id>"
$env:ARM_TENANT_ID = "87654321-4321-4321-4321-cba987654321"

# Verify
echo $env:ARM_CLIENT_ID
```

**Linux/Mac Bash:**

```bash
cd infrastructure

export ARM_CLIENT_ID="12345678-1234-1234-1234-123456789abc"
export ARM_CLIENT_SECRET="super-secret-password-xyz"
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
export ARM_TENANT_ID="87654321-4321-4321-4321-cba987654321"

# Verify
echo $ARM_CLIENT_ID
```

---

### Step 4: Run Terraform Locally (Creates GitHub Actions Service Principal!)

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Plan - see what will be created (15+ resources!)
terraform plan -var-file=dev.tfvars

# Apply - create ALL infrastructure including the GitHub Actions service principal
terraform apply -var-file=dev.tfvars
```

**What happens:**
- ✅ Terraform uses the **bootstrap service principal** to authenticate
- ✅ Creates resource group, ACR, AKS, PostgreSQL, networking
- ✅ **Creates a NEW service principal** specifically for GitHub Actions
- ✅ Outputs the `azure_credentials_json` for GitHub

**Duration:** 10-15 minutes

---

### Step 5: Get the GitHub Actions Credentials

After Terraform completes, get the **real** service principal credentials:

```bash
cd infrastructure

# Get the service principal JSON for GitHub
terraform output -raw azure_credentials_json
```

**Output example:**
```json
{"clientId":"abcd-1234-xyz","clientSecret":"github-sp-secret","subscriptionId":"sub-123","tenantId":"tenant-456"}
```

**Copy this entire JSON!** This is what goes into GitHub.

---

### Step 6: Add AZURE_CREDENTIALS to GitHub

1. Go to your repository settings:
   ```
   https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
   ```

2. Click **New repository secret**

3. Configure the secret:
   - **Name:** `AZURE_CREDENTIALS`
   - **Value:** Paste the entire JSON from Step 5
   - Click **Add secret**

---

### Step 7: Verify Terraform Outputs (Optional)

```bash
cd infrastructure

# See the beautiful summary
terraform output github_secrets_summary

# Verify individual outputs
terraform output acr_login_server
terraform output aks_cluster_name
terraform output postgres_fqdn
```

---

### Step 8: Clean Up Bootstrap Service Principal (Optional but Recommended)

The bootstrap service principal is **no longer needed** after Terraform runs. You can delete it:

```powershell
# List service principals to find the app ID
az ad sp list --display-name "terraform-bootstrap-sp" --query "[].{appId:appId, displayName:displayName}"

# Delete the bootstrap service principal
az ad sp delete --id "<bootstrap-sp-app-id>"
```

**Note:** Keep it if you want to run `terraform apply` locally again in the future. Otherwise, GitHub Actions will handle all deployments.

---

### Step 9: Test GitHub Actions Deployment

Now that `AZURE_CREDENTIALS` is configured, test the automated deployment:

```bash
cd c:\genaiexperiments\accountopening

# Push code to trigger deployment
git add -A
git commit -m "Initial deployment with automated credentials"
git push origin main
```

Watch the deployment:
- Go to https://github.com/uallknowmatt/aksreferenceimplementation/actions
- The workflow should run successfully using `AZURE_CREDENTIALS`

---

## 🔄 What Happens After Bootstrap?

### From Now On:

1. ✅ GitHub Actions uses `AZURE_CREDENTIALS` for all deployments
2. ✅ No more local Terraform runs needed (unless you want to)
3. ✅ Infrastructure changes via pull requests
4. ✅ Automated credential rotation (if configured)
5. ✅ Zero manual secret management

### The Two Service Principals:

| Service Principal | Purpose | Where Used | Created By | Lifespan |
|-------------------|---------|------------|------------|----------|
| **Bootstrap SP** | Initial Terraform run | Local machine only | Manual (`az ad sp create-for-rbac`) | Delete after bootstrap |
| **GitHub Actions SP** | All future deployments | GitHub Actions workflows | Terraform (automated!) | Permanent (auto-rotated) |

---

## 🎉 Summary

### What You Did Manually (Once):

1. ✅ Created bootstrap service principal (`az ad sp create-for-rbac`)
2. ✅ Ran Terraform locally with bootstrap credentials
3. ✅ Added `AZURE_CREDENTIALS` to GitHub secrets

### What's Now Automated (Forever):

1. ✅ GitHub Actions deploys using `AZURE_CREDENTIALS`
2. ✅ Infrastructure updates via Terraform in workflows
3. ✅ Service principal rotation (if configured)
4. ✅ Zero manual credential management

---

## 🔧 Troubleshooting

### Error: "Insufficient privileges to complete the operation"

**Problem:** Bootstrap service principal doesn't have permissions to create other service principals

**Solution:** Grant additional permissions:

```powershell
# Get your subscription ID
$subscriptionId = (az account show --query id -o tsv)

# Grant User Access Administrator role (needed to create service principals)
az role assignment create `
  --assignee "<bootstrap-sp-app-id>" `
  --role "User Access Administrator" `
  --scope "/subscriptions/$subscriptionId"
```

### Error: "The client does not have authorization to perform action"

**Problem:** Bootstrap SP needs permissions to create Azure AD applications

**Solution:** Use an account with at least **Application Administrator** role in Azure AD, or run the initial `terraform apply` with your personal Azure login:

```powershell
# Option 1: Login with your personal account (has higher permissions)
az login

# Don't set ARM_CLIENT_ID/ARM_CLIENT_SECRET environment variables
# Terraform will use your Azure CLI login automatically

cd infrastructure
terraform apply -var-file=dev.tfvars
```

### Error: "Backend configuration changed"

**Problem:** Terraform state backend not initialized

**Solution:**

```bash
cd infrastructure
rm -rf .terraform
terraform init
```

### Can I avoid the bootstrap process entirely?

**Yes! Alternative: Use Azure Cloud Shell**

1. Open https://shell.azure.com
2. Your Azure CLI is already authenticated with full permissions
3. Clone your repo and run Terraform:
   ```bash
   git clone https://github.com/uallknowmatt/aksreferenceimplementation.git
   cd aksreferenceimplementation/infrastructure
   terraform init
   terraform apply -var-file=dev.tfvars
   ```
4. Get the output: `terraform output -raw azure_credentials_json`
5. Add to GitHub secrets

**This skips the bootstrap service principal entirely!** ☁️

---

## 📖 Next Steps

After completing this bootstrap:

1. ✅ Go to **DEPLOYMENT_PREREQUISITES.md** for the complete deployment guide
2. ✅ Configure automated rotation: **AUTOMATED_CREDENTIAL_ROTATION.md**
3. ✅ Deploy your application via GitHub Actions
4. ✅ Never worry about secrets again! 🎉

---

**Remember:** This manual process is **ONLY for the initial setup**. After this, everything is automated through GitHub Actions! 🚀
