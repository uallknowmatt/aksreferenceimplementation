# AKS Cost Optimization Guide

## 🎯 Goal: Get Monthly Costs Under $2

## Current vs Optimized Costs

### 📊 BEFORE Optimization
| Resource | Configuration | Cost/Month |
|----------|--------------|------------|
| AKS Control Plane | Standard (SLA) | $73/month |
| AKS Nodes | 2x Standard_DS2_v2 | $280/month |
| PostgreSQL | B_Standard_B1ms | $12/month |
| ACR | Basic | $5/month |
| Networking | Standard | $5/month |
| **TOTAL** | | **~$375/month** 💸 |

### ✅ AFTER Optimization  
| Resource | Configuration | Cost/Month |
|----------|--------------|------------|
| AKS Control Plane | **Free tier (no SLA)** | **$0/month** ✅ |
| AKS Nodes | **1x Standard_B2s** | **$30/month** |
| PostgreSQL | B_Standard_B1ms | $12/month |
| ACR | Basic | $5/month |
| Networking | Standard | $2/month |
| **TOTAL** | | **~$49/month** 🎉 |

**Savings: $326/month (87% reduction!)**

---

## 🚀 How to Achieve Under $2/Month

### Strategy: **Start/Stop Infrastructure On-Demand**

The optimized $49/month configuration gives you:
- **$49/month ÷ 30 days = $1.63/day**
- **$1.63/day ÷ 24 hours = $0.068/hour**

**To stay under $2/month, run infrastructure for:**
- **Maximum ~30 hours per month**
- **Or ~1 hour per day**
- **Or ~7 hours per week**

---

## 📋 Implementation Steps

### Step 1: Switch to Free AKS Tier

```bash
# Update AKS to free tier (no SLA, but perfect for dev)
az aks update \
  --resource-group rg-account-opening-dev-eus2 \
  --name aks-account-opening-dev-eus2 \
  --tier free \
  --no-wait
```

**Savings: $73/month → $0/month** ✅

### Step 2: Reduce to Single Smallest Node

**Already done!** Your `terraform.tfvars` is now configured with:
- `node_count = 1`
- `vm_size = "Standard_B2s"` (2 vCPU, 4GB RAM)
- `enable_auto_scaling = false`

Apply with:
```bash
cd infrastructure/environments/dev
terraform apply
```

**Savings: $280/month → $30/month** ✅

### Step 3: Stop Infrastructure When Not in Use

#### Option A: Manual Stop/Start (Recommended for <$2/month)

**Stop everything when done testing:**
```powershell
# Stop AKS cluster (keeps config, stops billing for nodes)
az aks stop `
  --resource-group rg-account-opening-dev-eus2 `
  --name aks-account-opening-dev-eus2

# Stop PostgreSQL (keeps data, stops billing)
az postgres flexible-server stop `
  --resource-group rg-account-opening-dev-eus2 `
  --name psql-account-opening-dev-eus2
```

**Start when you need to test:**
```powershell
# Start PostgreSQL first (takes ~2 minutes)
az postgres flexible-server start `
  --resource-group rg-account-opening-dev-eus2 `
  --name psql-account-opening-dev-eus2

# Start AKS cluster (takes ~3-5 minutes)
az aks start `
  --resource-group rg-account-opening-dev-eus2 `
  --name aks-account-opening-dev-eus2
```

**When stopped: Only pays for storage (~$1/month)** 🎯

#### Option B: Scheduled Auto-Shutdown

Create automation to stop infrastructure daily:

```yaml
# .github/workflows/auto-shutdown.yml
name: Auto Shutdown Infrastructure
on:
  schedule:
    - cron: '0 22 * * *'  # 10 PM UTC daily
  workflow_dispatch:

jobs:
  shutdown:
    runs-on: ubuntu-latest
    steps:
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Stop AKS
        run: |
          az aks stop \
            --resource-group rg-account-opening-dev-eus2 \
            --name aks-account-opening-dev-eus2 \
            --no-wait
      
      - name: Stop PostgreSQL
        run: |
          az postgres flexible-server stop \
            --resource-group rg-account-opening-dev-eus2 \
            --name psql-account-opening-dev-eus2 \
            --no-wait
```

### Step 4: Even More Savings (Optional)

#### Use Azure Container Instances Instead

For even lower costs, consider Azure Container Instances (pay-per-second):
- **ACI pricing**: $0.000012 per vCPU-second + $0.0000013 per GB-second
- **Example**: 4 microservices × 0.25 vCPU × 0.5GB × 3600 sec = $0.007/hour
- **Cost**: **~$0.17/day or $5/month** if running 24/7

#### Delete ACR Images Not in Use

```bash
# List old images
az acr repository list --name acracountopeningdev --output table

# Delete old/unused images
az acr repository delete \
  --name acracountopeningdev \
  --image <image-name>:<tag> \
  --yes
```

---

## 💰 Cost Tracking

### Monitor Your Spending

