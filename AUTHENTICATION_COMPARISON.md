# GitHub Actions Azure Authentication - Complete Comparison

## 🎯 Executive Summary

**We offer TWO ways to authenticate GitHub Actions to Azure:**

1. **OIDC (OpenID Connect)** - ✅ RECOMMENDED by Microsoft
2. **Service Principal Secret** - ❌ Legacy approach

**Bottom line:** Use OIDC unless you have a specific reason not to!

---

## 📊 Detailed Comparison

| Feature | OIDC ✅ | Service Principal Secret ❌ |
|---------|---------|----------------------------|
| **Secrets stored in GitHub** | 0 (just 3 IDs) | 1 (clientSecret) |
| **Token lifetime** | Minutes | 1 year |
| **Rotation required** | NO! | Yes (automated but complex) |
| **Security risk** | Very low | Medium |
| **Attack surface** | Minimal | Larger |
| **Setup complexity** | Same | Same |
| **Maintenance** | Zero | Rotation workflow needed |
| **Microsoft recommendation** | ✅ YES | ⚠️ NOT RECOMMENDED |
| **Audit trail** | Complete (every token logged) | Limited |
| **Token reuse** | Impossible (single-use) | Possible (long-lived) |
| **Location restriction** | GitHub only | Can use anywhere |
| **Expiry risk** | None (auto-refreshed) | Annual rotation required |
| **Leaked secret impact** | None (just IDs) | Full subscription access |
| **Cost** | Free | Free |

---

## 🔐 Security Deep Dive

### Scenario 1: Attacker Gets GitHub Secrets

**With OIDC:**
```
❌ Attacker has AZURE_CLIENT_ID (just an ID, not a secret)
❌ Attacker has AZURE_TENANT_ID (just an ID, not a secret)
❌ Attacker has AZURE_SUBSCRIPTION_ID (just an ID, not a secret)
✅ Cannot generate valid OIDC token (needs GitHub to sign it)
✅ Cannot authenticate to Azure
✅ IMPACT: ZERO
```

**With Service Principal Secret:**
```
❌ Attacker has clientId
❌ Attacker has clientSecret (ACTUAL SECRET!)
❌ Attacker has subscriptionId
❌ Attacker has tenantId
❌ Can authenticate from anywhere
❌ Full subscription access
❌ IMPACT: CRITICAL until secret is rotated
```

### Scenario 2: Compromised Workflow

**With OIDC:**
```
✅ Token valid for minutes only
✅ Token tied to specific workflow run
✅ Token expires automatically
✅ New token per run (can't save and reuse)
✅ IMPACT: Limited to single workflow run
```

**With Service Principal Secret:**
```
❌ Secret valid for 1 year
❌ Can extract secret from environment
❌ Can use secret from anywhere
❌ Can save and reuse indefinitely
❌ IMPACT: High until secret is rotated
```

---

## 🏗️ Architecture Comparison

### OIDC Flow

```
┌─────────────────────┐
│  GitHub Workflow    │
│  Requests token     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  GitHub OIDC        │
│  Generates JWT      │
│  (signed by GitHub) │
└──────────┬──────────┘
           │ Short-lived token (minutes)
           ▼
┌─────────────────────┐
│  Azure AD           │
│  Validates:         │
│  - Signature        │
│  - Repository       │
│  - Branch           │
│  - Not expired      │
└──────────┬──────────┘
           │ Azure AD access token
           ▼
┌─────────────────────┐
│  Azure Resources    │
│  (ACR, AKS, etc.)   │
└─────────────────────┘
```

**Key Points:**
- ✅ No long-lived secrets
- ✅ Token generated per run
- ✅ Automatic expiration
- ✅ Repository-specific
- ✅ Branch-specific

### Service Principal Secret Flow

```
┌─────────────────────┐
│  GitHub Secrets     │
│  (AZURE_CREDENTIALS)│
│  Contains:          │
│  - clientSecret     │ ← LONG-LIVED SECRET!
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  GitHub Workflow    │
│  Reads secret       │
└──────────┬──────────┘
           │ Secret (valid 1 year)
           ▼
┌─────────────────────┐
│  Azure AD           │
│  Validates secret   │
└──────────┬──────────┘
           │ Azure AD access token
           ▼
┌─────────────────────┐
│  Azure Resources    │
│  (ACR, AKS, etc.)   │
└─────────────────────┘
```

**Key Points:**
- ❌ Long-lived secret (1 year)
- ❌ Same secret used every run
- ❌ Manual/automated rotation needed
- ❌ Not repository-specific
- ❌ Not branch-specific

---

## 📋 Setup Instructions

### OIDC Setup (RECOMMENDED)

1. **Run Terraform locally** (one-time):
   ```powershell
   cd infrastructure
   terraform apply -var-file=dev.tfvars
   ```

2. **Get the 3 IDs**:
   ```powershell
   terraform output github_secrets_oidc_summary
   ```

3. **Add to GitHub** (3 values, NOT secrets):
   - AZURE_CLIENT_ID
   - AZURE_TENANT_ID
   - AZURE_SUBSCRIPTION_ID

4. **Update workflow** (uncomment OIDC block):
   ```yaml
   permissions:
     id-token: write
     contents: read
   
   - name: Azure Login with OIDC
     uses: azure/login@v1
     with:
       client-id: ${{ secrets.AZURE_CLIENT_ID }}
       tenant-id: ${{ secrets.AZURE_TENANT_ID }}
       subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
   ```

