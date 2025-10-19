# Azure Portal OIDC Setup - 5 Minutes to Zero Secrets! 🎉

## 🎯 Your Question Answered

**"Why can't I just login to Azure Portal myself, set up the secrets needed in GitHub Actions, and be done with it?"**

**Answer: You absolutely CAN and SHOULD!** This is actually the **simplest** approach!

---

## ✅ Why Manual Portal Setup is BEST

Forget complicated scripts and Terraform bootstrapping. Just:

1. ✅ **5 minutes** in Azure Portal (one time)
2. ✅ **Zero secrets** stored in GitHub (just 3 non-sensitive IDs)
3. ✅ **Zero maintenance** forever
4. ✅ **No rotation** needed (tokens auto-expire)
5. ✅ **Microsoft recommended** best practice

**Then push your code and you're done forever!**

---

## 🚀 The 5-Minute Setup

### Step 1: Create App Registration (2 minutes)

1. **Login:** https://portal.azure.com
2. Navigate to: **Microsoft Entra ID** (search bar)
3. Click: **App registrations** (left menu) → **+ New registration**
4. Fill in:
   ```
   Name: github-actions-oidc
   Supported account types: Single tenant (default)
   Redirect URI: (leave blank)
   ```
5. Click **Register**
6. **⭐ SAVE THIS:** Copy the **Application (client) ID**

---

### Step 2: Create Federated Credential (1 minute)

1. In your new app, click: **Certificates & secrets** (left menu)
2. Click: **Federated credentials** tab → **+ Add credential**
3. Select: **GitHub Actions deploying Azure resources**
4. Fill in:
   ```
   Organization: uallknowmatt
   Repository: aksreferenceimplementation
   Entity type: Branch
   Branch name: main
   Name: github-main-branch
   ```
5. Click **Add**

**🎉 What this does:** Tells Azure "Trust GitHub tokens from this repo's main branch - NO PASSWORD NEEDED!"

---

### Step 3: Assign Permissions (1 minute)

1. Navigate to: **Subscriptions** (search bar)
2. Click your subscription → **Access control (IAM)**
3. Click: **+ Add** → **Add role assignment**
4. **Role tab:**
   - Select: **Contributor**
   - Click **Next**
5. **Members tab:**
   - Select: **User, group, or service principal**
   - Click **+ Select members**
   - Search: `github-actions-oidc`
   - Click **Select** → **Next**
6. Click **Review + assign**

**🎉 What this does:** Gives GitHub Actions permission to create/manage your Azure resources

---

### Step 4: Get the 3 IDs (1 minute)

**Important: These are NOT secrets! They're just identifiers (safe to share publicly):**

#### A. Client ID
- In app registration → **Overview** → Copy **Application (client) ID**

#### B. Tenant ID  
- **Microsoft Entra ID** → **Overview** → Copy **Tenant ID**

#### C. Subscription ID
- **Subscriptions** → Click your subscription → Copy **Subscription ID**

---

### Step 5: Add to GitHub (1 minute)

1. Go to: https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
2. Click **New repository secret** for each of these three:

**Secret 1:**
```
Name: AZURE_CLIENT_ID
Value: <paste-client-id>
```

**Secret 2:**
```
Name: AZURE_TENANT_ID  
Value: <paste-tenant-id>
```

**Secret 3:**
```
Name: AZURE_SUBSCRIPTION_ID
Value: <paste-subscription-id>
```

**🎉 Done! That's it! Only 3 "secrets" and they're not even sensitive!**

---

## 🏗️ One-Time Infrastructure Creation

Since Azure infrastructure doesn't exist yet, run Terraform locally once:

```powershell
# Login with YOUR personal Azure account
az login

# Navigate to infrastructure
cd c:\genaiexperiments\accountopening\infrastructure

# Initialize Terraform
terraform init

# Create everything (ACR, AKS, PostgreSQL, VNet, etc.)
terraform apply -var-file=dev.tfvars

# Takes 10-15 minutes
```

**What this creates:**
- Azure Container Registry (for Docker images)
- AKS cluster (for Kubernetes)
- PostgreSQL (for databases)
- VNet, subnets, security groups
- All necessary infrastructure

**After this one-time setup, GitHub Actions handles everything via OIDC!**

---

## 🚀 Deploy Your Application

```powershell
cd c:\genaiexperiments\accountopening

# Commit any pending changes (if needed)
git add -A
git commit -m "OIDC setup complete - zero secrets forever!"

# Push and watch the magic!
git push origin main
```

