# Infrastructure Destroy Guide

## Overview

The **Destroy Infrastructure** workflow allows you to safely tear down dev or production environments when needed.

## ⚠️ WARNING

**This workflow DESTROYS all infrastructure and DATA in the selected environment.**

- ❌ All AKS pods and services will be deleted
- ❌ All Docker images in ACR will be deleted
- ❌ All PostgreSQL databases and data will be deleted
- ❌ All network resources will be deleted
- ❌ **THIS CANNOT BE UNDONE**

## When to Use

Use this workflow when you need to:
- 🧹 Clean up a dev environment completely
- 💰 Reduce costs by destroying unused resources
- 🔄 Reset an environment to start fresh
- 🧪 Clean up after testing
- 🚨 Emergency cleanup

**DO NOT** use this for:
- ❌ Production (unless you're 100% sure)
- ❌ Routine deployments (use the deploy workflow)
- ❌ Rolling back changes (use kubectl rollout undo)

## How to Run

### Via GitHub UI

1. **Navigate to Actions**
   - Go to: https://github.com/uallknowmatt/aksreferenceimplementation/actions
   - Click on **"Destroy Infrastructure"** workflow (left sidebar)

2. **Click "Run workflow"**
   - Click the **"Run workflow"** dropdown button
   - Select the branch: `main`

3. **Choose Environment**
   - Select environment: `dev` or `prod`

4. **Confirm Destruction**
   - Type: `DESTROY` (all caps, exactly)
   - Click **"Run workflow"** button

5. **Approve (if environment protection is set)**
   - If you configured environment protection, approve the workflow

6. **Monitor Progress**
   - Watch the workflow run
   - Review the destruction plan
   - Wait for completion (usually 5-10 minutes)

### Via GitHub CLI

```bash
# Install GitHub CLI if needed
# https://cli.github.com/

# Destroy dev environment
gh workflow run destroy-infrastructure.yml \
  -f environment=dev \
  -f confirm_destroy=DESTROY

# Destroy prod environment (be careful!)
gh workflow run destroy-infrastructure.yml \
  -f environment=prod \
  -f confirm_destroy=DESTROY
```

## Safety Features

### 1. Confirmation Required
You must type `DESTROY` (all caps) to proceed. Typos will fail:
- ✅ `DESTROY` - Works
- ❌ `destroy` - Fails
- ❌ `Destroy` - Fails
- ❌ `yes` - Fails

### 2. Environment Protection (Optional)
Configure GitHub Environments for additional approval:
1. Go to Settings → Environments
2. Create: `destroy-dev` and `destroy-prod`
3. Add required reviewers
4. Now destruction requires manual approval

### 3. 30-Second Warning
Before destroying, the workflow:
- Shows what will be destroyed
- Lists all affected resources
- Waits 30 seconds
- Gives you time to cancel (Ctrl+C or cancel in UI)

### 4. Destruction Plan Preview
The workflow shows exactly what will be deleted:
```
Resources that will be DESTROYED:
  - azurerm_kubernetes_cluster.aks
  - azurerm_container_registry.acr
  - azurerm_postgresql_flexible_server.db
  - ...
```

## Workflow Steps

```
1. Validate Destroy Request
   └─ Checks confirmation is exactly "DESTROY"

2. Destroy Infrastructure
   ├─ Login to Azure
   ├─ Initialize Terraform
   ├─ Show current state
   ├─ Create destroy plan
   ├─ Show what will be destroyed
   ├─ 30-second final warning
   ├─ Execute destruction
   ├─ Verify resources deleted
   └─ Show cleanup summary
```

## What Gets Destroyed

### Dev Environment (~$150-200/month)
- ✅ Resource Group: `rg-account-opening-dev-eus`
- ✅ AKS Cluster: `aks-account-opening-dev-eus` (2 nodes)
- ✅ Container Registry: `acraccountopeningdeveus` (all images)
- ✅ PostgreSQL Server: `psql-account-opening-dev-eus`
  - Database: customerdb (all data)
  - Database: documentdb (all data)
  - Database: accountdb (all data)
  - Database: notificationdb (all data)
- ✅ Virtual Network: `vnet-account-opening-dev-eus`
- ✅ Subnets: aks-subnet, acr-subnet
- ✅ Network Security Group: `dev-aks-nsg`
- ✅ Log Analytics: `log-account-opening-dev-eus`
- ✅ Managed Identity: `id-account-opening-dev-workload`
- ✅ Private Endpoints
- ✅ All role assignments

### Prod Environment (~$500-800/month)
Same as dev but with:
- 3 nodes (instead of 2)
- Larger VMs (Standard_D4s_v3)
- Larger database (128GB)
- Private AKS cluster

## What Does NOT Get Destroyed

- ❌ Terraform state backend (stays for future use)
- ❌ Terraform state files (preserved in Azure Storage)
- ❌ GitHub secrets
- ❌ GitHub workflows
- ❌ Source code in repository

The state backend (`tfstateaccountopening`) is preserved so you can:
- See what was destroyed in the state history
- Recreate the environment later
- Track state changes over time

## After Destruction

### Immediate Verification

```bash
# Check if resources are gone
az group show --name rg-account-opening-dev-eus
# Should return: ResourceGroupNotFound

# List all resource groups
az group list --output table | grep account-opening
# Should be empty
```

### State File Handling

The state file remains in Azure Storage:
```bash
# View state file
az storage blob list \
  --account-name tfstateaccountopening \
  --container-name tfstate \
  --output table

# Download state file (for backup)
az storage blob download \
  --account-name tfstateaccountopening \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --file dev-backup.tfstate
```

### Optional: Delete State File

If you want to completely remove the state:
```bash
# ⚠️ Only do this if you're SURE
az storage blob delete \
  --account-name tfstateaccountopening \
  --container-name tfstate \
  --name dev.terraform.tfstate
```

## Recreating the Environment

After destruction, to recreate:

### For Dev
```bash
# Just push to main branch
git commit --allow-empty -m "Trigger dev deployment"
git push origin main

# Dev will be automatically recreated
```

### For Prod
```bash
# Push to trigger dev deployment
git push origin main

# After dev deploys, approve UAT
# Prod will be recreated
```

### Manual Trigger
Use the main deployment workflow manually:
1. Go to Actions → Deploy to AKS
2. Run workflow
3. Monitor deployment

## Troubleshooting

### Error: "Confirmation failed"
**Cause**: You didn't type `DESTROY` correctly

**Solution**: 
- Type exactly: `DESTROY` (all caps)
- No spaces before/after
- No quotes

### Error: "Backend doesn't exist"
**Cause**: State backend was manually deleted

**Solution**:
- This is fine - nothing to destroy
- Workflow will exit gracefully
- Check Azure Portal for any orphaned resources

### Resources Still Exist After Destroy
**Cause**: Some resources failed to delete

**Steps**:
1. Check workflow logs for errors
2. Manually delete via Azure Portal
3. Check for locks or dependencies
4. Re-run destroy workflow

**Manual cleanup**:
```bash
# Force delete resource group
az group delete \
  --name rg-account-opening-dev-eus \
  --yes \
  --no-wait

# Wait for deletion
az group wait \
  --name rg-account-opening-dev-eus \
  --deleted
```

### Error: "Permission denied"
**Cause**: Service principal lacks delete permissions

**Solution**:
- Check service principal has "Contributor" role
- Verify no resource locks exist
- Check Azure AD permissions

## Best Practices

### Before Destroying

✅ **DO**:
- Backup any critical data
- Export database dumps
- Save Docker images you need
- Document the configuration
- Notify team members
- Check for production dependencies

❌ **DON'T**:
- Destroy production without approval
- Destroy during business hours (for prod)
- Destroy if users are active
- Skip the backup step

### Backup Database Before Destroy

```bash
# Connect to PostgreSQL
kubectl get pods | grep postgres

# Export databases
kubectl exec -it <postgres-pod> -- pg_dump -U psqladmin customerdb > customerdb-backup.sql
kubectl exec -it <postgres-pod> -- pg_dump -U psqladmin documentdb > documentdb-backup.sql
kubectl exec -it <postgres-pod> -- pg_dump -U psqladmin accountdb > accountdb-backup.sql
kubectl exec -it <postgres-pod> -- pg_dump -U psqladmin notificationdb > notificationdb-backup.sql
```

### Save Docker Images

```bash
# List images
az acr repository list --name acraccountopeningdeveus

# Pull important images
docker pull acraccountopeningdeveus.azurecr.io/customer-service:latest
docker pull acraccountopeningdeveus.azurecr.io/document-service:latest
# ... etc

# Save to tar files
docker save acraccountopeningdeveus.azurecr.io/customer-service:latest > customer-service.tar
```

## Cost Savings

Destroying environments when not in use saves costs:

### Dev Environment
- **Running**: ~$150-200/month
- **Destroyed**: $0/month (only state storage ~$1/month)
- **Savings**: ~$150-200/month

### Production Environment
- **Running**: ~$500-800/month
- **Destroyed**: $0/month
- **Savings**: ~$500-800/month

**Example Usage Pattern**:
- Deploy dev Monday morning
- Use dev during the week
- Destroy dev Friday evening
- Recreate Monday morning
- **Monthly savings**: ~$60-80 (weekends only)

## Security Considerations

### Audit Trail
All destroy operations are logged:
- GitHub Actions logs (90 days retention)
- Azure Activity Log (90 days default)
- Terraform state history

### Review Logs
```bash
# View recent deletions in Azure
az monitor activity-log list \
  --max-events 50 \
  --query "[?contains(operationName.value, 'delete')]" \
  --output table
```

### Who Can Destroy?

Configure GitHub Environment protection to control who can approve:
1. Settings → Environments
2. Create `destroy-prod` environment
3. Add required reviewers (senior team members only)
4. Save protection rules

## Emergency Destroy

If you need to destroy immediately (e.g., cost overrun):

1. **Cancel any running workflows** first
2. **Run destroy workflow**
3. **Monitor closely** for failures
4. **Manually delete** any stuck resources
5. **Verify deletion** in Azure Portal

**Fast manual destroy**:
```bash
# Login
az login

# Delete resource group (forces everything)
az group delete \
  --name rg-account-opening-dev-eus \
  --yes \
  --no-wait

# This skips Terraform and deletes everything
```

## Summary

| Aspect | Details |
|--------|---------|
| **Trigger** | Manual (workflow_dispatch) |
| **Confirmation** | Must type "DESTROY" |
| **Warning** | 30-second countdown |
| **Duration** | ~5-10 minutes |
| **Reversible** | ❌ No - data is lost |
| **Cost After** | ~$0/month (just state storage) |
| **State Preserved** | ✅ Yes (for history) |

---

**Use this workflow carefully and always confirm you're destroying the right environment!** 🚨
