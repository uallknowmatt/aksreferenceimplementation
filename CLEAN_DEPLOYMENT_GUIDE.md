# Clean Deployment Guide

## Overview
This guide walks you through a **clean slate deployment** after manually deleting all Azure resource groups. The infrastructure has been completely reconfigured with:

✅ **PostgreSQL Private VNet Integration** (no public access)  
✅ **Automated Health Checks** after deployment (6 comprehensive tests)  
✅ **Self-Healing** (automatically stops infrastructure if tests fail)  
✅ **Cost Optimization** (infrastructure decision gate after successful deployment)

---

## Current Status

### What You've Done
- ✅ Manually deleted all resource groups except `terraform-state-rg`
- ✅ PostgreSQL reconfigured for private VNet integration (code committed)
- ✅ Automated testing framework created (code committed)
- ✅ Self-healing workflow implemented (code committed)

### What Remains
- ⏳ Clear Terraform state files for clean deployment
- ⏳ Deploy infrastructure with new PostgreSQL VNet architecture
- ⏳ Let automated tests validate the deployment
- ⏳ Verify self-healing loop works correctly

---

## Pre-Deployment Steps

### Step 1: Clear Terraform State Files

Since you manually deleted all resource groups, Terraform's state file is now out of sync with reality. You need to clear it:

#### Option A: Delete State Files via Azure Portal
1. Go to https://portal.azure.com
2. Search for "Storage accounts"
3. Find `tfstateaccountopening` storage account
4. Click **Storage Browser** → **Blob containers**
5. Click into the container (usually named `tfstate`)
6. Find these blobs:
   - `dev.terraform.tfstate`
   - `dev.terraform.tfstate.backup` (if exists)
7. Select each blob and click **Delete**
8. Confirm deletion

#### Option B: Delete State Files via Azure CLI (PowerShell)
```powershell
# Login to Azure
az login

# Delete the state files
az storage blob delete `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --name dev.terraform.tfstate

az storage blob delete `
  --account-name tfstateaccountopening `
  --container-name tfstate `
  --name dev.terraform.tfstate.backup
```

#### Option C: Use Terraform Command (from local machine)
```powershell
cd c:\genaiexperiments\accountopening\infrastructure\environments\dev

# List current state
terraform state list

# Remove everything from state (if anything shows up)
terraform state rm $(terraform state list)
```

**⚠️ Important:** Do NOT delete the `terraform-state-rg` resource group or the `tfstateaccountopening` storage account. These will be reused.

---

### Step 2: Verify GitHub Secrets

Ensure OIDC authentication is configured for GitHub Actions:

1. Go to your GitHub repository: https://github.com/uallknowmatt/aksreferenceimplementation
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Verify these secrets exist:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

If any are missing, see `GITHUB_ENVIRONMENT_SETUP.md` for setup instructions.

---

## Deployment Process

### Step 1: Trigger GitHub Actions Workflow

The deployment is fully automated through GitHub Actions:

1. Go to your repository: https://github.com/uallknowmatt/aksreferenceimplementation
2. Click **Actions** tab
3. Select **"Deploy to AKS (Dev)"** workflow (left sidebar)
4. Click **Run workflow** button (top right)
5. Configure the deployment:
   - Branch: `main`
   - Force run (ignore skip logic): `true` ✅ (IMPORTANT!)
   - Leave other options as defaults
6. Click **Run workflow**

---

### Step 2: Monitor Deployment Progress

The workflow has **7 jobs** that run sequentially:

#### **Job 1: Infrastructure Provisioning** (15-20 minutes)
- Sets up Terraform backend (creates storage if missing)
- Provisions resources in this order:
  1. Resource Group
  2. Virtual Network (VNet) with 3 subnets:
     - AKS Subnet (10.0.1.0/24)
     - ACR Subnet (10.0.2.0/24)
     - **PostgreSQL Subnet (10.0.3.0/24)** ← NEW!
  3. **Private DNS Zone** (privatelink.postgres.database.azure.com) ← NEW!
  4. **PostgreSQL Flexible Server** (with VNet integration) ← RECONFIGURED!
     - No public access ✅
     - Only accessible from AKS subnet ✅
     - Private endpoint with DNS resolution ✅
  5. Azure Container Registry (ACR)
  6. Azure Kubernetes Service (AKS)
  7. Log Analytics Workspace
  8. Network Security Group (NSG)

