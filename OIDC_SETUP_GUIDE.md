# GitHub OIDC Setup Guide - Zero Secrets! 🎉

## 🎯 Revolutionary Approach: OpenID Connect (OIDC)

**This is THE BEST way to authenticate GitHub Actions to Azure!**

### Why OIDC is Superior

| Aspect | Traditional (Service Principal Secret) | **OIDC (Recommended)** |
|--------|---------------------------------------|------------------------|
| **Secrets stored** | 1 long-lived secret (clientSecret) | **ZERO secrets!** 🎉 |
| **Security risk** | High (secret can leak) | **Very low** (no secrets) |
| **Token lifetime** | 1 year (must rotate) | **Minutes** (auto-expires) |
| **Rotation needed** | Yes (complex automation) | **NO!** (GitHub handles it) |
| **Setup complexity** | Medium | **Same (one-time)** |
| **GitHub secrets** | 4 values (including secret) | **3 IDs only** (no secrets) |
| **Attack surface** | Large (persistent creds) | **Minimal** (ephemeral tokens) |
| **Audit trail** | Limited | **Complete** (every token logged) |
| **Cost** | Free | **Free** |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Actions Workflow                  │
│                                                              │
│  1. Workflow starts                                         │
│  2. GitHub generates OIDC token (JWT)                       │
│     - Contains: repo, branch, commit SHA, workflow         │
│     - Signed by GitHub                                      │
│     - Expires in minutes                                    │
│                                                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ OIDC token
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                         Azure AD                             │
│                                                              │
│  3. Verifies token signature (from GitHub)                  │
│  4. Checks federated credential trust:                      │
│     - Correct repository?                                   │
│     - Correct branch?                                       │
│     - Allowed by trust policy?                              │
│  5. Issues Azure AD access token                            │
│                                                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ Azure AD token
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      Azure Resources                         │
│                                                              │
│  6. GitHub Actions uses Azure AD token to:                  │
│     - Push to ACR                                           │
│     - Deploy to AKS                                         │
│     - Read Terraform outputs                                │
│     - Manage all infrastructure                             │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Key Point:** GitHub generates a NEW token for EVERY workflow run. No long-lived secrets anywhere!

---

## 📋 One-Time Setup (Still Need Bootstrap, But Better!)

### Why You Still Need Manual Setup (Once)

Even with OIDC, you have the **chicken-and-egg problem**:
- Terraform needs to create the Entra ID application
- But Terraform runs in GitHub Actions
- But GitHub Actions needs Azure credentials
- But those credentials come from Terraform!

**Solution:** One-time manual setup, then fully automated forever.

### The Process

```
┌──────────────────────────────────────────────────────────────┐
│                    ONE-TIME MANUAL SETUP                      │
└──────────────────────────────────────────────────────────────┘
         │
         ▼
    1. Login to Azure CLI locally
    2. Run Terraform locally (creates app + federated credential)
    3. Add 3 IDs to GitHub (no secrets!)
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│              FULLY AUTOMATED FOREVER AFTER                    │
│                                                               │
│  • Every workflow run gets fresh OIDC token                  │
│  • Azure validates token automatically                       │
│  • No secret rotation needed                                 │
│  • Zero maintenance                                          │
└──────────────────────────────────────────────────────────────┘
```

---

## 🚀 Step-by-Step Setup

### Step 1: Login to Azure Locally

```powershell
# Login to Azure
az login

# Verify you're in the correct subscription
az account show

# Set subscription if needed
az account set --subscription "<your-subscription-id>"
```

### Step 2: Run Terraform Locally (Creates OIDC Setup)

```powershell
cd c:\genaiexperiments\accountopening\infrastructure

# Initialize Terraform
terraform init

# Create infrastructure (including OIDC federated credential)
terraform apply -var-file=dev.tfvars
```

**What Terraform creates for OIDC:**
- ✅ Entra ID Application (GitHub Actions App)
- ✅ Service Principal (from application)
- ✅ **Federated Identity Credential** (trusts GitHub OIDC)
- ✅ Role assignments (Contributor, AcrPush, AKS Admin)
- ✅ Trust policy (repo: `uallknowmatt/aksreferenceimplementation`, branch: `main`)
- ✅ All Azure infrastructure (ACR, AKS, PostgreSQL, etc.)