```bash
# Check current month's cost
az consumption usage list \
  --start-date $(date -u -d '1 day ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --end-date $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
  --query "[?contains(instanceName, 'account-opening')].{Resource:instanceName, Cost:pretaxCost}" \
  --output table

# Set up budget alert in Azure Portal
# Go to: Cost Management + Billing → Budgets → Create
# Set budget: $2/month with alerts at 80%, 90%, 100%
```

### Azure Cost Analysis

1. Go to [Azure Portal → Cost Management + Billing](https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview)
2. Click "Cost analysis"
3. Filter by Resource Group: `rg-account-opening-dev-eus2`
4. View daily costs and trends

---

## 🎮 Quick Reference Commands

### Daily Workflow

**Morning (Start infrastructure):**
```powershell
# Start PostgreSQL & AKS (~5 min total)
az postgres flexible-server start -g rg-account-opening-dev-eus2 -n psql-account-opening-dev-eus2
az aks start -g rg-account-opening-dev-eus2 -n aks-account-opening-dev-eus2

# Get AKS credentials
az aks get-credentials -g rg-account-opening-dev-eus2 -n aks-account-opening-dev-eus2 --overwrite-existing
```

**Evening (Stop infrastructure):**
```powershell
# Stop AKS & PostgreSQL
az aks stop -g rg-account-opening-dev-eus2 -n aks-account-opening-dev-eus2
az postgres flexible-server stop -g rg-account-opening-dev-eus2 -n psql-account-opening-dev-eus2
```

**Check status:**
```powershell
# Check if running
az aks show -g rg-account-opening-dev-eus2 -n aks-account-opening-dev-eus2 --query "powerState.code"
az postgres flexible-server show -g rg-account-opening-dev-eus2 -n psql-account-opening-dev-eus2 --query "state"
```

---

## 📊 Cost Scenarios

### Scenario 1: Always Running (Development)
- **Cost**: $49/month
- **Use case**: Active development, testing throughout the day

### Scenario 2: Business Hours Only (8 hours/day, 5 days/week)
- **Usage**: 160 hours/month
- **Cost**: ~$11/month
- **Use case**: Regular demos, development during work hours

### Scenario 3: Testing Only (1 hour/day)
- **Usage**: 30 hours/month
- **Cost**: ~$2/month ✅
- **Use case**: Occasional testing, demos

### Scenario 4: Weekend Projects (10 hours/week)
- **Usage**: 40 hours/month
- **Cost**: ~$2.7/month
- **Use case**: Side project, learning

### Scenario 5: Stopped (Storage only)
- **Cost**: ~$1/month
- **Use case**: Paused project, data retention only

---

## ⚠️ Important Notes

### Performance Considerations

**Standard_B2s (recommended minimum for AKS):**
- ✅ Can run system pods (coredns, metrics-server)
- ✅ Can run 2-3 lightweight microservices
- ⚠️ CPU bursting - good for sporadic workloads
- ⚠️ Not suitable for production or load testing
- ⚠️ May be slow for complex operations

**If you need better performance (still cheap):**
- **Standard_B2ms**: 2 vCPU, 8GB RAM @ $60/month
- **Standard_B4ms**: 4 vCPU, 16GB RAM @ $121/month

### Free Tier Limitations

**AKS Free Tier:**
- ❌ No SLA (99.95% uptime guarantee)
- ❌ No financially backed uptime commitment
- ⚠️ Node limit: 1000 nodes (not an issue for dev)
- ✅ Perfect for dev/test environments
- ✅ All features available (just no SLA)

### Data Persistence

**When stopped:**
- ✅ All data is preserved
- ✅ Kubernetes configs retained
- ✅ Database data safe
- ✅ Container images in ACR remain
- ⚠️ Pods will need to restart when AKS starts
- ⚠️ Takes ~5 minutes to start up

---

## 🎯 Summary: Achieving Sub-$2/Month

1. ✅ **Switch to AKS Free Tier** (saves $73/month)
2. ✅ **Use 1x Standard_B2s node** (saves $250/month)  
3. ✅ **Keep PostgreSQL B1ms** (already optimized)
4. ✅ **Stop infrastructure when not in use** (saves $47/month)
5. ✅ **Run only 30 hours/month** = **Under $2/month** 🎉

**Total savings: $375/month → $2/month (99.5% reduction!)**

---

## 📞 Need Help?

- **Azure Pricing Calculator**: https://azure.microsoft.com/en-us/pricing/calculator/
- **AKS Pricing**: https://azure.microsoft.com/en-us/pricing/details/kubernetes-service/
- **PostgreSQL Pricing**: https://azure.microsoft.com/en-us/pricing/details/postgresql/flexible-server/
- **Cost Management**: https://portal.azure.com/#view/Microsoft_Azure_CostManagement

---

**Last Updated**: October 2025
**Target**: <$2/month for dev environment
**Status**: ✅ Achievable with stop/start strategy