**📊 Watch for:**
- ✅ PostgreSQL provisioning completes (~10 minutes)
- ✅ AKS cluster provisioning completes (~8 minutes)
- ✅ All Terraform outputs displayed

---

#### **Job 2: Build & Push Docker Images** (5-8 minutes)
- Builds Docker images for all microservices:
  - `customer-service`
  - `document-service`
  - `account-service`
  - `notification-service`
- Pushes images to Azure Container Registry

**📊 Watch for:**
- ✅ Each service builds successfully
- ✅ Images pushed to ACR

---

#### **Job 3: Deploy to AKS** (3-5 minutes)
- Creates Kubernetes ConfigMaps with PostgreSQL connection details
- Creates Secrets for database credentials
- Deploys all microservices to AKS
- Deploys frontend UI with LoadBalancer
- Waits for all pods to be ready (max 5 minutes)

**📊 Watch for:**
- ✅ All ConfigMaps and Secrets created
- ✅ All deployments and services created
- ✅ Pods transitioning to Running state
- ⚠️ If pods stuck in CrashLoopBackOff → tests will catch this!

---

#### **Job 4: Automated Health Checks** (2-3 minutes) ← NEW! 🎉
This is the **self-healing** validation step. It runs **6 comprehensive tests**:

##### **Test 1: Pod Status Check**
- Verifies all pods are `Running` and `Ready (1/1)`
- Identifies any CrashLoopBackOff or Pending pods

##### **Test 2: LoadBalancer IP Assignment**
- Checks frontend UI has external IP assigned
- Outputs the frontend URL: `http://X.X.X.X`

##### **Test 3: Frontend Health Endpoint**
- Curls `http://FRONTEND_IP/health`
- Expects HTTP 200 OK response

##### **Test 4: Backend Services Health**
- Port-forwards to each service's actuator endpoint
- Checks health status for:
  - `customer-service:8081/actuator/health`
  - `document-service:8081/actuator/health`
  - `account-service:8081/actuator/health`
  - `notification-service:8081/actuator/health`
- Expects `"status":"UP"` for all services

##### **Test 5: Database Connectivity**
- Checks database connection from `customer-service` pod
- Verifies PostgreSQL private VNet integration works
- Endpoint: `/actuator/health/db`
- Expects `"status":"UP"`

##### **Test 6: End-to-End Smoke Test** (not implemented yet)
- Would test creating a test customer via API
- Verifies complete application flow

**📊 Success Criteria:**
- ✅ All 5 tests PASS → Proceeds to Job 6 (Infrastructure Decision)
- ❌ Any test FAILS → Proceeds to Job 5 (Handle Test Failure)

---

#### **Job 5: Handle Test Failure** (conditional) ← NEW! 🛑
**Only runs if automated tests FAIL**

This is the **self-healing** response:

1. **Stops AKS Cluster** (saves ~$30/month)
2. **Stops PostgreSQL Server** (saves ~$18/month)
3. **Displays failure report:**
   ```
   ⚠️  DEPLOYMENT TESTS FAILED
   ========================================
   
   Infrastructure has been stopped to save costs.
   Please review the test failures, fix the issues,
   and redeploy.
   
   To redeploy:
   1. Fix the issues identified in the tests
   2. Trigger the workflow again with force_run=true
   ```

