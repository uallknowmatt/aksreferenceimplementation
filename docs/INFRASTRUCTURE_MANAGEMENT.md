# Infrastructure Management Guide

Complete guide for managing Azure infrastructure including creation, starting, stopping, and destruction of resources.

## Table of Contents
- [Creating Brand New Infrastructure](#creating-brand-new-infrastructure)
- [Starting Infrastructure](#starting-infrastructure-cost-saving)
- [Stopping Infrastructure](#stopping-infrastructure-cost-saving)
- [Destroying Infrastructure](#destroying-infrastructure-complete-cleanup)
- [Cost Management](#cost-management)

---

## Creating Brand New Infrastructure

### Prerequisites

- Azure CLI installed and logged in
- Terraform installed (1.6+)
- Contributor access to Azure subscription
- Service principal created (for CI/CD)

### Step-by-Step Creation

#### 1. Login to Azure

```bash
az login

# Verify subscription
az account show
```

#### 2. Navigate to Environment

```bash
cd infrastructure/environments/dev
```

#### 3. Initialize Terraform

```bash
terraform init
```

**What this does:**
- Downloads Azure provider
- Configures remote state backend
- Prepares working directory

#### 4. Review Planned Changes

```bash
terraform plan
```

**Review output carefully:**
- Resources to be created
- Estimated costs
- Configuration values

#### 5. Apply Infrastructure

```bash
terraform apply
```

- Review the plan again
- Type `yes` to confirm
- Wait 10-15 minutes for completion

**Resources Created:**
- ✅ Resource Group
- ✅ Virtual Network (VNet) with 3 subnets
- ✅ Network Security Groups (NSGs)
- ✅ AKS Cluster (1 node)
- ✅ Azure Container Registry (ACR)
- ✅ PostgreSQL Flexible Server (VNet integrated)
- ✅ Private DNS Zones
- ✅ Managed Identity for AKS
- ✅ Role assignments

#### 6. Save Outputs

```bash
terraform output > ../../../infrastructure-outputs.txt

# View specific outputs
terraform output resource_group_name
terraform output aks_cluster_name
terraform output postgres_server_name
terraform output acr_login_server
```

#### 7. Configure kubectl

```bash
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw aks_cluster_name)

# Verify connection
kubectl get nodes
```

#### 8. Verify Infrastructure

```bash
# Check all resources
cd ../../../scripts/educational
./check-infra-status.sh
```

### Infrastructure Created Details

**Resource Group:** `rg-account-opening-dev-eus2`
- Location: East US 2
- Contains all resources

**Virtual Network:** `vnet-account-opening-dev-eus2`
- Address space: 10.0.0.0/16
- Subnets:
  - AKS: 10.0.1.0/24
  - ACR: 10.0.2.0/24
  - PostgreSQL: 10.0.3.0/24

**AKS Cluster:** `aks-account-opening-dev-eus2`
- Kubernetes version: 1.28+
- Node pool: 1 x Standard_B2s
- Network plugin: Azure CNI
- Load balancer: Standard SKU

**PostgreSQL:** `psql-account-opening-dev-eus2`
- Version: PostgreSQL 15
- SKU: Burstable B1ms
- Storage: 32 GB
- VNet integrated (private only)

**Container Registry:** `acr<uniqueid>.azurecr.io`
- SKU: Basic
- Admin user: Disabled
- Managed identity access

### Expected Cost

**Development Environment (24/7):**
- Total: ~$110-135/month

**Can be reduced by 47% with stop/start strategy**

---

## Starting Infrastructure (Cost Saving)

When infrastructure is stopped to save costs, use these methods to start it.

### Method 1: Using Script (Easiest)

```bash
cd scripts/educational
./start-infra.sh
```

**What it does:**
1. Checks current status
2. Starts AKS cluster
3. Starts PostgreSQL server
4. Waits for services to be ready
5. Shows final status

### Method 2: Azure CLI

```bash
# Start AKS cluster
az aks start \
  --resource-group rg-account-opening-dev-eus2 \
  --name aks-account-opening-dev-eus2

# Start PostgreSQL
az postgres flexible-server start \
  --resource-group rg-account-opening-dev-eus2 \
  --name psql-account-opening-dev-eus2

# Check status
az aks show \
  --resource-group rg-account-opening-dev-eus2 \
  --name aks-account-opening-dev-eus2 \
  --query "powerState"

az postgres flexible-server show \
  --resource-group rg-account-opening-dev-eus2 \
  --name psql-account-opening-dev-eus2 \
  --query "state"
```

### Method 3: Azure Portal

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to resource group `rg-account-opening-dev-eus2`
3. **Start AKS:**
   - Select AKS cluster
   - Click **Start** button in top toolbar
   - Wait 2-3 minutes
4. **Start PostgreSQL:**
   - Select PostgreSQL server
   - Click **Start** button in top toolbar
   - Wait 1-2 minutes

### Method 4: GitHub Actions Workflow

1. Go to GitHub → Actions
2. Select "Start Infrastructure" workflow
3. Click "Run workflow"
4. Select environment: `dev` or `prod`
5. Click "Run workflow" button
6. Monitor progress in Actions tab

### Timing

- **AKS:** 2-3 minutes to start
- **PostgreSQL:** 1-2 minutes to start
- **Total:** ~5 minutes

### After Starting

```bash
# Verify AKS is running
kubectl get nodes

# Should show nodes in "Ready" state

# Verify pods start
kubectl get pods

# Check database connectivity
cd scripts/educational
./test-postgres-connection.sh
```

### Troubleshooting Start Issues

**AKS won't start:**
```bash
# Check for errors
az aks show \
  --resource-group rg-account-opening-dev-eus2 \
  --name aks-account-opening-dev-eus2 \
  --query "{Name:name, Status:powerState, ProvisioningState:provisioningState}"

# Common issues:
# - Already running (check status)
# - Subscription quota exceeded
# - Billing issue
```

**PostgreSQL won't start:**
```bash
# Check for errors
az postgres flexible-server show \
  --resource-group rg-account-opening-dev-eus2 \
  --name psql-account-opening-dev-eus2 \
  --query "{Name:name, State:state}"

# If stuck in "Stopping" state, wait a few minutes
```

---

## Stopping Infrastructure (Cost Saving)

Stop infrastructure when not in use to save ~$100-150/month (67% savings).

### Method 1: Using Script (Easiest)

```bash
cd scripts/educational
./stop-infra.sh
```

**What it does:**
1. Checks current status
2. Stops AKS cluster
3. Stops PostgreSQL server
4. Shows final status
5. Displays cost savings

### Method 2: Azure CLI

```bash
# Stop AKS cluster (saves ~$70-100/month)
az aks stop \
  --resource-group rg-account-opening-dev-eus2 \
  --name aks-account-opening-dev-eus2

# Stop PostgreSQL (saves ~$40-50/month)
az postgres flexible-server stop \
  --resource-group rg-account-opening-dev-eus2 \
  --name psql-account-opening-dev-eus2

# Verify stopped
az aks show \
  --resource-group rg-account-opening-dev-eus2 \
  --name aks-account-opening-dev-eus2 \
  --query "powerState"

# Output should be: {"code": "Stopped"}
```

### Method 3: Azure Portal

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to resource group `rg-account-opening-dev-eus2`
3. **Stop AKS:**
   - Select AKS cluster
   - Click **Stop** button in top toolbar
   - Confirm action
4. **Stop PostgreSQL:**
   - Select PostgreSQL server
   - Click **Stop** button in top toolbar
   - Confirm action

### Method 4: GitHub Actions Workflow

1. Go to GitHub → Actions
2. Select "Stop Infrastructure" workflow
3. Click "Run workflow"
4. Select environment: `dev` or `prod`
5. Click "Run workflow" button

### What Happens When Stopped

**✅ Preserved:**
- All configuration
- All data in databases
- Docker images in ACR
- Network configuration
- Kubernetes deployments (not running)

**💰 Cost Savings:**
- AKS compute: $0 (nodes deallocated)
- PostgreSQL compute: $0 (stopped)
- Storage: Still charged (~$5-10/month)
- Networking: Still charged (~$5/month)

**⏱️ Can restart anytime:**
- No data loss
- Same configuration
- Quick restart (5 minutes)

### Cost Comparison

| State | Monthly Cost | Savings |
|-------|--------------|---------|
| Running 24/7 | $110-135 | - |
| Stopped | $10-20 | 85% |
| Stopped nights/weekends | $50-75 | 47% |

### Automated Stop/Start Schedule

**Using GitHub Actions (recommended for dev):**

Create `.github/workflows/scheduled-stop.yml`:
```yaml
name: Stop Infrastructure (Nightly)
on:
  schedule:
    - cron: '0 22 * * 1-5'  # 10 PM UTC Mon-Fri (6 PM EST)

jobs:
  stop:
    runs-on: ubuntu-latest
    steps:
      - uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Stop AKS
        run: |
          az aks stop \
            --resource-group rg-account-opening-dev-eus2 \
            --name aks-account-opening-dev-eus2
      
      - name: Stop PostgreSQL
        run: |
          az postgres flexible-server stop \
            --resource-group rg-account-opening-dev-eus2 \
            --name psql-account-opening-dev-eus2
```

Create `.github/workflows/scheduled-start.yml`:
```yaml
name: Start Infrastructure (Morning)
on:
  schedule:
    - cron: '0 12 * * 1-5'  # 12 PM UTC Mon-Fri (8 AM EST)

jobs:
  start:
    runs-on: ubuntu-latest
    steps:
      - uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Start AKS
        run: |
          az aks start \
            --resource-group rg-account-opening-dev-eus2 \
            --name aks-account-opening-dev-eus2
      
      - name: Start PostgreSQL
        run: |
          az postgres flexible-server start \
            --resource-group rg-account-opening-dev-eus2 \
            --name psql-account-opening-dev-eus2
```

**Savings with this schedule:**
- Stopped: 6 PM - 8 AM (14 hours) + weekends
- Total stopped: ~70% of time
- **Monthly savings: ~$52-70 (47%)**

---

## Destroying Infrastructure (Complete Cleanup)

### ⚠️ WARNING

**This permanently deletes ALL resources and data!**
- Cannot be undone
- All databases will be deleted
- All Docker images will be deleted
- All configurations will be deleted

**Only do this if:**
- You're done with the project
- You want to start completely fresh
- You want to stop all Azure costs

### Before Destroying

**1. Backup important data:**
```bash
# Export database (if needed)
kubectl run psql-backup --image=postgres:15 --rm -it --restart=Never -- \
  pg_dump -h psql-account-opening-dev-eus2.postgres.database.azure.com \
          -U psqladmin \
          -d customerdb > customerdb-backup.sql
```

**2. Save Terraform state (optional):**
```bash
cd infrastructure/environments/dev
cp terraform.tfstate terraform.tfstate.backup
```

**3. Document any important configurations:**
- LoadBalancer IPs
- Custom NSG rules
- Any manual changes

### Method 1: Using Terraform (Recommended)

```bash
cd infrastructure/environments/dev

# Preview what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy
```

**During destruction:**
- Review the list of resources to be deleted
- Type `yes` to confirm
- Wait 5-10 minutes

**What gets deleted:**
- ❌ AKS Cluster (all pods, services, configs)
- ❌ Azure Container Registry (all Docker images)
- ❌ PostgreSQL Database (ALL DATA)
- ❌ Virtual Network (subnets, NSGs)
- ❌ All managed identities
- ❌ All role assignments
- ❌ Private DNS zones
- ❌ Log Analytics workspace
- ❌ All public IPs
- ❌ Resource group

**What does NOT get deleted:**
- ✅ Terraform state storage (`terraform-state-rg`)
- ✅ GitHub repository
- ✅ GitHub secrets
- ✅ Source code

### Method 2: Azure Portal (Simpler)

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to **Resource Groups**
3. Select `rg-account-opening-dev-eus2`
4. Click **Delete resource group** (top toolbar)
5. Type the resource group name to confirm
6. Click **Delete**
7. Wait 5-10 minutes

**Advantage:**
- Simpler (one action deletes everything)
- Don't need Terraform installed

**Disadvantage:**
- Terraform state may become inconsistent
- Need to clean up state manually

### Method 3: Azure CLI

```bash
# Delete resource group (deletes all resources inside)
az group delete \
  --name rg-account-opening-dev-eus2 \
  --yes \
  --no-wait

# Check deletion status
az group show \
  --name rg-account-opening-dev-eus2

# If deleted, you'll see an error
```

### Complete Cleanup (Including State)

If you want to remove EVERYTHING including Terraform state:

```bash
# 1. Destroy infrastructure
cd infrastructure/environments/dev
terraform destroy

# 2. Delete Terraform state storage
az group delete \
  --name terraform-state-rg \
  --yes

# 3. Clean local Terraform files
rm -rf .terraform
rm terraform.tfstate*
rm .terraform.lock.hcl
```

**Now your Azure subscription is completely clean.**

### After Destruction

```bash
# Verify resource group deleted
az group show --name rg-account-opening-dev-eus2
# Should return: ResourceGroupNotFound

# List all resource groups
az group list --output table

# Check for any orphaned resources
az resource list --output table
```

### Cost After Destruction

- **Infrastructure cost:** $0/month
- **Terraform state storage:** ~$1-2/month (if kept)
- **GitHub:** $0 (free tier)

### Recreating Infrastructure

To create infrastructure again after destruction:

```bash
cd infrastructure/environments/dev

# Re-initialize Terraform
terraform init

# Create fresh infrastructure
terraform apply
```

See [Creating Brand New Infrastructure](#creating-brand-new-infrastructure) for full steps.

---

## Cost Management

### Monthly Cost Breakdown

#### Development Environment

**Running 24/7:**
| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| AKS Cluster | Standard_B2s (1 node) | $35-50 |
| PostgreSQL Flexible Server | Burstable B1ms | $40-50 |
| Virtual Network | Standard | $5 |
| Load Balancer | Standard | $20 |
| Storage (ACR + DB) | 100 GB | $10 |
| **TOTAL** | | **~$110-135/month** |

**Stopped (nights/weekends - 70% of time):**
| Resource | Monthly Cost |
|----------|--------------|
| AKS Cluster (stopped 70%) | $11-15 |
| PostgreSQL (stopped 70%) | $12-15 |
| Storage (always charged) | $10 |
| Networking (always charged) | $25 |
| **TOTAL** | **~$58-65/month** |
| **Savings vs 24/7** | **~$52-70/month (47%)** |

### Cost Optimization Tips

#### 1. Stop Resources When Not in Use
```bash
# Use scheduled workflows (see Automated Stop/Start above)
# OR manual stop/start daily
```
**Savings: 47-85%**

#### 2. Use Burstable VMs
Already implemented:
- AKS: `Standard_B2s` (burstable)
- PostgreSQL: `B1ms` (burstable)

**Benefits:**
- Lower base cost
- Can burst to full CPU when needed
- Perfect for dev/test

#### 3. Reduce AKS Node Count
```bash
# Scale down to 1 node minimum
az aks nodepool scale \
  --resource-group rg-account-opening-dev-eus2 \
  --cluster-name aks-account-opening-dev-eus2 \
  --name agentpool \
  --node-count 1
```
**Savings: $35-50/month per node removed**

#### 4. Enable AKS Autoscaling
```bash
az aks nodepool update \
  --resource-group rg-account-opening-dev-eus2 \
  --cluster-name aks-account-opening-dev-eus2 \
  --name agentpool \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 3
```
**Benefit: Automatic cost optimization**

#### 5. Use Azure Cost Alerts
```bash
# Create budget alert ($150/month)
az consumption budget create \
  --budget-name account-opening-dev-budget \
  --amount 150 \
  --time-grain Monthly \
  --start-date 2024-01-01 \
  --end-date 2025-12-31 \
  --resource-group rg-account-opening-dev-eus2
```

### Monitoring Costs

**Azure Portal:**
1. Go to Cost Management + Billing
2. Select Subscriptions → Your subscription
3. Click Cost analysis
4. Filter by resource group: `rg-account-opening-dev-eus2`
5. View daily/monthly costs

**Azure CLI:**
```bash
# Get cost for current month
az consumption usage list \
  --start-date 2024-10-01 \
  --end-date 2024-10-31 \
  --query "[?contains(instanceName, 'account-opening')]" \
  --output table
```

---

**See Also:**
- [Deployment Guide](DEPLOYMENT_GUIDE.md)
- [Cost Optimization Guide](COST_OPTIMIZATION_GUIDE.md)
- [Azure Portal Guide](AZURE_PORTAL_GUIDE.md)