### Step 3: Get the 3 IDs (NO SECRETS!)

After Terraform completes:

```powershell
# Get the summary
terraform output github_secrets_oidc_summary

# Get individual values
terraform output -raw github_oidc_client_id
terraform output -raw azure_tenant_id
terraform output -raw azure_subscription_id
```

**Example output:**
```
AZURE_CLIENT_ID: abc123-def456-ghi789
AZURE_TENANT_ID: tenant-id-xyz
AZURE_SUBSCRIPTION_ID: sub-id-123
```

**IMPORTANT:** These are **IDs, not secrets!** They're safe to share and can even be public.

### Step 4: Add to GitHub (3 Values, Zero Secrets!)

1. Go to https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
2. Click **New repository secret**
3. Add these 3 values:

| Secret Name | Value | Is it a secret? |
|-------------|-------|-----------------|
| `AZURE_CLIENT_ID` | From terraform output | ❌ NO (just an ID) |
| `AZURE_TENANT_ID` | From terraform output | ❌ NO (just an ID) |
| `AZURE_SUBSCRIPTION_ID` | From terraform output | ❌ NO (just an ID) |

**That's it!** No `clientSecret`, no passwords, no long-lived credentials!

---

## 🔍 How It Works in GitHub Actions

### Workflow Configuration

```yaml
name: Deploy to Azure with OIDC

on: [push]

permissions:
  id-token: write  # Required to request OIDC token
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Azure Login with OIDC
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          # NO client-secret needed! ✅

      - name: Run Azure commands
        run: |
          az account show
          az acr list
          az aks list
```

### What Happens Behind the Scenes

```
1. Workflow starts
   ↓
2. GitHub generates OIDC token (JWT):
   {
     "iss": "https://token.actions.githubusercontent.com",
     "sub": "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main",
     "aud": "api://AzureADTokenExchange",
     "exp": 1697654321,  // Expires in minutes!
     "repository": "uallknowmatt/aksreferenceimplementation",
     "ref": "refs/heads/main",
     ...
   }
   ↓
3. azure/login action sends token to Azure AD
   ↓
4. Azure AD verifies:
   - Token signature (from GitHub)
   - Token not expired
   - Repository matches (uallknowmatt/aksreferenceimplementation)
   - Branch matches (main)
   - Trust policy allows this
   ↓
5. Azure AD issues short-lived access token
   ↓
6. Workflow uses access token to manage Azure resources
   ↓
7. Token expires after workflow completes
```