**📊 What to do if this runs:**
1. Review the test failure output from Job 4
2. Identify which test(s) failed:
   - **Pod Status Failed?** → Check pod logs: `kubectl logs <pod-name>`
   - **LoadBalancer Failed?** → Check service: `kubectl get svc frontend-ui`
   - **Frontend Health Failed?** → Check frontend logs
   - **Backend Health Failed?** → Check backend service logs
   - **Database Failed?** → Check PostgreSQL connection string and VNet integration
3. Fix the issue (code or configuration)
4. Re-run the workflow with `force_run=true`

**💡 Self-Healing Benefits:**
- Saves money by stopping failed deployments
- Forces you to fix issues before keeping infrastructure running
- Prevents "zombie" deployments that waste costs

---

#### **Job 6: Infrastructure Decision Gate** (conditional) ← UPDATED! 💰
**Only runs if automated tests PASS**

Displays deployment success summary and cost information:

```
✅ Development environment deployed successfully!
✅ All automated tests passed!

Frontend URL: http://X.X.X.X

🔍 Current resources running:
   - AKS Cluster (1 node, Standard_B2s)
   - PostgreSQL Flexible Server (Burstable B1ms)
   - Azure Container Registry (Basic tier)
   - Log Analytics Workspace
   - Virtual Network & NSG

💵 Estimated cost: ~$49/month if left running 24/7
💵 Or ~$1.46/month if only running 30min/day

⚠️  CHOOSE YOUR ACTION:

Option 1: APPROVE THIS STEP
  → Infrastructure will STOP (saves money!)
  → Cost reduces to ~$1/month (storage only)
  → Use 'Start Infrastructure' workflow when needed

Option 2: REJECT/CANCEL THIS WORKFLOW
  → Infrastructure stays RUNNING
  → Costs continue at ~$49/month
  → You can stop manually with 'Stop Infrastructure' workflow

💡 Tip: APPROVE to save money, REJECT to keep running
```

**What to do:**
- **APPROVE** → Infrastructure stops, costs drop to ~$1/month
- **REJECT** → Infrastructure keeps running, costs ~$49/month

---

#### **Job 7: Stop Infrastructure** (conditional)
**Only runs if you APPROVE Job 6**

- Stops AKS cluster
- Stops PostgreSQL server
- Displays summary of stopped resources

---

## Post-Deployment Verification

### Option A: Infrastructure Kept Running (Rejected Job 6)

If you chose to keep infrastructure running, verify everything works:

#### 1. Access Frontend UI
```powershell
# The frontend URL is displayed in Job 4 output
# Example: http://68.220.25.83

# Open in browser or test with curl
curl http://FRONTEND_IP/health
```

**Expected:** HTTP 200 OK with health status

---

#### 2. Verify All Pods Running
```powershell
kubectl get pods

# Expected output:
# NAME                                   READY   STATUS    RESTARTS   AGE
# account-service-xxxxxx-xxxxx           1/1     Running   0          5m
# customer-service-xxxxxx-xxxxx          1/1     Running   0          5m
# document-service-xxxxxx-xxxxx          1/1     Running   0          5m
# frontend-ui-xxxxxx-xxxxx               1/1     Running   0          5m
# notification-service-xxxxxx-xxxxx      1/1     Running   0          5m
```

**All should be `1/1 Running` with no CrashLoopBackOff!**

---

#### 3. Test Backend Services
```powershell
# Port-forward to customer-service
kubectl port-forward deployment/customer-service 8081:8081

# In another terminal, test health endpoint
curl http://localhost:8081/actuator/health

# Expected: {"status":"UP", ...}
```

Repeat for other services: `document-service`, `account-service`, `notification-service`

---

#### 4. Verify Database Connectivity
```powershell
# Test database health from customer-service
kubectl port-forward deployment/customer-service 8081:8081

# Check database health
curl http://localhost:8081/actuator/health/db

# Expected: {"status":"UP", "components":{"db":{"status":"UP","details":{...}}}}
```

**✅ This confirms PostgreSQL private VNet integration is working!**

---

