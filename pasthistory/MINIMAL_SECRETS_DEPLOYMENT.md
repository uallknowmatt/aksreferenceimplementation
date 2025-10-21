# 🎯 MINIMAL SECRETS DEPLOYMENT - ONLY 1 SECRET NEEDED!

## 🚀 Revolutionary Approach

**Before:** 9 GitHub secrets to manage  
**After:** **ONLY 1 SECRET!** 🎉

All infrastructure values (ACR, AKS, PostgreSQL) are fetched **dynamically** from Terraform state at runtime. No more hardcoded secrets!

---

## ✨ What's Changed

### ❌ Old Approach (9 Secrets)
```
ACR_LOGIN_SERVER       ← Hardcoded
ACR_USERNAME           ← Hardcoded
ACR_PASSWORD           ← Hardcoded, needs rotation
AKS_CLUSTER_NAME       ← Hardcoded
AKS_RESOURCE_GROUP     ← Hardcoded
POSTGRES_HOST          ← Hardcoded
POSTGRES_USERNAME      ← Hardcoded
POSTGRES_PASSWORD      ← Hardcoded, needs rotation
MANAGED_IDENTITY_CLIENT_ID ← Hardcoded
```

### ✅ New Approach (1 Secret!)
```
AZURE_CREDENTIALS      ← Only secret needed!
```

Everything else is fetched automatically:
- ACR → `terraform output -raw acr_login_server`
- AKS → `terraform output -raw aks_cluster_name`
- PostgreSQL → **Passwordless via Managed Identity!**
- Workload Identity → `terraform output -raw workload_identity_client_id`

---

## 🏗️ Architecture

### GitHub Actions Workflow Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. GitHub Actions starts                                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Login to Azure with AZURE_CREDENTIALS (only secret!)     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Run: terraform init (in infrastructure/ dir)             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Fetch dynamic values:                                    │
│    - terraform output -raw acr_login_server                 │
│    - terraform output -raw acr_name                         │
│    - terraform output -raw aks_cluster_name                 │
│    - terraform output -raw aks_resource_group_name          │
│    - terraform output -raw postgres_fqdn                    │
│    - terraform output -raw workload_identity_client_id      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Use fetched values for:                                  │
│    - ACR login (az acr login)                               │
│    - Docker push                                            │
│    - K8s deployment                                         │
│    - ConfigMap/Secret generation                            │
└─────────────────────────────────────────────────────────────┘
```

### Application Authentication to PostgreSQL

```
┌─────────────────────────────────────────────────────────────┐
│ Pod starts in AKS                                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Pod has Workload Identity annotation                        │
│ (azure.workload.identity/client-id = xxx)                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Pod requests token from Azure AD via Workload Identity      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Pod connects to PostgreSQL using Azure AD token             │
│ NO PASSWORD NEEDED! 🎉                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Deployment Steps

### Step 1: Disable GitHub Actions (Temporarily)

1. Go to GitHub repo → **Settings** → **Actions** → **General**
2. Select **Disable actions**
3. Click **Save**

### Step 2: Deploy Infrastructure with Terraform

```bash
cd infrastructure

# Login to Azure
az login

# Initialize Terraform
terraform init

# Apply infrastructure (creates EVERYTHING)
terraform apply -var-file=dev.tfvars
```

**What gets created:**
- ✅ Resource Group
- ✅ AKS Cluster (with Workload Identity enabled)
- ✅ Azure Container Registry
- ✅ PostgreSQL Flexible Server (Azure AD auth enabled)
- ✅ Service Principal for GitHub Actions
- ✅ Managed Identity for application pods
- ✅ All role assignments
- ✅ Federated credentials for workload identity

### Step 3: Get the ONE Secret

```bash
# Get the service principal JSON
terraform output -raw azure_credentials_json
```

**Output example:**
```json
{"clientId":"xxx-xxx-xxx","clientSecret":"xxx","subscriptionId":"xxx","tenantId":"xxx"}
```

### Step 4: Add Secret to GitHub

1. Go to https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
2. Click **New repository secret**
3. Name: `AZURE_CREDENTIALS`
4. Value: Paste the entire JSON from Step 3
5. Click **Add secret**

**That's it! Only 1 secret!** 🎉

### Step 5: Re-enable GitHub Actions

1. Go back to **Settings** → **Actions** → **General**
2. Select **Allow all actions and reusable workflows**
3. Click **Save**

### Step 6: Deploy!

```bash
# Push code or create empty commit
git commit --allow-empty -m "Deploy with minimal secrets approach"
git push origin main
```

Watch the magic happen:
- Workflow fetches all values from Terraform
- Builds and pushes Docker images
- Deploys to AKS
- Pods use Workload Identity for PostgreSQL (no passwords!)

---

## 🔍 How It Works: Technical Details

### 1. GitHub Actions Workflow Changes

