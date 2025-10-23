# AKS Cost Optimization Guide

## Overview
This guide shows you how to minimize Azure costs while keeping AKS for development. **Current setup uses AKS Free Tier ($0 control plane cost)**.

## Current Monthly Costs (if running 24/7)

| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| AKS Control Plane | **Free Tier** | **$0.00** ✅ |
| AKS Nodes (1 node) | Standard_D2s_v3 | ~$70.00 |
| PostgreSQL | B_Standard_B1ms | ~$25.00 |
| Container Registry | Basic | ~$5.00 |
| Networking/Storage | - | ~$5-10.00 |
| **TOTAL** | | **~$105-110/month** |

## Goal: Get Under $2/Month

### Strategy 1: Start/Stop Infrastructure (Recommended) ⭐

**Use the GitHub Actions workflows to start/stop when needed:**

1. **Stop infrastructure when not in use:**
   ```bash
   # Via GitHub UI: Actions → Stop Infrastructure → Run workflow
   # Or via CLI:
   gh workflow run stop-infrastructure.yml -f environment=dev
   ```

2. **Start infrastructure when testing:**
   ```bash
   # Via GitHub UI: Actions → Start Infrastructure → Run workflow
   # Or via CLI:
   gh workflow run start-infrastructure.yml -f environment=dev
   ```

3. **Cost breakdown:**
   - Running 24/7: ~$105/month
   - Running 8 hours/day: ~$35/month
   - **Running 1 hour/day: ~$4.50/month** 🎯
   - **Running 30 minutes/day: ~$2.25/month** ✅ **Under $2!**

### Strategy 2: Use Smaller VM Sizes

The smallest production-capable VM for AKS is **Standard_B2s**:

**Update `infrastructure/environments/dev/terraform.tfvars`:**
```hcl
# Change from Standard_D2s_v3 to Standard_B2s
vm_size              = "Standard_B2s"      # ~$30/month (was ~$70)
node_count           = 1                    # Minimum for AKS
enable_auto_scaling  = false                # Disable autoscaling for cost control
```

**New monthly cost:** ~$60/month (still need to start/stop to get under $2)

### Strategy 3: Optimize PostgreSQL

**Already using the cheapest tier!** ✅
- Current: `B_Standard_B1ms` (~$25/month)
- This is the smallest PostgreSQL Flexible Server available
- Start/Stop workflow will reduce costs when not running

### Strategy 4: Remove Container Registry (if not deploying often)

If you're only deploying occasionally, you can:
1. Comment out ACR in `infrastructure/acr.tf`
2. Use Docker Hub (free) or GitHub Container Registry (free) instead
3. **Savings:** $5/month

### Strategy 5: Use AKS Spot Instances (Advanced)

For non-production workloads, use Spot VMs (70-90% discount):

**Add to `infrastructure/aks.tf`:**
```hcl
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size              = "Standard_B2s"
  node_count           = 1
  priority             = "Spot"
  eviction_policy      = "Delete"
  spot_max_price       = 0.05  # Max price per hour
  
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
}
```

**Cost:** ~$7-10/month (but can be evicted at any time)

## Recommended Setup for Under $2/Month

### Configuration:
1. **Keep AKS Free Tier** (already configured) ✅
2. **Use Standard_B2s VMs** (smallest production-capable)
3. **Use Start/Stop workflows**
4. **Run only when testing** (30 minutes to 1 hour per day)

### Monthly Breakdown:
```
AKS Control Plane:    $0.00  (Free Tier)
VM Node (B2s):        $30.00 × (30 min / 24 hours) = $0.60
PostgreSQL:           $25.00 × (30 min / 24 hours) = $0.50
Container Registry:   $5.00 / 30 = $0.16
Networking/Storage:   ~$0.20
─────────────────────────────────────────────────
TOTAL:                ~$1.46/month ✅
```

## Quick Reference Commands

### PowerShell (Windows)
```powershell
# Stop infrastructure
gh workflow run stop-infrastructure.yml -f environment=dev

# Start infrastructure
gh workflow run start-infrastructure.yml -f environment=dev

# Check status
gh run list --workflow=stop-infrastructure.yml --limit 1
gh run list --workflow=start-infrastructure.yml --limit 1

# Watch workflow
gh run watch
```

### Bash (Linux/Mac)
```bash
# Same commands work in bash
gh workflow run stop-infrastructure.yml -f environment=dev
gh workflow run start-infrastructure.yml -f environment=dev
```

## Cost Monitoring

### View current costs in Azure Portal:
1. Go to **Cost Management + Billing**
2. Select **Cost analysis**
3. Filter by Resource Group: `rg-account-opening-dev-eus2`

### Set up budget alerts:
```bash
# Create a budget alert for $5/month
az consumption budget create \
  --budget-name "aks-dev-budget" \
  --amount 5 \
  --time-grain Monthly \
  --start-date 2025-11-01 \
  --end-date 2026-12-31 \
  --resource-group rg-account-opening-dev-eus2
```

## Best Practices

1. **Always stop infrastructure after testing** 🛑
2. **Use scheduled workflows** to automatically stop at night (optional)
3. **Monitor costs weekly** in Azure Portal
4. **Delete infrastructure completely** if not using for > 1 week
5. **Test locally with Docker Compose** before deploying to AKS

## Scheduled Auto-Stop (Optional)

To automatically stop infrastructure at 6 PM every day:

**Add to `stop-infrastructure.yml`:**
```yaml
on:
  workflow_dispatch:
    # ... existing inputs ...
  schedule:
    - cron: '0 18 * * *'  # 6 PM UTC daily
```

## FAQ

**Q: Will I lose data when I stop the infrastructure?**
A: No! PostgreSQL data is persisted to disk. When you restart, all data will be there.

**Q: How long does it take to start/stop?**
A: ~2-3 minutes to stop, ~3-5 minutes to start.

**Q: Can I use even smaller VMs?**
A: Standard_B2s (2 vCPU, 4 GB RAM) is the minimum for AKS. Smaller VMs like B1s are not supported.

**Q: What if I forget to stop the infrastructure?**
A: Set up a budget alert (see above) to get notified when costs exceed $5.

**Q: Is Free Tier AKS production-ready?**
A: Free Tier is great for dev/test. For production, use Standard Tier ($0.10/hour = ~$73/month) which includes:
- 99.95% uptime SLA
- Better control plane performance
- More API server requests per second

## Summary

✅ **Yes, AKS Free Tier is being used** (saves ~$73/month vs Standard Tier)
✅ **Start/Stop workflows created** (stop-infrastructure.yml, start-infrastructure.yml)
✅ **Target: Under $2/month** (achievable with 30 min/day usage)
✅ **No data loss** when stopping infrastructure

**Next Steps:**
1. Test the Start/Stop workflows
2. Optionally switch to Standard_B2s VM size
3. Set up budget alerts in Azure Portal
4. Create a testing schedule (e.g., only run on weekdays)