**Key Security Features:**
- ✅ Token is single-use (can't replay)
- ✅ Token expires in minutes
- ✅ Token tied to specific repo/branch
- ✅ Token signed by GitHub (can't forge)
- ✅ Azure validates EVERYTHING

---

## 🔐 Security Comparison

### Scenario: Attacker Gets GitHub Secrets

**With Service Principal Secret:**
```
❌ Attacker has clientSecret
❌ Valid for 1 year
❌ Can use from anywhere
❌ Full access to Azure subscription
❌ Damage window: 1 year (until rotation)
```

**With OIDC (IDs only):**
```
✅ Attacker has AZURE_CLIENT_ID (just an ID)
✅ Has AZURE_TENANT_ID (just an ID)
✅ Has AZURE_SUBSCRIPTION_ID (just an ID)
✅ Cannot generate valid OIDC token (need GitHub to sign it)
✅ Cannot authenticate to Azure
✅ Damage window: ZERO (no credentials!)
```

### Scenario: Compromised Workflow Token

**With Service Principal Secret:**
```
❌ Token valid for 1 year
❌ Can use from anywhere
❌ Attacker can save and reuse
```

**With OIDC:**
```
✅ Token valid for minutes only
✅ Token tied to workflow run
✅ Token expires before attacker can abuse
✅ New token per run (can't reuse)
```

---

## 📊 Comparison: Bootstrap vs OIDC

| Aspect | Bootstrap (Service Principal Secret) | **OIDC (Recommended)** |
|--------|-------------------------------------|------------------------|
| **Initial setup** | Manual (once) | **Manual (once)** |
| **GitHub secrets** | 4 (including clientSecret) | **3 (no secrets!)** |
| **Security risk** | Medium (secret can leak) | **Very low** |
| **Rotation needed** | Yes (automated but complex) | **NO!** |
| **Token lifetime** | 1 year | **Minutes** |
| **Maintenance** | Automated rotation workflow | **ZERO** 🎉 |
| **Attack surface** | Long-lived credential | **Ephemeral tokens** |
| **Microsoft recommendation** | ⚠️ Not recommended | **✅ Recommended** |

---

## 🎯 Migration Path

### If You Already Set Up Bootstrap

Good news! You can migrate to OIDC easily:

```powershell
# 1. Update Terraform to use federated credentials (already done!)
cd infrastructure
terraform apply -var-file=dev.tfvars

# 2. Get the 3 IDs
terraform output github_secrets_oidc_summary

# 3. Update GitHub secrets:
#    - Remove: AZURE_CREDENTIALS (old way)
#    - Add: AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID

# 4. Update workflow to use azure/login with OIDC (already done!)

# 5. Delete rotation workflow (no longer needed!)
rm .github/workflows/rotate-azure-credentials.yml
```

---

## ✅ Verification

### Test OIDC Authentication

```powershell
# Push code to trigger workflow
git commit --allow-empty -m "Test OIDC authentication"
git push origin main

# Watch workflow run
# https://github.com/uallknowmatt/aksreferenceimplementation/actions

# Verify Azure login step succeeds
# Should see: "Login successful"
```

### Verify Federated Credential

```powershell
# Check federated credential exists
az ad app federated-credential list \
  --id $(cd infrastructure && terraform output -raw github_oidc_client_id)

# Should show:
# - Issuer: https://token.actions.githubusercontent.com
# - Subject: repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main
# - Audiences: api://AzureADTokenExchange
```

---

## 🐛 Troubleshooting

### Error: "AADSTS700024: Client assertion audience claim does not match"

**Cause:** Audience mismatch in federated credential

**Solution:**
```powershell
# Verify audience is correct
cd infrastructure
terraform state show azuread_application_federated_identity_credential.github_actions

# Should show: audience = ["api://AzureADTokenExchange"]
```

### Error: "AADSTS700016: Application not found"

**Cause:** AZURE_CLIENT_ID incorrect

**Solution:**
```powershell
# Get correct client ID
cd infrastructure
terraform output -raw github_oidc_client_id

# Update GitHub secret
```

### Error: "AADSTS700024: Subject mismatch"

**Cause:** Workflow running from wrong repo/branch

**Solution:**
```powershell
# Check federated credential subject
cd infrastructure
terraform state show azuread_application_federated_identity_credential.github_actions

# Should show:
# subject = "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main"

# If running from different branch, update Terraform:
# subject = "repo:owner/repo:ref:refs/heads/your-branch"
```

### Workflow Fails: "Unable to get ACTIONS_ID_TOKEN_REQUEST_URL"

**Cause:** Missing `id-token: write` permission

**Solution:**
```yaml
# Add to workflow
permissions:
  id-token: write  # Required!
  contents: read
```

---

## 📚 Additional Resources

- [Microsoft: GitHub Actions OIDC with Azure](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [GitHub: OIDC Security Hardening](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure: Workload Identity Federation](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation)

---

## 🎉 Summary

### What You Get with OIDC

✅ **Zero secrets stored in GitHub**  
✅ **Zero rotation needed** (tokens auto-expire)  
✅ **Zero maintenance** (GitHub handles everything)  
✅ **Maximum security** (ephemeral tokens, no long-lived creds)  
✅ **Complete audit trail** (every token request logged)  
✅ **Microsoft recommended** (best practice)  

### What You Need to Do

1. **Once:** Run Terraform locally to create federated credential
2. **Once:** Add 3 IDs to GitHub (not secrets!)
3. **Forever:** Enjoy zero-maintenance, secure deployments! 🎉

**This is THE BEST way to authenticate GitHub Actions to Azure!**