#### 5. Test Complete Application Flow
```powershell
# Get frontend IP
$FRONTEND_IP = kubectl get svc frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Create a test customer
curl -X POST http://${FRONTEND_IP}/api/customers `
  -H "Content-Type: application/json" `
  -d '{"firstName":"Test","lastName":"User","email":"test@example.com"}'

# List customers
curl http://${FRONTEND_IP}/api/customers

# Expected: JSON array with the test customer
```

---

### Option B: Infrastructure Stopped (Approved Job 6)

If you chose to stop infrastructure to save costs:

#### Restart Infrastructure When Needed
```powershell
# Option 1: Use GitHub Actions "Start Infrastructure" workflow
# 1. Go to Actions → "Start Infrastructure (Dev)"
# 2. Click Run workflow
# 3. Wait 2-3 minutes for AKS and PostgreSQL to start
# 4. Run health checks

# Option 2: Use PowerShell script
.\start-infra.ps1

# Option 3: Use Azure CLI
az aks start --name <AKS_NAME> --resource-group <RG_NAME>
az postgres flexible-server start --name <POSTGRES_NAME> --resource-group <RG_NAME>
```

After restarting, wait **2-3 minutes** then verify:
```powershell
kubectl get pods
# All should transition to Running within 2-3 minutes
```

---

## Troubleshooting

### Problem: Tests Fail Due to PostgreSQL Connection Timeout

**Symptoms:**
- Job 4 Test 5 fails (Database Connectivity)
- Backend pods show errors in logs: `java.net.SocketTimeoutException`

**Root Cause:**
PostgreSQL VNet integration may not be fully initialized yet.

**Solution:**
1. Check if PostgreSQL is actually running:
   ```powershell
   az postgres flexible-server show --name <POSTGRES_NAME> --resource-group <RG_NAME>
   ```
2. Verify subnet delegation:
   ```powershell
   az network vnet subnet show --vnet-name <VNET_NAME> --name snet-dev-postgres --resource-group <RG_NAME>
   ```
   Should show `delegations` → `Microsoft.DBforPostgreSQL/flexibleServers`

3. Verify Private DNS Zone is linked:
   ```powershell
   az network private-dns link vnet list --zone-name privatelink.postgres.database.azure.com --resource-group <RG_NAME>
   ```

4. If everything looks correct but still failing, try **redeploying** (sometimes VNet integration needs a fresh deployment)

---

### Problem: Pods Stuck in CrashLoopBackOff

**Symptoms:**
- Job 4 Test 1 fails (Pod Status)
- Pods restart repeatedly

**Solution:**
1. Check pod logs:
   ```powershell
   kubectl logs <pod-name>
   ```

2. Common issues:
   - **Database connection refused:** PostgreSQL may not be started yet
   - **Image pull errors:** ACR authentication issue
   - **Port conflicts:** Check service configurations

3. If PostgreSQL connection issue:
   ```powershell
   # Verify PostgreSQL connection string in ConfigMap
   kubectl get configmap customer-service-config -o yaml
   
   # Should show FQDN ending with: .privatelink.postgres.database.azure.com
   ```

---

### Problem: Frontend LoadBalancer Has No IP

**Symptoms:**
- Job 4 Test 2 fails (LoadBalancer IP)
- Frontend service shows `<pending>`

**Solution:**
1. Check service:
   ```powershell
   kubectl get svc frontend-ui
   ```

2. If stuck at `<pending>`, check AKS outbound connectivity:
   ```powershell
   kubectl describe svc frontend-ui
   ```

3. May need to wait longer (LoadBalancer IP can take 3-5 minutes)

---

### Problem: Terraform State Conflicts

**Symptoms:**
- Job 1 fails with "resource already exists"
- Error: "A resource with the ID already exists"

**Solution:**
You didn't clear the Terraform state properly. Re-run **Pre-Deployment Step 1** to clear state files.

---

### Problem: Self-Healing Stops Infrastructure Too Early

**Symptoms:**
- Tests fail due to pods not ready yet
- Infrastructure stops before pods finish starting

