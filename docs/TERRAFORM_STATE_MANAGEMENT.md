# Terraform State Management Guide

## Overview

This document explains how the Terraform state is managed in this project and answers common questions about the `terraform-state-rg` resource group.

---

## Should I Delete `terraform-state-rg`?

### **Answer: NO - Never delete it manually! ❌**

The `terraform-state-rg` resource group contains your **Terraform state files**, which are critical for:

1. **Tracking Infrastructure** - Records what resources exist in Azure
2. **Preventing Conflicts** - Prevents multiple deployments from interfering with each other
3. **State Locking** - Ensures only one deployment runs at a time
4. **Rollback Capability** - Allows you to understand what was deployed

---

## What's Inside `terraform-state-rg`?

```
terraform-state-rg/
└── Storage Account: tfstateaccountopening
    └── Container: tfstate
        └── Blob: dev.terraform.tfstate  ← YOUR TERRAFORM STATE FILE
            • Contains: List of all deployed resources
            • Size: ~50-100 KB
            • Versioned: Yes (30 versions kept)
            • Soft Delete: Yes (30 days retention)
            • Cost: ~$0.50/month
```

### Key Features

✅ **Versioning Enabled** - Previous versions kept for 30 days  
✅ **Soft Delete** - Deleted blobs recoverable for 30 days  
✅ **Encrypted** - Data encrypted at rest (Azure Storage encryption)  
✅ **Private** - No public blob access allowed  
✅ **Locked** - State locking prevents concurrent modifications

---

## How State Management Works

### Automatic Creation (Zero Manual Steps!)

The GitHub Actions workflow **automatically handles everything**:

```yaml
# From .github/workflows/aks-deploy.yml

- name: Setup Terraform State Backend
  run: |
    RESOURCE_GROUP="terraform-state-rg"
    STORAGE_ACCOUNT="tfstateaccountopening"
    
    # Check if storage account exists
    if ! az storage account show --name $STORAGE_ACCOUNT &>/dev/null; then
      # Create resource group
      az group create --name $RESOURCE_GROUP --location eastus
      
      # Create storage account with security features
      az storage account create \
        --name $STORAGE_ACCOUNT \
        --resource-group $RESOURCE_GROUP \
        --sku Standard_LRS \
        --https-only true \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access false
      
      # Enable versioning (keep 30 versions)
      az storage account blob-service-properties update \
        --account-name $STORAGE_ACCOUNT \
        --enable-versioning true
      
      # Enable soft delete (30 days retention)
      az storage account blob-service-properties update \
        --account-name $STORAGE_ACCOUNT \
        --enable-delete-retention true \
        --delete-retention-days 30
      
      # Create container
      az storage container create \
        --name tfstate \
        --account-name $STORAGE_ACCOUNT
    fi
```

### What This Means for You

🎉 **No separate PowerShell or Shell scripts needed!**  
🎉 **No manual setup required!**  
🎉 **Just trigger the workflow and it handles everything!**

---

## When You Delete All Resource Groups

### Scenario: You manually deleted all Azure resources

**What to do:**

1. ✅ **Keep `terraform-state-rg`** - Don't delete it
2. ✅ **Clear the state file** - It's now out of sync with reality
3. ✅ **Trigger workflow** - It will create fresh infrastructure

### Clearing State Files (When Resources Were Deleted Manually)

#### Option A: Delete State Blob via Azure Portal

1. Go to https://portal.azure.com
2. Search for "Storage accounts"
3. Click `tfstateaccountopening`
4. Click **Storage Browser** → **Blob containers**
5. Click `tfstate` container
6. Select `dev.terraform.tfstate`
7. Click **Delete** button
8. Confirm deletion

**Result:** State file deleted. Workflow will create fresh state on next run.

---

#### Option B: Delete State Blob via Azure CLI

