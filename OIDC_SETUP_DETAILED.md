# Azure OIDC Setup - Detailed Step-by-Step Guide

This guide explains each command in the OIDC setup process, what it does, why it's needed, and shows example output.

---

## 🎯 What is OIDC and Why Use It?

**OIDC (OpenID Connect)** is a modern authentication protocol that allows GitHub Actions to authenticate to Azure **without storing long-lived secrets**.

### Traditional Approach (Bad) ❌
```
GitHub Secret: clientSecret = "abc123xyz" (expires in 1 year)
↓
GitHub Actions uses this password to login to Azure
↓
Must rotate secret before expiration
```

### OIDC Approach (Good) ✅
```
GitHub Actions requests: "I'm workflow X from repo Y"
↓
Azure checks: "Does GitHub say this is really repo Y?"
↓
Azure generates short-lived token (1 hour)
↓
No secrets stored, tokens auto-expire
```

**Benefits:**
- ✅ No secrets to store
- ✅ No rotation needed
- ✅ Tokens expire automatically
- ✅ More secure (can't be leaked)
- ✅ Audit trail of which repos accessed Azure

---

## 📋 Prerequisites

1. **Azure CLI installed**: `az --version`
2. **GitHub CLI installed**: `gh --version`
3. **Azure account**: Active subscription with permissions to create app registrations
4. **GitHub account**: Write access to the repository

---

## 🚀 Step-by-Step Setup

### Step 0: Login to Azure

```bash
az login --use-device-code
```

**What it does:**
- Opens browser or shows device code
- Authenticates you to Azure
- Gets access token for managing Azure resources

**Mock Output:**
```
To sign in, use a web browser to open the page https://microsoft.com/devicelogin 
and enter the code A4SBXQUGD to authenticate.

[
  {
    "cloudName": "AzureCloud",
    "id": "d8797220-f5cf-4668-a271-39ce114bb150",
    "name": "Azure subscription 1",
    "state": "Enabled",
    "tenantId": "c742e0a4-0cf9-4202-aec8-f4b52ecf17cf",
    "user": {
      "name": "user@example.com",
      "type": "user"
    }
  }
]
```

**Why needed:** You must be authenticated to create Azure AD resources.

---

### Step 1: Get Azure Account Information

```bash
az account show --query "{subscriptionId:id, tenantId:tenantId}" -o json
```

**What it does:**
- Retrieves your current Azure subscription ID
- Gets your Azure AD tenant ID
- Both are non-sensitive identifiers (not secrets!)

**Mock Output:**
```json
{
  "subscriptionId": "d8797220-f5cf-4668-a271-39ce114bb150",
  "tenantId": "c742e0a4-0cf9-4202-aec8-f4b52ecf17cf"
}
```

**Why needed:** 
- Subscription ID tells Azure which subscription to bill/use
- Tenant ID tells Azure which directory contains your apps
- Both needed for GitHub Actions to authenticate

**Store these values:** You'll add them to GitHub secrets later.

---

### Step 2: Create App Registration

```bash
az ad app create --display-name "github-actions-oidc"
```

**What it does:**
- Creates an "application" in Azure Active Directory
- This is an identity that can be assigned permissions
- Think of it as a "user account" for GitHub Actions

**Mock Output:**
```json
{
  "appId": "dee4be7b-818b-4a94-8de2-4992da57b9c6",
  "displayName": "github-actions-oidc",
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "identifierUris": [],
  "publisherDomain": "uallknowmattyahoo.onmicrosoft.com",
  "signInAudience": "AzureADMyOrg"
}
```

**Why needed:** 
- Azure needs an "identity" to grant permissions to
- This is what GitHub Actions will authenticate AS
- Without this, GitHub can't access Azure resources

**Important value:** `appId` = **Client ID** (save this!)

---

### Step 3: Get the Client ID

```bash
az ad app list --display-name "github-actions-oidc" --query [0].appId -o tsv
```

**What it does:**
- Searches for apps with name "github-actions-oidc"
- Returns the Application (Client) ID
- This is the identifier GitHub Actions will use

**Mock Output:**
```
dee4be7b-818b-4a94-8de2-4992da57b9c6
```

**Why needed:**
- Used in subsequent commands to reference this app
- Will be stored in GitHub secrets as `AZURE_CLIENT_ID`
- GitHub Actions sends this ID when requesting tokens

---

### Step 4: Create Service Principal

```bash
az ad sp create --id dee4be7b-818b-4a94-8de2-4992da57b9c6
```

**What it does:**
- Creates a "service principal" from the app registration
- Service principal = the actual account that can DO things
- App registration = just the definition, service principal = the instance

**Mock Output:**
```json
{
  "accountEnabled": true,
  "appId": "dee4be7b-818b-4a94-8de2-4992da57b9c6",
  "displayName": "github-actions-oidc",
  "id": "f9e8d7c6-b5a4-3210-9876-543210fedcba",
  "servicePrincipalType": "Application"
}
```

**Why needed:**
- You can't assign Azure permissions to an app registration directly
- Service principal is the "real" identity that gets permissions
- Think: App = blueprint, Service Principal = actual building

**Analogy:**
```
App Registration     = Job description
Service Principal    = Employee hired for that job
Permissions          = Access badges given to employee
```

---

### Step 5: Create Federated Credential (The OIDC Magic!)

```bash
# Create JSON file
cat > federated-credential.json <<EOF
{
  "name": "github-actions-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main",
  "description": "GitHub Actions OIDC for main branch",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

# Create the credential
az ad app federated-credential create \
  --id dee4be7b-818b-4a94-8de2-4992da57b9c6 \
  --parameters @federated-credential.json
```

**What it does:**
- Tells Azure to TRUST GitHub's OIDC tokens
- Configures WHICH GitHub repo/branch can authenticate
- Establishes the trust relationship between GitHub and Azure

**Mock Output:**
```json
{
  "audiences": ["api://AzureADTokenExchange"],
  "description": "GitHub Actions OIDC for main branch",
  "issuer": "https://token.actions.githubusercontent.com",
  "name": "github-actions-main",
  "subject": "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main"
}
```

**Why needed:** This is the CORE of OIDC!

**What each field means:**

- **`issuer`**: Who generates the tokens? (GitHub Actions)
  - Azure will trust tokens from this URL
  - GitHub's token service signs all workflow tokens

- **`subject`**: Which repo/branch is allowed?
  - Format: `repo:OWNER/REPO:ref:refs/heads/BRANCH`
  - Only workflows from THIS specific repo/branch can authenticate
  - Prevents other repos from impersonating you

- **`audiences`**: What is the token for?
  - Always `api://AzureADTokenExchange` for Azure
  - Ensures token is meant for Azure (not someone else)

- **`name`**: Just a friendly name for the credential

**The Authentication Flow:**
```
1. GitHub Actions workflow runs on main branch
2. GitHub generates JWT token saying "I'm repo X, branch Y"
3. Workflow sends token to Azure: "Give me access!"
4. Azure checks:
   - Is issuer "token.actions.githubusercontent.com"? ✓
   - Is subject "repo:X:ref:refs/heads/Y"? ✓
   - Is audience "api://AzureADTokenExchange"? ✓
5. Azure generates short-lived access token (1 hour)
6. Workflow uses this token to access Azure resources
```

**Security Benefits:**
- ✅ Only YOUR repo can authenticate (subject check)
- ✅ Only YOUR branch can authenticate (ref check)
- ✅ Tokens expire in 1 hour (can't be reused)
- ✅ No secrets stored anywhere (GitHub just proves identity)

---

### Step 6: Assign Contributor Role

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az role assignment create \
  --assignee dee4be7b-818b-4a94-8de2-4992da57b9c6 \
  --role Contributor \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

**What it does:**
- Grants the service principal "Contributor" permissions
- Contributor = can create/modify/delete most Azure resources
- Scoped to your entire subscription

**Mock Output:**
```json
{
  "id": "/subscriptions/d8797220-.../roleAssignments/12345678-...",
  "name": "12345678-1234-1234-1234-123456789abc",
  "principalId": "f9e8d7c6-b5a4-3210-9876-543210fedcba",
  "roleDefinitionName": "Contributor",
  "scope": "/subscriptions/d8797220-f5cf-4668-a271-39ce114bb150",
  "type": "Microsoft.Authorization/roleAssignments"
}
```

**Why needed:**
- Service principal needs permissions to DO things
- Without this, authentication works but actions fail
- Contributor role allows Terraform to create infrastructure

**Permission Levels:**
- **Owner**: Full access including assigning permissions
- **Contributor**: Can create/modify/delete resources (what we use)
- **Reader**: Can only view resources
- **Custom roles**: Specific permissions only

**Scope Levels:**
- **Subscription**: Access to everything in subscription (what we use)
- **Resource Group**: Access to specific resource group only
- **Resource**: Access to one specific resource only

---

### Step 7: Add Secrets to GitHub (Automated!)

```bash
# Authenticate to GitHub CLI
gh auth login

# Add the three secrets
echo "dee4be7b-818b-4a94-8de2-4992da57b9c6" | \
  gh secret set AZURE_CLIENT_ID -R uallknowmatt/aksreferenceimplementation

echo "c742e0a4-0cf9-4202-aec8-f4b52ecf17cf" | \
  gh secret set AZURE_TENANT_ID -R uallknowmatt/aksreferenceimplementation

echo "d8797220-f5cf-4668-a271-39ce114bb150" | \
  gh secret set AZURE_SUBSCRIPTION_ID -R uallknowmatt/aksreferenceimplementation
```

**What it does:**
- Uses GitHub CLI to add secrets to your repo
- These are NOT sensitive values (just identifiers)
- GitHub Actions needs these to know WHERE to authenticate

**Mock Output:**
```
✓ Set Actions secret AZURE_CLIENT_ID for uallknowmatt/aksreferenceimplementation
✓ Set Actions secret AZURE_TENANT_ID for uallknowmatt/aksreferenceimplementation
✓ Set Actions secret AZURE_SUBSCRIPTION_ID for uallknowmatt/aksreferenceimplementation
```

**Why needed:**
- GitHub Actions needs to know:
  - **Client ID**: Which app to authenticate as
  - **Tenant ID**: Which Azure AD to use
  - **Subscription ID**: Which Azure subscription to access

**Note:** These are **identifiers**, not passwords!
- Safe to log/display
- Can't be used alone to access Azure
- Must be combined with GitHub's OIDC token (which only GitHub can generate)

---

### Step 8: Verify Setup

```bash
# Verify secrets are added
gh secret list -R uallknowmatt/aksreferenceimplementation

# Verify app registration
az ad app show --id dee4be7b-818b-4a94-8de2-4992da57b9c6 \
  --query "{name:displayName, appId:appId}" -o json

# Verify federated credential
az ad app federated-credential list \
  --id dee4be7b-818b-4a94-8de2-4992da57b9c6 \
  --query "[].{name:name, subject:subject}" -o json

# Verify role assignment
az role assignment list \
  --assignee dee4be7b-818b-4a94-8de2-4992da57b9c6 \
  --query "[].{role:roleDefinitionName, scope:scope}" -o json
```

**Mock Output:**

**GitHub Secrets:**
```
NAME                   UPDATED               
AZURE_CLIENT_ID        less than a minute ago
AZURE_SUBSCRIPTION_ID  less than a minute ago
AZURE_TENANT_ID        less than a minute ago
```

**App Registration:**
```json
{
  "appId": "dee4be7b-818b-4a94-8de2-4992da57b9c6",
  "name": "github-actions-oidc"
}
```

**Federated Credential:**
```json
[
  {
    "name": "github-actions-main",
    "subject": "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main"
  }
]
```

**Role Assignment:**
```json
[
  {
    "role": "Contributor",
    "scope": "/subscriptions/d8797220-f5cf-4668-a271-39ce114bb150"
  }
]
```

---

## 🔄 How It Works in GitHub Actions

Your workflow file (`.github/workflows/aks-deploy.yml`) will use this:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required for OIDC!
      contents: read
    
    steps:
      - name: Azure Login via OIDC
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**What happens:**
```
1. Workflow starts
2. GitHub Actions generates JWT token:
   - Signed by GitHub
   - Contains: repo name, branch, workflow
3. azure/login action sends token to Azure
4. Azure validates:
   - Signature is from GitHub ✓
   - Subject matches federated credential ✓
   - Audience is correct ✓
5. Azure returns access token (valid 1 hour)
6. All subsequent Azure CLI commands use this token
7. Token expires automatically (no cleanup needed)
```

---

## 🆚 Comparison: Secrets vs OIDC

| Aspect | Service Principal Secret | OIDC |
|--------|-------------------------|------|
| **Setup** | Create SP, store password | Create SP, configure federation |
| **Secrets Stored** | 1 password (clientSecret) | 0 passwords! |
| **Expiration** | 1-2 years | Tokens: 1 hour (auto-renew) |
| **Rotation** | Manual, before expiration | Never needed |
| **Security** | Password can be stolen | Can't steal (GitHub generates tokens) |
| **Audit** | Who used the password? Unknown | Exact repo/branch/workflow logged |
| **Complexity** | Simple | Slightly more setup |
| **Best Practice** | ❌ Old approach | ✅ Modern approach |

---

## 🛡️ Security Benefits

### 1. No Long-Lived Secrets
- Traditional: Password valid for 1 year
- OIDC: Tokens valid for 1 hour, auto-renewed

### 2. Can't Be Stolen
- Traditional: If password leaked, attacker has access for 1 year
- OIDC: Tokens generated by GitHub (can't be leaked from code)

### 3. Granular Control
- Can limit to specific:
  - Repository
  - Branch
  - Environment (production, staging)
  - Pull requests vs pushes

### 4. Full Audit Trail
- Azure logs show EXACTLY which repo/branch accessed resources
- Can detect unusual access patterns

### 5. No Rotation Overhead
- Traditional: Must rotate every 90 days
- OIDC: Nothing to rotate!

---

## 🔧 Troubleshooting

### Issue: "invalid_grant" error

**Problem:** Azure refresh token expired

**Solution:**
```bash
az account clear
az login --use-device-code
```

### Issue: Federated credential creation fails with JSON error

**Problem:** PowerShell escaping issues

**Solution:** Use a file instead:
```bash
# Create file
@{
  name = "github-actions-main"
  issuer = "https://token.actions.githubusercontent.com"
  subject = "repo:owner/repo:ref:refs/heads/main"
  audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json | Out-File cred.json

# Use file
az ad app federated-credential create --id <CLIENT_ID> --parameters @cred.json
```

### Issue: GitHub Actions fails with "OIDC token not found"

**Problem:** Missing `id-token: write` permission

**Solution:** Add to workflow:
```yaml
permissions:
  id-token: write
  contents: read
```

### Issue: Azure login succeeds but can't create resources

**Problem:** Service principal missing permissions

**Solution:** Verify role assignment:
```bash
az role assignment list --assignee <CLIENT_ID>
```

---

## 📚 Additional Resources

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure Workload Identity Documentation](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [GitHub CLI Reference](https://cli.github.com/manual/)

---

## ✅ Summary

**What you created:**
1. ✅ App registration in Azure AD
2. ✅ Service principal with Contributor role
3. ✅ Federated credential linking GitHub to Azure
4. ✅ 3 GitHub secrets (identifiers, not passwords)

**What you achieved:**
- ✅ Zero passwords stored anywhere
- ✅ GitHub Actions can authenticate to Azure
- ✅ Tokens auto-expire (1 hour)
- ✅ No rotation needed ever
- ✅ Full audit trail of access

**Your workflow is now secure and maintenance-free! 🎉**
