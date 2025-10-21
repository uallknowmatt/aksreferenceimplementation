# Terraform State Backend - Azure Storage

## Overview

This project uses **Azure Storage Account** as the Terraform state backend. This ensures that Terraform state persists between GitHub Actions workflow runs and enables proper infrastructure management.

## Why Remote State?

### ❌ Without Remote State (Local State)
- State file is lost after each workflow run
- Terraform doesn't know what resources exist
- Gets "resource already exists" errors
- Can't update or destroy existing resources
- No collaboration possible

### ✅ With Remote State (Azure Storage)
- State persists between runs
- Terraform knows exactly what exists
- Can update and destroy resources properly
- State locking prevents concurrent modifications
- Team collaboration enabled
- Automatic versioning and backup

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow                   │
│                                                              │
│  1. Authenticate to Azure (OIDC)                            │
│  2. Check if backend exists → Create if needed              │
│  3. terraform init (downloads state from storage)           │
│  4. terraform plan/apply (modifies state)                   │
│  5. State automatically saved back to storage               │
└─────────────────────────────────────────────────────────────┘
                              ↓ ↑
                         Read/Write State
                              ↓ ↑
┌─────────────────────────────────────────────────────────────┐
│              Azure Storage Account Backend                   │
│                                                              │
│  Resource Group:  terraform-state-rg                        │
│  Storage Account: tfstateaccountopening                     │
│  Container:       tfstate                                   │
│  State File:      dev.terraform.tfstate                     │
│                                                              │
│  Features:                                                   │
│  ✅ Versioning enabled (30 days)                            │
│  ✅ Soft delete enabled (30 days)                           │
│  ✅ State locking via Azure Blob Lease                      │
│  ✅ Encrypted at rest (Azure Storage encryption)            │
│  ✅ HTTPS only, TLS 1.2+                                     │
└─────────────────────────────────────────────────────────────┘
```

## Backend Configuration

Located in `infrastructure/main.tf`:

```terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateaccountopening"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    # Authentication via ARM_* environment variables
  }
}
```

## Setup

### Automatic Setup (Recommended) ✅

The GitHub Actions workflow automatically sets up the backend on first run:

1. **Checks if storage account exists** - Idempotent, safe to run multiple times
2. **Creates resources if needed**:
   - Resource group: `terraform-state-rg`
   - Storage account: `tfstateaccountopening`
   - Blob container: `tfstate`
   - Enables versioning (30 days)
   - Enables soft delete (30 days)
3. **Grants permissions** - Assigns `Storage Blob Data Contributor` role to GitHub Actions service principal
4. **Initializes Terraform** - Downloads state from remote backend

**No manual steps required!** 🎉

All backend setup is handled inline in the workflow using Azure CLI commands. No separate scripts to maintain!

### Manual Setup (If Needed)

If you want to set up the backend manually or test locally:

```bash
# Variables
RESOURCE_GROUP="terraform-state-rg"
STORAGE_ACCOUNT="tfstateaccountopening"
CONTAINER="tfstate"
LOCATION="eastus"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags purpose=terraform-state

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Enable versioning
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-versioning true

# Create container
az storage container create \
  --name $CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

# Enable soft delete
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-delete-retention true \
  --delete-retention-days 30
```

#### Grant Permissions:
```bash
# Get storage account ID
STORAGE_ACCOUNT_ID=$(az storage account show \
  --name tfstateaccountopening \
  --resource-group terraform-state-rg \
  --query id -o tsv)

# Get service principal object ID
SP_OBJECT_ID=$(az ad sp show \
  --id <YOUR_CLIENT_ID> \
  --query id -o tsv)

# Grant access
az role assignment create \
  --assignee $SP_OBJECT_ID \
  --role "Storage Blob Data Contributor" \
  --scope $STORAGE_ACCOUNT_ID
```

## State Management

### Viewing State

```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show azurerm_resource_group.rg

# Download state file (for inspection only)
az storage blob download \
  --account-name tfstateaccountopening \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --file terraform.tfstate.backup \
  --auth-mode login