**Old workflow:**
```yaml
env:
  REGISTRY: ${{ secrets.ACR_LOGIN_SERVER }}  # ❌ Hardcoded
  AKS_CLUSTER: ${{ secrets.AKS_CLUSTER_NAME }}  # ❌ Hardcoded
  AKS_RG: ${{ secrets.AKS_RESOURCE_GROUP }}  # ❌ Hardcoded
```

**New workflow:**
```yaml
steps:
  - name: Get Terraform Outputs
    run: |
      terraform init
      ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)  # ✅ Dynamic!
      AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name)  # ✅ Dynamic!
      AKS_RESOURCE_GROUP=$(terraform output -raw aks_resource_group_name)  # ✅ Dynamic!
      echo "acr_login_server=$ACR_LOGIN_SERVER" >> $GITHUB_OUTPUT
```

### 2. ACR Authentication

**Old approach:**
```yaml
- name: Log in to Azure Container Registry
  uses: azure/docker-login@v1
  with:
    login-server: ${{ secrets.ACR_LOGIN_SERVER }}  # ❌ Hardcoded
    username: ${{ secrets.ACR_USERNAME }}  # ❌ Hardcoded
    password: ${{ secrets.ACR_PASSWORD }}  # ❌ Hardcoded
```

**New approach:**
```yaml
- name: Log in to Azure Container Registry
  run: |
    az acr login --name ${{ steps.terraform-outputs.outputs.acr_name }}  # ✅ Uses service principal already logged in!
```

**Why this works:**
- GitHub Actions is already logged in to Azure via AZURE_CREDENTIALS
- Service principal has AcrPush role assigned (via Terraform)
- `az acr login` uses the active Azure session
- No separate credentials needed!

### 3. PostgreSQL Passwordless Authentication

**Infrastructure setup (Terraform):**
```terraform
# Create managed identity for pods
resource "azurerm_user_assigned_identity" "workload_identity" {
  name = "account-opening-workload-identity-dev"
}

# Federated credential links Kubernetes service account to Azure identity
resource "azurerm_federated_identity_credential" "workload_identity" {
  for_each = ["customer-service", "document-service", "account-service", "notification-service"]
  
  parent_id = azurerm_user_assigned_identity.workload_identity.id
  issuer    = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject   = "system:serviceaccount:default:${each.key}"
  audience  = ["api://AzureADTokenExchange"]
}
```

**Kubernetes deployment (example):**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: customer-service
  annotations:
    azure.workload.identity/client-id: "<WORKLOAD_IDENTITY_CLIENT_ID>"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: customer-service
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"  # ← Enable workload identity
    spec:
      serviceAccountName: customer-service  # ← Use service account with identity
      containers:
      - name: customer-service
        env:
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:postgresql://<POSTGRES_HOST>:5432/customerdb"
        - name: SPRING_DATASOURCE_AZURE_AUTHENTICATION
          value: "AZURE_IDENTITY"  # ← Use Azure AD authentication!
```

**Application configuration (Spring Boot):**
```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:postgresql://${POSTGRES_HOST}:5432/customerdb
    azure:
      authentication: AZURE_IDENTITY  # ← Passwordless!
```

**No passwords anywhere!** The pod's managed identity is used to get an Azure AD token, which PostgreSQL accepts for authentication.

---

## 🎯 Benefits

### 🔐 Security

1. **Fewer Secrets = Smaller Attack Surface**
   - Down from 9 secrets to 1
   - 89% reduction in secret management overhead!

2. **No Password Rotation**
   - Database passwords → Gone (using Azure AD)
   - ACR passwords → Not stored (using service principal)
   - Only service principal secret needs rotation (1 year validity)

3. **Least Privilege**
   - Workload identity has minimal permissions
   - Each service can have different permissions (if needed)

4. **No Hardcoded Credentials**
   - Everything fetched dynamically
   - Terraform state is source of truth

### 🚀 Operations

1. **Simplified Setup**
   - 1 secret to configure vs 9
   - Less documentation to maintain
   - Fewer opportunities for errors

2. **Dynamic Infrastructure**
   - Rename ACR? No workflow change needed
   - Change PostgreSQL host? No workflow change needed
   - Move to different region? No workflow change needed

3. **Environment Parity**
   - Same workflow for dev/staging/prod
   - Just use different Terraform workspaces
   - No environment-specific secrets

4. **Easier Troubleshooting**
   - Values visible in workflow logs
   - Easy to verify what's being used
   - Terraform state shows configuration

### 🔄 Maintenance

1. **Single Source of Truth**
   - Terraform manages infrastructure
   - Workflow fetches current state
   - No drift between secrets and reality

2. **Automated Updates**
   - Infrastructure changes automatically propagated
   - No manual secret updates
   - Workflow always uses latest values

3. **Team Collaboration**
   - Anyone with Terraform access can see values
   - No "who has the password?" questions
   - Consistent across team members

---

## 🆚 Comparison

| Aspect | Old Approach (9 Secrets) | New Approach (1 Secret) |
|--------|--------------------------|-------------------------|
| **Secrets to manage** | 9 | 1 | 
| **Secret rotation** | Regular (passwords) | Once per year (SP) |
| **Setup complexity** | High | Low |
| **Infrastructure changes** | Update secrets manually | Automatic via Terraform |
| **Security** | Passwords in GitHub | Passwordless where possible |
| **Debugging** | Hard (secrets hidden) | Easy (values in logs) |
| **Team onboarding** | Complex documentation | Simple setup |
| **Environment setup** | Different secrets per env | Same secret, different Terraform state |
| **Maintenance** | High overhead | Minimal overhead |

---

## 🔄 Updating Infrastructure

### Scenario: Change ACR Name

**Old approach:**
```bash
# 1. Update Terraform
terraform apply

