# Azure Portal Guide - Finding Services and External IPs

This guide shows you how to find your services, external IPs, and troubleshoot issues using the Azure Portal.

## Current Status of Your Deployment

✅ **AKS Cluster**: Running  
✅ **PostgreSQL**: Ready  
✅ **Frontend UI**: Running (1/1)  
❌ **Backend Services**: CrashLoopBackOff (PostgreSQL connection timeout)  
🌐 **Frontend External IP**: **68.220.25.83**

---

## Part 1: Finding External IP in Azure Portal

### Method 1: Via Kubernetes Services (Recommended)

1. **Navigate to your AKS cluster**:
   - Go to [Azure Portal](https://portal.azure.com)
   - Search for "aks-account-opening-dev-eus2"
   - Click on your AKS cluster

2. **Go to Services and ingresses**:
   - In the left menu, under **Kubernetes resources**
   - Click **Services and ingresses**
   
3. **Find the LoadBalancer service**:
   - Look for **frontend-ui** in the list
   - The **External IP** column shows: **68.220.25.83**
   - Click on it to see more details

### Method 2: Via Load Balancers

1. **Navigate to Load Balancers**:
   - In Azure Portal, search for "Load balancers"
   - Or go to your resource group: **rg-account-opening-dev-eus2**
   - Click on **Load balancers**

2. **Find the Kubernetes LoadBalancer**:
   - Look for a load balancer named like: **kubernetes** or **kubernetes-abc123**
   - Click on it

3. **Check Frontend IP Configuration**:
   - In the left menu, click **Frontend IP configuration**
   - You'll see the public IP address: **68.220.25.83**

### Method 3: Via Public IP Addresses

1. **Navigate to Public IP addresses**:
   - Go to your resource group: **rg-account-opening-dev-eus2**
   - Or search for "Public IP addresses" in the portal

2. **Find the LoadBalancer IP**:
   - Look for an IP address associated with the load balancer
   - The IP address will be: **68.220.25.83**
   - Associated with: **frontend-ui** service

---

## Part 2: Viewing Services Running in AKS

### Option A: Azure Portal - Workloads View

1. **Navigate to your AKS cluster**:
   - Portal → "aks-account-opening-dev-eus2"

2. **Click on "Workloads"**:
   - Left menu → Kubernetes resources → **Workloads**

3. **View all deployments and pods**:
   You should see:
   - ✅ **frontend-ui** - Running (1/1 pods)
   - ❌ **customer-service** - CrashLoopBackOff
   - ❌ **document-service** - CrashLoopBackOff
   - ❌ **account-service** - CrashLoopBackOff
   - ❌ **notification-service** - CrashLoopBackOff

4. **Click on any deployment** to see:
   - Pod details
   - Logs
   - Events
   - YAML configuration

### Option B: Azure Portal - Services View

1. **Navigate to your AKS cluster**:
   - Portal → "aks-account-opening-dev-eus2"

2. **Click on "Services and ingresses"**:
   - Left menu → Kubernetes resources → **Services and ingresses**

3. **View all services**:
   - **frontend-ui** - LoadBalancer - 68.220.25.83:80
   - **customer-service** - ClusterIP - Internal only
   - **document-service** - ClusterIP - Internal only
   - **account-service** - ClusterIP - Internal only
   - **notification-service** - ClusterIP - Internal only

### Option C: Using Cloud Shell in Portal

1. **Open Cloud Shell**:
   - Click the Cloud Shell icon (>_) in the top toolbar
   - Select **Bash** or **PowerShell**

2. **Connect to your AKS cluster**:
   ```bash
   az aks get-credentials \
     --resource-group rg-account-opening-dev-eus2 \
     --name aks-account-opening-dev-eus2
   ```

3. **View pods**:
   ```bash
   kubectl get pods
   ```

4. **View services**:
   ```bash
   kubectl get services
   ```

5. **Get external IP**:
   ```bash
   kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

---

## Part 3: Current Issue - Why Services Are Not Running

### Problem: Backend Services in CrashLoopBackOff

Your backend services (customer, document, account, notification) are **failing to start** because they **cannot connect to PostgreSQL**.

**Error in logs**:
```
Caused by: org.postgresql.util.PSQLException: The connection attempt failed.
Caused by: java.net.SocketTimeoutException: Connect timed out
```

### Root Cause

Even though PostgreSQL shows as "Ready" in Azure, the pods are timing out when trying to connect. This can happen due to:

1. **PostgreSQL was recently started** - It may still be initializing
2. **Firewall rules** - PostgreSQL firewall may not allow AKS subnet
3. **DNS resolution** - Pods may not be able to resolve PostgreSQL hostname
4. **Network policy** - Virtual network configuration

### Solution: Restart PostgreSQL to Ensure Full Initialization

```powershell
# Stop PostgreSQL
az postgres flexible-server stop `
  --resource-group rg-account-opening-dev-eus2 `
  --name psql-account-opening-dev-eus2

# Wait 30 seconds
Start-Sleep -Seconds 30

# Start PostgreSQL
az postgres flexible-server start `
  --resource-group rg-account-opening-dev-eus2 `
  --name psql-account-opening-dev-eus2

# Wait for PostgreSQL to be fully ready (2-3 minutes)
Start-Sleep -Seconds 180

# Restart all pods to retry connection
kubectl rollout restart deployment/customer-service
kubectl rollout restart deployment/document-service
kubectl rollout restart deployment/account-service
kubectl rollout restart deployment/notification-service

# Wait for pods to restart
Start-Sleep -Seconds 60

# Check pod status
kubectl get pods
```

### Alternative: Use Start Infrastructure Workflow (Recommended)

The **Start Infrastructure** workflow is now fixed to start PostgreSQL BEFORE AKS, ensuring proper startup order:

```powershell
# Use GitHub CLI to start infrastructure properly
gh workflow run "Start Infrastructure" -f environment=dev
```

This will:
1. ✅ Start PostgreSQL first
2. ⏳ Wait 60 seconds for PostgreSQL to be ready
3. ✅ Start AKS cluster
4. ⏳ Wait 30 seconds for pods to connect

---

## Part 4: Viewing in Azure Portal - Step-by-Step with Screenshots

### Finding Your Frontend UI External IP

#### Step 1: Navigate to AKS Cluster
![Navigate to AKS](https://via.placeholder.com/800x400.png?text=Portal+%3E+Search+%22aks-account-opening-dev-eus2%22)

1. Go to: https://portal.azure.com
2. In the search bar at the top, type: **aks-account-opening-dev-eus2**
3. Click on the AKS cluster from search results

#### Step 2: Go to Services and Ingresses
![Services Menu](https://via.placeholder.com/800x400.png?text=Left+Menu+%3E+Kubernetes+Resources+%3E+Services+and+Ingresses)

1. In the left navigation menu
2. Expand **Kubernetes resources**
3. Click **Services and ingresses**

#### Step 3: Find frontend-ui Service
![Frontend UI Service](https://via.placeholder.com/800x400.png?text=frontend-ui+LoadBalancer+68.220.25.83)

You'll see a table with:
- **Name**: frontend-ui
- **Type**: LoadBalancer
- **Cluster IP**: 10.1.133.217
- **External IP**: **68.220.25.83** ← This is what you need!
- **Port**: 80

Click on **frontend-ui** to see more details.

### Viewing Pod Status

#### Step 1: Go to Workloads
![Workloads Menu](https://via.placeholder.com/800x400.png?text=Left+Menu+%3E+Kubernetes+Resources+%3E+Workloads)

1. In the left navigation menu
2. Expand **Kubernetes resources**
3. Click **Workloads**

#### Step 2: View Deployment Status
![Deployment Status](https://via.placeholder.com/800x400.png?text=Deployments+with+Status)

You'll see:
- **frontend-ui**: 1/1 pods running ✅
- **customer-service**: 0/1 pods (CrashLoopBackOff) ❌
- **document-service**: 0/1 pods (CrashLoopBackOff) ❌
- **account-service**: 0/1 pods (CrashLoopBackOff) ❌
- **notification-service**: 0/1 pods (CrashLoopBackOff) ❌

#### Step 3: View Pod Logs
![Pod Logs](https://via.placeholder.com/800x400.png?text=Click+Deployment+%3E+Logs)

1. Click on any deployment (e.g., **customer-service**)
2. Click on the pod name
3. Click **Logs** tab
4. You'll see the PostgreSQL connection error

---

## Part 5: Quick Reference - Portal Navigation

### To Find External IP:
```
Portal → Search "aks-account-opening-dev-eus2" 
→ Services and ingresses 
→ frontend-ui 
→ External IP: 68.220.25.83
```

### To View Running Pods:
```
Portal → Search "aks-account-opening-dev-eus2" 
→ Workloads 
→ See all deployments and pod status
```

### To View Pod Logs:
```
Portal → AKS Cluster 
→ Workloads 
→ Click deployment 
→ Click pod 
→ Logs tab
```

### To View PostgreSQL:
```
Portal → Search "psql-account-opening-dev-eus2" 
→ Overview 
→ Status: Ready/Stopped
```

---

## Part 6: Testing Your Frontend

### Access Your UI

1. **Open browser**: http://68.220.25.83
2. **Expected result**: React UI loads (navigation, forms, etc.)
3. **Current state**: UI loads, but API calls will fail because backend services are down

### Why Backend APIs Fail

The frontend UI is working, but when you try to:
- Create a customer
- Upload a document
- Open an account

These will **fail** because the backend services (customer-service, document-service, etc.) are not running due to the PostgreSQL connection issue.

---

## Part 7: Complete Fix - Step by Step

### Option 1: Quick Fix (Manual)

```powershell
# 1. Restart PostgreSQL to ensure it's fully initialized
az postgres flexible-server restart `
  --resource-group rg-account-opening-dev-eus2 `
  --name psql-account-opening-dev-eus2

# 2. Wait 3 minutes for PostgreSQL to be fully ready
Start-Sleep -Seconds 180

# 3. Delete failing pods (they will be recreated automatically)
kubectl delete pod -l app=customer-service
kubectl delete pod -l app=document-service
kubectl delete pod -l app=account-service
kubectl delete pod -l app=notification-service

# 4. Wait 1 minute for new pods to start
Start-Sleep -Seconds 60

# 5. Check status - all should be Running now
kubectl get pods
```

### Option 2: Automated Fix (Use Workflows)

```powershell
# Stop everything first
gh workflow run "Stop Infrastructure" -f environment=dev

# Wait 5 minutes for shutdown
Start-Sleep -Seconds 300

# Start properly (PostgreSQL first, then AKS)
gh workflow run "Start Infrastructure" -f environment=dev

# Wait 5 minutes for startup
Start-Sleep -Seconds 300

# Check status
kubectl get pods
```

### Option 3: Redeploy Everything

```powershell
# Trigger full deployment with force_run
gh workflow run "Deploy to AKS (Dev & Production)" --ref main -f force_run=true
```

---

## Part 8: After Fix - Verify Everything Works

### 1. Check Pod Status
```powershell
kubectl get pods
```
**Expected**: All pods should show `1/1 Running`

### 2. Check Services
```powershell
kubectl get services
```
**Expected**: frontend-ui should have external IP: 68.220.25.83

### 3. Test Health Endpoints

```powershell
# Frontend health check
curl http://68.220.25.83/health

# Backend API tests (through frontend proxy)
curl http://68.220.25.83/api/customer/customers
curl http://68.220.25.83/api/document/documents
curl http://68.220.25.83/api/account/accounts
curl http://68.220.25.83/api/notification/notifications
```

### 4. Test in Browser

1. Open: http://68.220.25.83
2. Go to Customer Registration
3. Fill form and submit
4. Should show success message
5. Check browser console (F12) - no errors

---

## Summary

### Your Current Status:
- ✅ **Frontend UI**: Running and accessible at http://68.220.25.83
- ❌ **Backend Services**: Down (PostgreSQL connection timeout)
- ✅ **AKS Cluster**: Running
- ✅ **PostgreSQL**: Ready (but may need restart)

### Where to Find External IP in Portal:
1. **Portal → aks-account-opening-dev-eus2 → Services and ingresses → frontend-ui**
2. Look for **External IP** column: **68.220.25.83**

### Where to See Services Running:
1. **Portal → aks-account-opening-dev-eus2 → Workloads**
2. Shows all deployments and their pod status

### Fix the Issue:
```powershell
# Recommended: Use start infrastructure workflow
gh workflow run "Start Infrastructure" -f environment=dev
```

Or see detailed manual fix instructions above.

---

## Need Help?

- **PostgreSQL connection issues**: See Part 3 above
- **Finding external IP**: See Part 1 above
- **Viewing services**: See Part 2 above
- **Complete testing guide**: See [TESTING_GUIDE.md](TESTING_GUIDE.md)
- **Deployment guide**: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