```

### State Locking

Azure Storage automatically provides state locking using blob leases:
- Only one Terraform operation can run at a time
- Prevents corruption from concurrent modifications
- Lock is automatically released after operation completes

### State Recovery

If state is corrupted or needs recovery:

```bash
# List state versions
az storage blob list \
  --account-name tfstateaccountopening \
  --container-name tfstate \
  --auth-mode login

# Restore previous version
az storage blob download \
  --account-name tfstateaccountopening \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --version-id <VERSION_ID> \
  --file terraform.tfstate.restored \
  --auth-mode login
```

### Importing Existing Resources

If resources were created outside Terraform, import them:

```bash
# Import resource group
terraform import azurerm_resource_group.rg \
  /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-account-opening-dev-eus

# Import AKS cluster
terraform import azurerm_kubernetes_cluster.aks \
  /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-account-opening-dev-eus/providers/Microsoft.ContainerService/managedClusters/aks-account-opening-dev-eus
```

## Security

### Storage Account Security Features
- ✅ **HTTPS Only**: All traffic encrypted in transit (TLS 1.2+)
- ✅ **Private Access**: Public blob access disabled
- ✅ **Encryption at Rest**: Azure Storage encryption (256-bit AES)
- ✅ **Versioning**: 30 days of version history
- ✅ **Soft Delete**: 30 days recovery window
- ✅ **RBAC**: Access controlled via Azure AD roles

### Authentication
- GitHub Actions authenticates using OIDC (no secrets!)
- Service principal needs `Storage Blob Data Contributor` role
- Authentication via `ARM_*` environment variables

### Access Control
```bash
# View who has access
az role assignment list \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/terraform-state-rg/providers/Microsoft.Storage/storageAccounts/tfstateaccountopening

# Revoke access if needed
az role assignment delete \
  --assignee <PRINCIPAL_ID> \
  --role "Storage Blob Data Contributor" \
  --scope <STORAGE_ACCOUNT_ID>
```

## Troubleshooting

### Error: "Failed to get existing workspaces"
**Cause**: Service principal doesn't have access to storage account
**Solution**: Grant `Storage Blob Data Contributor` role

### Error: "Error locking state"
**Cause**: Another Terraform operation is running, or previous lock wasn't released
**Solution**: 
1. Wait for other operation to complete
2. If stuck, manually break the lease:
```bash
az storage blob lease break \
  --blob-name dev.terraform.tfstate \
  --container-name tfstate \
  --account-name tfstateaccountopening \
  --auth-mode login
```

### Error: "Backend initialization required"
**Cause**: Local Terraform not initialized with backend
**Solution**: `terraform init -reconfigure`

### State Drift
If Terraform state doesn't match reality:
```bash
# Refresh state from Azure
terraform refresh

# See what changed
terraform plan

# Update state to match reality
terraform apply -refresh-only
```

## Cost

### Storage Account Costs (Approximate)
- **Storage**: ~$0.02/month (state files are tiny, usually < 1 MB)
- **Operations**: ~$0.01/month (minimal read/write operations)
- **Total**: ~$0.03/month

**Practically free!** 💰

## Best Practices

1. ✅ **Never commit state files** - `.gitignore` should exclude `*.tfstate*`
2. ✅ **Use separate state files per environment** - dev.tfstate, prod.tfstate
3. ✅ **Enable versioning** - Already configured (30 days)
4. ✅ **Enable soft delete** - Already configured (30 days)
5. ✅ **Use state locking** - Automatic with Azure Storage
6. ✅ **Regular backups** - Versioning provides this
7. ✅ **Principle of least privilege** - Only grant necessary roles
8. ✅ **Monitor access** - Use Azure Activity Logs

## Migration from Local State

If you have existing local state:

1. Create backend (automatic in workflow)
2. Run `terraform init -migrate-state` to copy local state to remote
3. Verify: `terraform state list`
4. Delete local state files: `rm terraform.tfstate*`

## References

- [Terraform Backend Documentation](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
- [Azure Storage Security Guide](https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide)
- [Terraform State Best Practices](https://developer.hashicorp.com/terraform/language/state)

---

**Status**: ✅ **Implemented and Active**

The backend is automatically set up by the GitHub Actions workflow on first run!
