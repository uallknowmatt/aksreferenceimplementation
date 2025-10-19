# GitHub Secrets Setup Guide

## 🎯 Three Ways to Add Secrets to GitHub

Choose your preferred method:

---

## Method 1: Automated with GitHub CLI (Recommended!) ✅

This is the **easiest and fastest** method - the script does everything for you!

### Prerequisites

Install GitHub CLI:
```bash
# Windows (using winget)
winget install --id GitHub.cli

# macOS
brew install gh

# Linux
sudo apt install gh    # Ubuntu/Debian
sudo dnf install gh    # Fedora
```

### Setup Steps

```bash
# 1. Authenticate to GitHub (one-time)
gh auth login
# Follow prompts: choose GitHub.com, HTTPS, authenticate via browser

# 2. Run the OIDC setup script
.\setup-oidc-cli.ps1    # PowerShell on Windows
# OR
./setup-oidc-cli.sh     # Bash on macOS/Linux

# The script will automatically:
# ✅ Create Azure service principal with OIDC federation
# ✅ Add all 3 secrets to GitHub
# ✅ Display confirmation
```

**That's it!** The script detects GitHub CLI and adds secrets automatically.

---

## Method 2: GitHub CLI Manually

If you want to add secrets manually using GitHub CLI:

```bash
# Authenticate first
gh auth login

# Add each secret
gh secret set AZURE_CLIENT_ID -R uallknowmatt/aksreferenceimplementation
# Paste value and press Enter, then Ctrl+D

gh secret set AZURE_TENANT_ID -R uallknowmatt/aksreferenceimplementation
# Paste value and press Enter, then Ctrl+D

gh secret set AZURE_SUBSCRIPTION_ID -R uallknowmatt/aksreferenceimplementation
# Paste value and press Enter, then Ctrl+D

# Verify
gh secret list -R uallknowmatt/aksreferenceimplementation
```

### Using Piped Input (Easier)

```bash
# After running setup-oidc-cli script, it outputs the values
# Copy them and use:

echo "your-client-id" | gh secret set AZURE_CLIENT_ID -R uallknowmatt/aksreferenceimplementation
echo "your-tenant-id" | gh secret set AZURE_TENANT_ID -R uallknowmatt/aksreferenceimplementation
echo "your-subscription-id" | gh secret set AZURE_SUBSCRIPTION_ID -R uallknowmatt/aksreferenceimplementation
```

---

## Method 3: GitHub Web UI (Traditional)

If you prefer using the web interface:

1. **Go to Repository Settings**
   - Navigate to: https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions

2. **Add Each Secret**
   - Click **"New repository secret"**
   - Add these three secrets:

   | Name | Value | Description |
   |------|-------|-------------|
   | `AZURE_CLIENT_ID` | `<your-client-id>` | Application (client) ID from Azure AD |
   | `AZURE_TENANT_ID` | `<your-tenant-id>` | Directory (tenant) ID from Azure AD |
   | `AZURE_SUBSCRIPTION_ID` | `<your-subscription-id>` | Azure subscription ID |

3. **Verify**
   - You should see all 3 secrets listed
   - Values are hidden (showing "***")

---

## 🔍 Where to Get the Values

### Option A: From setup-oidc-cli Script Output

After running `.\setup-oidc-cli.ps1`, the script displays all three values:

```
✅ Client ID: abc-123-xyz
✅ Tenant ID: def-456-uvw
✅ Subscription ID: ghi-789-rst
```

### Option B: From Azure CLI

```bash
# Get all at once
az account show --query "{subscriptionId:id, tenantId:tenantId}" -o json

# Get Client ID (after creating app registration)
az ad app list --display-name "github-actions-oidc" --query [0].appId -o tsv
```

### Option C: From Azure Portal

1. **Subscription ID:**
   - Azure Portal → Subscriptions → Copy "Subscription ID"

2. **Tenant ID:**
   - Azure Portal → Azure Active Directory → Overview → Copy "Tenant ID"

3. **Client ID:**
   - Azure Portal → Azure Active Directory → App registrations → "github-actions-oidc" → Copy "Application (client) ID"

---

## 📊 Comparison Table

| Method | Setup Time | Ease of Use | Best For |
|--------|------------|-------------|----------|
| **Automated Script** | 30 seconds | ⭐⭐⭐⭐⭐ Easiest | Everyone! |
| **GitHub CLI Manual** | 2 minutes | ⭐⭐⭐⭐ Easy | Power users |
| **GitHub Web UI** | 5 minutes | ⭐⭐⭐ Medium | No CLI access |

---

## ✅ Verify Secrets Are Added

### Using GitHub CLI
```bash
gh secret list -R uallknowmatt/aksreferenceimplementation

# Should show:
# AZURE_CLIENT_ID      Updated YYYY-MM-DD
# AZURE_SUBSCRIPTION_ID Updated YYYY-MM-DD
# AZURE_TENANT_ID      Updated YYYY-MM-DD
```

### Using Web UI
Visit: https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions

You should see all 3 secrets listed.

---

## 🔧 Troubleshooting

### "gh: command not found"

**Problem:** GitHub CLI not installed

**Solution:**
```bash
# Windows
winget install --id GitHub.cli

# macOS
brew install gh

# Verify
gh --version
```

### "authentication required"

**Problem:** Not authenticated to GitHub CLI

**Solution:**
```bash
gh auth login
# Follow prompts to authenticate via browser
```

### "Resource not accessible by personal access token"

**Problem:** Token doesn't have `repo` scope

**Solution:**
```bash
# Re-authenticate with full permissions
gh auth login --scopes repo,workflow

# Or use web UI method instead
```

### "failed to get API: HTTP 404"

**Problem:** Repository name or organization incorrect

**Solution:**
```bash
# Verify repository exists
gh repo view uallknowmatt/aksreferenceimplementation

# Check you have write access
gh repo view uallknowmatt/aksreferenceimplementation --json permissions
```

---

## 🎉 Summary

**Recommended Approach:**

1. Install GitHub CLI: `winget install --id GitHub.cli`
2. Authenticate once: `gh auth login`
3. Run script: `.\setup-oidc-cli.ps1`
4. Done! All secrets added automatically ✅

**No manual copying/pasting needed!**

---

## 📚 Additional Resources

- [GitHub CLI Documentation](https://cli.github.com/)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Azure OIDC Setup Guide](AZURE_PORTAL_OIDC_SETUP.md)
- [Authentication Comparison](AUTHENTICATION_COMPARISON.md)

---

**Your deployment is now fully automated! 🚀**