```powershell
# Delete the state file
az storage blob delete `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --name dev.terraform.tfstate `
  --auth-mode login

# Verify deletion
az storage blob list `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --auth-mode login
```

**Result:** State file deleted. Should return empty list.

---

#### Option C: Delete and Recreate Storage Account (Nuclear Option)

⚠️ **Only use this if you want a completely fresh start**

```powershell
# Delete the entire storage account (including all state files)
az storage account delete `
  --name tfstateaccountopening `
  --resource-group terraform-state-rg `
  --yes

# Optionally delete the resource group
az group delete `
  --name terraform-state-rg `
  --yes

# Done! Workflow will recreate everything on next run
```

**Result:** Complete clean slate. Workflow auto-creates resource group and storage on next run.

---

## State File Recovery

### If You Accidentally Delete the State File

✅ **Versioning is enabled** - Previous versions are kept for 30 days

#### Recover via Azure Portal

1. Go to Storage Account: `tfstateaccountopening`
2. Click **Storage Browser** → **Blob containers**
3. Click `tfstate` container
4. Click `dev.terraform.tfstate` (will show as deleted)
5. Click **Show deleted blobs** toggle
6. Right-click the deleted blob → **Undelete**

---

#### Recover via Azure CLI

```powershell
# List all versions (including deleted)
az storage blob list `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --include d `
  --auth-mode login

# Undelete the blob
az storage blob undelete `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --name dev.terraform.tfstate `
  --auth-mode login
```

---

### If You Accidentally Delete the Storage Account

✅ **Soft delete is enabled** - Deleted blobs retained for 30 days

#### Check if recoverable

```powershell
# List deleted storage accounts
az storage account list `
  --include-deleted `
  --query "[?name=='tfstateaccountopening']" `
  --output table
```

#### Recover storage account (if within 30 days)

```powershell
# Recover the deleted storage account
az storage account restore `
  --name tfstateaccountopening `
  --resource-group terraform-state-rg
```

---

## State Locking

### How It Works

When Terraform runs, it **locks the state file** to prevent concurrent modifications:

```
1. Terraform acquires lease on state blob
   └─ Lease State: "leased" (locked)
   
2. Terraform performs operations
   └─ State: Read → Plan → Apply → Update
   
3. Terraform releases lease
   └─ Lease State: "available" (unlocked)
```

### If Workflow Fails Mid-Deployment

**Problem:** State file stuck in "leased" state

**Solution:** The workflow has automatic lock clearing:

```yaml
- name: Clear Stuck State Locks (if any)
  continue-on-error: true
  run: |
    # Check lease state
    LEASE_STATE=$(az storage blob show \
      --name dev.terraform.tfstate \
      --query "properties.lease.state" -o tsv)
    
    # If leased but no active operation, break lease
    if [ "$LEASE_STATE" = "leased" ]; then
      az storage blob lease break \
        --blob-name dev.terraform.tfstate \
        --lease-break-period 0
    fi
```

**Manual Fix (if needed):**

```powershell
# Break the lease manually
az storage blob lease break `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --blob-name dev.terraform.tfstate `
  --lease-break-period 0 `
  --auth-mode login
```

---

## Cost Breakdown

### terraform-state-rg Costs

| Resource | Monthly Cost | Description |
|----------|--------------|-------------|
| Storage Account | ~$0.50 | Standard LRS storage |
| State File Storage | ~$0.01 | ~50-100 KB file |
| Versioning | ~$0.10 | 30 versions × ~50 KB each |
| Soft Delete | ~$0.05 | Deleted blobs for 30 days |
| **Total** | **~$0.66/month** | **Negligible cost!** |

**Recommendation:** Always keep this resource group. Cost is minimal and value is immense.

---

## Best Practices

### ✅ DO

1. **Keep terraform-state-rg** - Never delete it
2. **Clear state files** - When resources are manually deleted
3. **Let workflow handle creation** - No manual setup needed
4. **Monitor state file size** - Should stay under 1 MB
5. **Use versioning** - Already enabled automatically
6. **Enable soft delete** - Already enabled automatically

### ❌ DON'T

1. **Delete terraform-state-rg** - Unless you want complete clean slate
2. **Manually edit state files** - Let Terraform manage them
3. **Share state files publicly** - Contains sensitive resource IDs
4. **Disable versioning** - Needed for rollback
5. **Disable soft delete** - Needed for recovery
6. **Run concurrent deployments** - State locking prevents this