# 2. Get new ACR name
az acr show ...

# 3. Update GitHub secret: ACR_LOGIN_SERVER
# 4. Update GitHub secret: ACR_USERNAME  
# 5. Update GitHub secret: ACR_PASSWORD
```

**New approach:**
```bash
# 1. Update Terraform
terraform apply

# 2. Done! ✅
# Next deployment automatically uses new values
```

### Scenario: Rotate Service Principal Secret

```bash
cd infrastructure

# Terraform detects secret is expiring and rotates it
terraform apply

# Get new JSON
terraform output -raw azure_credentials_json

# Update GitHub secret AZURE_CREDENTIALS
# Done! ✅
```

---

## 🧪 Testing

### Verify Terraform Outputs

```bash
cd infrastructure

# See all outputs
terraform output

# Test each output
terraform output -raw acr_login_server
terraform output -raw acr_name
terraform output -raw aks_cluster_name
terraform output -raw aks_resource_group_name
terraform output -raw postgres_fqdn
terraform output -raw workload_identity_client_id
terraform output -raw azure_credentials_json

# See the beautiful summary
terraform output github_secrets_summary
```

### Verify Workload Identity

```bash
# Get AKS credentials
az aks get-credentials --resource-group <RG> --name <AKS_NAME>

# Check service accounts
kubectl get serviceaccounts

# Check pod identity
kubectl describe pod <pod-name> | grep azure.workload.identity

# Test database connection from pod
kubectl exec -it <pod-name> -- /bin/sh
# Inside pod:
curl https://<POSTGRES_HOST>:5432
# Should connect successfully
```

---

## 📝 Migration Guide

If you already have the old approach with 9 secrets:

### Step 1: Update Infrastructure

```bash
cd infrastructure
git pull  # Get latest Terraform changes
terraform init
terraform apply -var-file=dev.tfvars
```

### Step 2: Update Workflow

The workflow file (`.github/workflows/aks-deploy.yml`) is already updated. Just git pull:

```bash
git pull origin main
```

### Step 3: Clean Up Old Secrets

Keep:
- ✅ `AZURE_CREDENTIALS`

Delete:
- ❌ `ACR_LOGIN_SERVER`
- ❌ `ACR_USERNAME`
- ❌ `ACR_PASSWORD`
- ❌ `AKS_CLUSTER_NAME`
- ❌ `AKS_RESOURCE_GROUP`
- ❌ `POSTGRES_HOST`
- ❌ `POSTGRES_USERNAME`
- ❌ `POSTGRES_PASSWORD`
- ❌ `MANAGED_IDENTITY_CLIENT_ID`

### Step 4: Test

```bash
git commit --allow-empty -m "Test minimal secrets approach"
git push origin main
```

Watch workflow succeed with only 1 secret! 🎉

---

## ✅ Checklist

Setup checklist:

- [ ] Terraform updated with workload identity support
- [ ] AKS has OIDC and workload identity enabled
- [ ] Service principal created by Terraform
- [ ] Managed identity created for pods
- [ ] Federated credentials configured
- [ ] PostgreSQL configured for Azure AD authentication
- [ ] Workflow updated to fetch Terraform outputs
- [ ] Only AZURE_CREDENTIALS secret in GitHub
- [ ] Old secrets deleted from GitHub
- [ ] Deployment tested end-to-end
- [ ] Pods can connect to PostgreSQL without passwords
- [ ] Documentation updated

---

## 🎉 Summary

**You asked:** "can it be referenced automatically in code... i should only need the azure subscription id to be stored in github secrets"

**Answer:** YES! ✅ Even better - you only need the service principal credentials (which includes subscription ID). Everything else is fetched dynamically from Terraform state!

**Key innovations:**
1. **Terraform outputs** → Source of truth for infrastructure values
2. **Workload Identity** → Passwordless database authentication
3. **Service Principal** → Single credential for GitHub Actions
4. **Dynamic fetching** → No hardcoded values

**Result:**
- 9 secrets → 1 secret (89% reduction!)
- More secure (fewer secrets, passwordless DB)
- Easier to maintain (Terraform is source of truth)
- Environment agnostic (same secret, different Terraform state)

---

**Your deployment is now truly automated and secure! 🚀🔐**