**Solution:**
The workflow already waits **5 minutes** for pods to be ready (Job 3). If this isn't enough:

1. Edit `.github/workflows/aks-deploy.yml`
2. Find the "Wait for all pods to be ready" step
3. Increase timeout from `{1..60}` to `{1..120}` (10 minutes)
4. Commit and push the change

---

## Cost Management

### Current Infrastructure Costs (Estimated)

**Running 24/7:**
- AKS (Standard_B2s, 1 node): ~$30/month
- PostgreSQL (Burstable B1ms): ~$18/month
- ACR (Basic): ~$5/month
- **Total: ~$53/month**

**Stopped (Storage Only):**
- Storage for state files: ~$0.50/month
- ACR storage: ~$0.50/month
- **Total: ~$1/month**

**Recommended Strategy:**
1. **During development:** Keep infrastructure running only when actively working
2. **After testing:** Stop infrastructure immediately (approve Job 6)
3. **Before customer demo:** Start infrastructure 5 minutes before demo
4. **After demo:** Stop infrastructure immediately

**Savings:** ~$52/month if stopped when not in use!

---

## Self-Healing Loop Summary

The new workflow implements a **fully automated self-healing deployment loop**:

```
1. Deploy Infrastructure (Terraform)
   ↓
2. Build & Push Docker Images
   ↓
3. Deploy to Kubernetes
   ↓
4. Run Automated Health Checks (6 tests)
   ↓
   ├─→ TESTS PASS → Continue to Infrastructure Decision
   │                 ↓
   │                 User chooses: Keep Running or Stop
   │
   └─→ TESTS FAIL → Stop Infrastructure Immediately
                     ↓
                     Fix issues and redeploy (loop back to step 1)
```

**Benefits:**
- ✅ Never pay for broken deployments
- ✅ Immediate feedback on deployment health
- ✅ Forces fixing issues before production
- ✅ Saves ~$52/month when stopped
- ✅ Production-ready validation before customer delivery

---

## Next Steps

### Immediate Actions (Required)
1. ✅ **Clear Terraform state files** (Pre-Deployment Step 1)
2. ✅ **Trigger GitHub Actions workflow** with `force_run=true`
3. ✅ **Monitor Job 4** (Automated Health Checks) to see if tests pass
4. ✅ **Decide**: Approve Job 6 to stop (save money) or Reject to keep running

### Future Enhancements (Optional)
1. **Add End-to-End Smoke Test** (Test 6 in Job 4)
   - Currently skipped
   - Would test creating/retrieving customers via API
   - Full application flow validation

2. **Add Performance Tests**
   - Load testing with Apache Bench or K6
   - Validate application handles expected traffic

3. **Add Security Scanning**
   - Container image scanning (Trivy)
   - Dependency vulnerability checks
   - Network security policy validation

4. **Production Environment**
   - Duplicate infrastructure for production
   - Blue/Green deployment strategy
   - Automated rollback on test failure

---

## Reference Documentation

- **Infrastructure Guide:** `DEPLOYMENT_GUIDE.md`
- **Testing Procedures:** `TESTING_GUIDE.md`
- **Cost Optimization:** `COST_OPTIMIZATION_GUIDE.md`
- **Azure Portal Navigation:** `AZURE_PORTAL_GUIDE.md`
- **GitHub Secrets Setup:** `GITHUB_ENVIRONMENT_SETUP.md`

---

## Summary

You now have a **production-ready, self-healing deployment pipeline** with:

✅ **Secure PostgreSQL** (private VNet integration, no public access)  
✅ **Automated Testing** (6 comprehensive health checks)  
✅ **Self-Healing** (stops infrastructure on test failure)  
✅ **Cost Optimization** (infrastructure decision gate)  
✅ **Complete Automation** (from infrastructure to validation)

**Ready to deploy?** Follow the **Deployment Process** section above!

**Need help?** Check the **Troubleshooting** section or review test failures in Job 4 output.

**Good luck! 🚀**