---

## Troubleshooting

### Problem: "Backend configuration changed"

**Error Message:**
```
Error: Backend configuration changed
A backend configuration change has been detected.
```

**Solution:**
```powershell
# Re-initialize Terraform with new backend config
cd infrastructure/environments/dev
terraform init -reconfigure -backend-config="key=dev.terraform.tfstate"
```

---

### Problem: "Error acquiring state lock"

**Error Message:**
```
Error: Error acquiring the state lock
Lock Info:
  ID: xxxxxxxxx
  Operation: OperationTypeApply
```

**Solution:**

The workflow automatically handles this, but if running locally:

```powershell
# Option 1: Wait for lock to expire (usually 5 minutes)

# Option 2: Break the lease manually
az storage blob lease break `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --blob-name dev.terraform.tfstate `
  --lease-break-period 0 `
  --auth-mode login

# Option 3: Force unlock (use with caution!)
terraform force-unlock <lock-id>
```

---

### Problem: "Failed to get existing workspaces"

**Error Message:**
```
Error: Failed to get existing workspaces: storage: service returned error
```

**Solution:**

Check if service principal has correct permissions:

```powershell
# Grant Storage Blob Data Contributor role
az role assignment create `
  --assignee <SERVICE_PRINCIPAL_APP_ID> `
  --role "Storage Blob Data Contributor" `
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/terraform-state-rg/providers/Microsoft.Storage/storageAccounts/tfstateaccountopening"
```

The workflow automatically grants this role, but verify if error persists.

---

### Problem: State file corrupted

**Symptoms:**
- Terraform crashes on init
- State file shows as 0 bytes
- "Failed to read state" errors

**Solution:**

Restore from version history:

```powershell
# List all versions
az storage blob list `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --include v `
  --auth-mode login

# Download a previous version
az storage blob download `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --name dev.terraform.tfstate `
  --version-id <VERSION_ID> `
  --file dev.terraform.tfstate.backup `
  --auth-mode login

# Upload as current version (after backing up corrupted file)
az storage blob upload `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --name dev.terraform.tfstate `
  --file dev.terraform.tfstate.backup `
  --overwrite `
  --auth-mode login
```

---

## Summary

### Key Takeaways

✅ **terraform-state-rg is automatically managed** by GitHub Actions workflow  
✅ **No separate PS1/SH scripts needed** - workflow handles everything  
✅ **Never delete terraform-state-rg** unless you want complete clean slate  
✅ **Clear state files** when resources are manually deleted  
✅ **Versioning and soft delete** protect against accidental deletion  
✅ **State locking** prevents concurrent modifications  
✅ **Cost is negligible** (~$0.66/month) compared to value  

### Quick Reference

| Scenario | Action |
|----------|--------|
| First deployment | ✅ Workflow auto-creates everything |
| Manually deleted resources | ✅ Clear state file, keep terraform-state-rg |
| Want completely fresh start | ⚠️ Delete terraform-state-rg, workflow recreates it |
| Accidentally deleted state file | ✅ Recover from versioning (30 days) |
| State file stuck locked | ✅ Workflow auto-clears, or break lease manually |
| Need to rollback | ✅ Restore from version history |

---

## Related Documentation

- **[CLEAN_DEPLOYMENT_GUIDE.md](CLEAN_DEPLOYMENT_GUIDE.md)** - Step-by-step deployment guide
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - General deployment procedures
- **[DESTROY_GUIDE.md](DESTROY_GUIDE.md)** - How to destroy infrastructure
- **[AUTOMATED_TESTING_GUIDE.md](AUTOMATED_TESTING_GUIDE.md)** - Automated testing and self-healing

---

**Need Help?** Check the workflow logs at: https://github.com/uallknowmatt/aksreferenceimplementation/actions

**Questions?** Review the "Setup Terraform State Backend" step in `.github/workflows/aks-deploy.yml` lines 141-207