5. **Done!** Zero maintenance forever.

**Full guide:** `OIDC_SETUP_GUIDE.md`

---

### Service Principal Secret Setup (Legacy)

1. **Uncomment in Terraform**:
   - Edit `infrastructure/iam.tf`
   - Uncomment `azuread_service_principal_password` resource

2. **Run Terraform**:
   ```powershell
   cd infrastructure
   terraform apply -var-file=dev.tfvars
   ```

3. **Get the secret**:
   ```powershell
   terraform output -raw azure_credentials_json
   ```

4. **Add to GitHub** (1 secret):
   - AZURE_CREDENTIALS (contains clientSecret!)

5. **Set up rotation workflow**:
   - Copy `.github/workflows/rotate-azure-credentials.yml`
   - Configure annual rotation

**Full guide:** `BOOTSTRAP_GUIDE.md`

---

## 🔄 Migration: Service Principal → OIDC

Already using service principal secret? Easy migration:

1. **Update Terraform**:
   ```powershell
   cd infrastructure
   # iam.tf already has OIDC federated credential
   terraform apply -var-file=dev.tfvars
   ```

2. **Get OIDC values**:
   ```powershell
   terraform output github_secrets_oidc_summary
   ```

3. **Update GitHub secrets**:
   - Delete: `AZURE_CREDENTIALS` (old)
   - Add: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`

4. **Update workflow**:
   - Uncomment OIDC authentication block
   - Comment out service principal block
   - Add `permissions: id-token: write`

5. **Delete rotation workflow**:
   ```powershell
   rm .github/workflows/rotate-azure-credentials.yml
   ```

6. **Test**:
   ```powershell
   git commit -am "Migrate to OIDC authentication"
   git push
   ```

7. **Done!** No more rotation needed!

---

## 💡 Why Microsoft Recommends OIDC

From [Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure):

> **"OpenID Connect (OIDC) allows your GitHub Actions workflows to access resources in Azure, without needing to store the Azure credentials as long-lived GitHub secrets."**

From [GitHub Security Hardening](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect):

> **"OpenID Connect allows your workflows to exchange short-lived tokens directly from your cloud provider. This means you no longer need to create long-lived secrets."**

**Key reasons:**
1. ✅ Eliminates long-lived secrets
2. ✅ Reduces attack surface
3. ✅ Automatic token expiration
4. ✅ Complete audit trail
5. ✅ Zero rotation overhead

---

## 🤔 When to Use Service Principal Secret

**Only use service principal secret if:**

- ❌ You have a specific compliance requirement
- ❌ Your Azure AD tenant doesn't support federated credentials (rare)
- ❌ You need to authenticate from non-GitHub environments

**Otherwise, use OIDC!** It's more secure and easier to maintain.

---

## 📖 Additional Resources

### OIDC
- `OIDC_SETUP_GUIDE.md` - Complete OIDC setup guide
- [Microsoft: GitHub OIDC with Azure](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [GitHub: OIDC Security Hardening](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)

### Service Principal Secret
- `BOOTSTRAP_GUIDE.md` - Bootstrap setup guide
- `AUTOMATED_CREDENTIAL_ROTATION.md` - Rotation automation
- `ROTATION_QUICK_REFERENCE.md` - Rotation quick reference

### General
- `DEPLOYMENT_PREREQUISITES.md` - Complete deployment guide
- `MINIMAL_SECRETS_DEPLOYMENT.md` - Minimal secrets architecture

---

## 🎯 Decision Matrix

**Use this to decide:**

| Your Situation | Recommended Approach |
|----------------|---------------------|
| **New project** | ✅ OIDC |
| **Maximum security needed** | ✅ OIDC |
| **Minimal maintenance desired** | ✅ OIDC |
| **Microsoft best practices** | ✅ OIDC |
| **Legacy project (already has secret)** | 🔄 Migrate to OIDC |
| **Compliance requires specific secret storage** | ⚠️ Service Principal Secret |
| **Need to authenticate from non-GitHub** | ⚠️ Service Principal Secret |

**Default answer: OIDC** ✅

---

## ✅ Checklist

### For OIDC Setup

- [ ] Terraform applied with federated credential
- [ ] 3 IDs added to GitHub (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID)
- [ ] Workflow updated with `permissions: id-token: write`
- [ ] Workflow updated with OIDC authentication block
- [ ] Test workflow run succeeded
- [ ] Deleted rotation workflow (no longer needed)

### For Service Principal Secret Setup

- [ ] Uncommented `azuread_service_principal_password` in iam.tf
- [ ] Terraform applied
- [ ] AZURE_CREDENTIALS secret added to GitHub
- [ ] Rotation workflow configured
- [ ] Test workflow run succeeded
- [ ] Calendar reminder for secret rotation (or automation configured)

---

## 🎉 Summary

**OIDC is the clear winner:**
- ✅ Zero secrets stored
- ✅ Zero rotation needed
- ✅ Zero maintenance
- ✅ Maximum security
- ✅ Microsoft recommended

**Unless you have a specific reason not to, use OIDC!**

Setup time is identical, but OIDC gives you better security and zero maintenance forever.