**What happens:**
1. GitHub Actions triggers on push
2. GitHub generates OIDC token (expires in minutes!)
3. Azure validates token using federated credential
4. Workflow builds all 4 microservices
5. Pushes Docker images to ACR
6. Deploys to AKS
7. **Token auto-expires - no cleanup needed!**

---

## 🔍 Verify It's Working

### Check Workflow Logs

1. Go to: https://github.com/uallknowmatt/aksreferenceimplementation/actions
2. Click latest workflow run
3. Expand **"Azure Login (OIDC)"** step
4. Should see:
   ```
   Federated token retrieved successfully
   Login successful using federated identity
   ```

**This confirms: NO PASSWORD USED! GitHub generated a token, Azure accepted it, token will expire in minutes!**

---

## 🆚 Why OIDC is Better Than Service Principal Secrets

| What You Care About | Service Principal Secret | OIDC (This Setup) |
|---------------------|-------------------------|-------------------|
| **Setup time** | 10 minutes (scripting) | **5 minutes (portal)** ✅ |
| **Secrets stored** | 1 (clientSecret) | **0** (just 3 IDs) ✅ |
| **If "secret" leaks** | **🚨 Account compromised** | **No impact** (just IDs) ✅ |
| **Annual rotation** | **YES** (automated workflow needed) | **NO** (never!) ✅ |
| **Token lifetime** | 1 year (risk window) | **Minutes** (auto-expires) ✅ |
| **Maintenance** | Rotation monitoring | **ZERO** ✅ |
| **Security level** | Medium | **Very high** ✅ |
| **Microsoft recommendation** | Legacy | **✅ Current best practice** |
| **Audit trail** | Limited | **Complete** (every token logged) ✅ |

---

## 🎉 What You've Achieved

✅ **Zero secrets** in GitHub (just 3 non-sensitive IDs)  
✅ **Zero maintenance** forever (no rotation)  
✅ **Maximum security** (tokens expire in minutes)  
✅ **5-minute setup** (Azure Portal only)  
✅ **Microsoft recommended** best practice  
✅ **Simple** (no complex scripts or bootstrapping)  

**If those 3 "secrets" leak?** No problem! They're just identifiers. An attacker would need to compromise GitHub's OIDC signing keys (impossible) to use them.

---

## 🔧 Quick Troubleshooting

### Error: "Failed to get federated token"

**Problem:** GitHub can't generate OIDC token

**Fix:** Verify `.github/workflows/aks-deploy.yml` has:
```yaml
jobs:
  build-and-push:
    permissions:
      id-token: write  # ← Must be present!
      contents: read
```

### Error: "Authorization failed"  

**Problem:** Service principal lacks permissions

**Fix:**
1. Go to: Subscription → IAM → Role assignments
2. Verify `github-actions-oidc` has **Contributor** role
3. Wait 5 minutes for Azure AD propagation

### Error: "The provided token is invalid"

**Problem:** Federated credential doesn't match

**Fix:** Verify federated credential settings:
- Organization: `uallknowmatt` (exact match!)
- Repository: `aksreferenceimplementation` (exact match!)
- Entity type: `Branch` (not Pull request)
- Branch: `main` (exact match!)

---

## 📚 Additional Resources

**Want technical details?**
- `OIDC_SETUP_GUIDE.md` - Complete architecture and explanation

**Want to compare approaches?**
- `AUTHENTICATION_COMPARISON.md` - OIDC vs Service Principal vs Bootstrap

**Want automated Terraform approach?**
- `BOOTSTRAP_GUIDE.md` - Fully automated (more complex)

---

## 🚀 Summary

**Your instinct was 100% correct!** The simplest approach is:

1. ✅ **5 minutes** in Azure Portal (manual, one-time)
2. ✅ **3 IDs** added to GitHub (not sensitive!)
3. ✅ **Run Terraform** locally once (creates infrastructure)
4. ✅ **Push code** and you're done
5. ✅ **ZERO maintenance** forever!

**This is actually BETTER than complex automation because:**
- Simpler (no scripts to maintain)
- Faster (Azure Portal UI is intuitive)
- Same result (zero secrets, zero rotation)
- Easier to troubleshoot (you saw what you created)
- One-time only (never touch it again)

**Congratulations! You found the sweet spot between simplicity and security!** 🎉

---

**Next:** Push your code and watch it deploy via OIDC with zero secrets! 🚀
