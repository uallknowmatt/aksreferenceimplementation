# Testing Guide - Azure Deployment

This guide explains how to test your deployed application in Azure, including finding external IPs, accessing the UI, and testing backend services.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Finding External IPs](#finding-external-ips)
- [Testing the Frontend UI](#testing-the-frontend-ui)
- [Testing Backend Services](#testing-backend-services)
- [Health Checks](#health-checks)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before testing, ensure:
1. ✅ Infrastructure is deployed (AKS, PostgreSQL, etc.)
2. ✅ Application is deployed to AKS
3. ✅ You have `kubectl` configured for your AKS cluster
4. ✅ Infrastructure is **started** (not stopped)

### Connect to AKS Cluster

```powershell
# Login to Azure
az login

# Get AKS credentials (replace with your environment: dev or prod)
az aks get-credentials `
  --resource-group rg-account-opening-dev-eus2 `
  --name aks-account-opening-dev-eus2 `
  --overwrite-existing

# Verify connection
kubectl get nodes
```

---

## Finding External IPs

### Method 1: Using kubectl

```powershell
# Get all services and their external IPs
kubectl get services

# Output will look like:
# NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)
# customer-service       ClusterIP      10.0.100.10    <none>           80/TCP
# document-service       ClusterIP      10.0.100.20    <none>           80/TCP
# account-service        ClusterIP      10.0.100.30    <none>           80/TCP
# notification-service   ClusterIP      10.0.100.40    <none>           80/TCP
# frontend-ui            LoadBalancer   10.0.100.50    68.220.25.83     80:30080/TCP
```

### Method 2: Get Frontend UI IP Only

```powershell
# Get frontend UI external IP
kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Example output: 68.220.25.83
```

### Method 3: Check GitHub Actions Output

After deployment completes, the workflow displays the LoadBalancer IP:

1. Go to **GitHub Actions**
2. Click on your latest workflow run
3. Open the **"Deploy to AKS (Dev)"** job
4. Scroll to the **"Get Service Information"** step
5. Look for the output:
   ```
   🌐 Frontend UI Available at: http://68.220.25.83
   ```

### ⚠️ If External IP Shows `<pending>`

If the external IP shows `<pending>`, wait 2-3 minutes for Azure to assign it:

```powershell
# Watch until IP is assigned
kubectl get service frontend-ui --watch

# Press Ctrl+C to stop watching
```

---

## Testing the Frontend UI

### Access the UI

1. **Get the Frontend LoadBalancer IP** (from steps above)
2. **Open in browser**: `http://<EXTERNAL-IP>`
   
   Example: **http://68.220.25.83**

3. **Expected result**: React application loads successfully

### Test UI Functionality

#### 1. Customer Registration
- Navigate to "Customer Registration" page
- Fill in customer details:
  - First Name: John
  - Last Name: Doe
  - Email: john.doe@example.com
  - Phone: +1-555-123-4567
  - Date of Birth: 01/01/1990
- Click "Submit"
- ✅ Success message should appear

#### 2. Document Upload
- Navigate to "Document Upload" page
- Select customer (from dropdown)
- Upload a document (PDF, JPG, or PNG)
- Add document type (e.g., "Passport", "Driver's License")
- Click "Upload"
- ✅ Upload success message should appear

#### 3. Account Opening
- Navigate to "Account Opening" page
- Select customer
- Choose account type (Savings/Checking)
- Set initial deposit amount
- Click "Open Account"
- ✅ Account created message with account number

#### 4. Notifications
- Navigate to "Notifications" page
- View notification history
- ✅ All previous actions should show notifications

### Browser Console Testing

Open browser DevTools (F12) → Console tab:

```javascript
// Check if UI can reach backend
console.log("Testing API connectivity...");

// APIs are proxied through nginx
// /api/customer -> customer-service
// /api/document -> document-service
// /api/account -> account-service
// /api/notification -> notification-service
```

Look for successful API calls (200 status codes) in the Network tab.

---

## Testing Backend Services

Backend services are **internal only** (ClusterIP), but you can test them through the frontend UI's nginx proxy.

### Method 1: Via Frontend Proxy (Recommended)

The frontend UI proxies all API calls through nginx:

```bash
# Test customer service API through frontend
curl http://<FRONTEND-IP>/api/customer/customers

# Test document service
curl http://<FRONTEND-IP>/api/document/documents

# Test account service
curl http://<FRONTEND-IP>/api/account/accounts

# Test notification service
curl http://<FRONTEND-IP>/api/notification/notifications
```

### Method 2: Port Forwarding (Direct Access)

For direct access to backend services:

```powershell
# Forward customer-service to localhost
kubectl port-forward service/customer-service 8081:80

# In another terminal, test it
curl http://localhost:8081/api/customers
```

Repeat for other services:
```powershell
# Document Service
kubectl port-forward service/document-service 8082:80

# Account Service
kubectl port-forward service/account-service 8083:80

# Notification Service
kubectl port-forward service/notification-service 8084:80
```

### Method 3: Exec into Frontend Pod

```powershell
# Get frontend pod name
kubectl get pods -l app=frontend-ui

# Exec into the pod
kubectl exec -it <frontend-pod-name> -- sh

# Test backend services from inside the cluster
curl http://customer-service/api/customers
curl http://document-service/api/documents
curl http://account-service/api/accounts
curl http://notification-service/api/notifications

# Exit the pod
exit
```

---

## Health Checks

### Frontend Health Check

```powershell
# Check frontend health endpoint
curl http://<FRONTEND-IP>/health

# Expected output:
# {
#   "status": "healthy",
#   "nginx": "running"
# }
```

### Backend Health Checks (via Port Forward)

```powershell
# Customer Service
kubectl port-forward service/customer-service 8081:80
curl http://localhost:8081/actuator/health

# Document Service
kubectl port-forward service/document-service 8082:80
curl http://localhost:8082/actuator/health

# Account Service
kubectl port-forward service/account-service 8083:80
curl http://localhost:8083/actuator/health

# Notification Service
kubectl port-forward service/notification-service 8084:80
curl http://localhost:8084/actuator/health
```

Expected output for each:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    },
    "diskSpace": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

---

## Pod Status and Logs

### Check Pod Status

```powershell
# Get all pods
kubectl get pods

# Expected output (all pods Running with 1/1 ready):
# NAME                                   READY   STATUS    RESTARTS   AGE
# customer-service-xxxx-yyyy             1/1     Running   0          5m
# document-service-xxxx-yyyy             1/1     Running   0          5m
# account-service-xxxx-yyyy              1/1     Running   0          5m
# notification-service-xxxx-yyyy         1/1     Running   0          5m
# frontend-ui-xxxx-yyyy                  1/1     Running   0          5m
```

### Check Pod Logs

```powershell
# View logs for a specific service
kubectl logs -l app=customer-service --tail=50

# Follow logs in real-time
kubectl logs -l app=customer-service --follow

# Check for errors
kubectl logs -l app=account-service | Select-String "ERROR"
```

### Check Recent Events

```powershell
# Get recent cluster events
kubectl get events --sort-by='.lastTimestamp'

# Filter for warnings or errors
kubectl get events --field-selector type=Warning
```

---

## Database Testing

### Connect to PostgreSQL

```powershell
# Get PostgreSQL hostname
kubectl get configmap customer-service-config -o jsonpath='{.data.POSTGRES_HOST}'

# Connect using Azure CLI (replace with your values)
az postgres flexible-server execute `
  --name psql-account-opening-dev-eus2 `
  --admin-user psqladmin `
  --admin-password "YourPassword" `
  --database-name customerdb `
  --query-text "SELECT COUNT(*) FROM customers;"
```

### Test Database Connectivity from Pods

```powershell
# Exec into customer-service pod
kubectl get pods -l app=customer-service
kubectl exec -it <customer-service-pod> -- sh

# Try connecting to database (inside pod)
psql -h $POSTGRES_HOST -U psqladmin -d customerdb -c "SELECT 1;"

# Exit
exit
```

---

## Troubleshooting

### Issue: Can't Access Frontend UI

**Symptom**: Browser shows "Can't reach this site" at `http://<EXTERNAL-IP>`

**Solutions**:

1. **Check if infrastructure is running**:
   ```powershell
   # Check AKS status
   az aks show --resource-group rg-account-opening-dev-eus2 --name aks-account-opening-dev-eus2 --query "powerState"
   
   # If stopped, start it:
   gh workflow run "Start Infrastructure" -f environment=dev
   ```

2. **Check if LoadBalancer has IP**:
   ```powershell
   kubectl get service frontend-ui
   # If <pending>, wait 2-3 minutes
   ```

3. **Check NSG rules**:
   ```powershell
   # Verify port 80 is allowed
   az network nsg rule list `
     --resource-group rg-account-opening-dev-eus2 `
     --nsg-name dev-aks-nsg `
     --query "[?direction=='Inbound' && destinationPortRange=='80']"
   ```

4. **Check pod status**:
   ```powershell
   kubectl get pods -l app=frontend-ui
   # Should show Running with 1/1 ready
   ```

### Issue: API Calls Failing

**Symptom**: UI loads but API calls return errors

**Solutions**:

1. **Check backend pod status**:
   ```powershell
   kubectl get pods
   # All pods should be Running
   ```

2. **Check backend logs**:
   ```powershell
   kubectl logs -l app=customer-service --tail=100
   kubectl logs -l app=account-service --tail=100
   ```

3. **Check database connectivity**:
   ```powershell
   # See if pods can reach PostgreSQL
   kubectl logs -l app=customer-service | Select-String "connection"
   ```

4. **Check PostgreSQL is running**:
   ```powershell
   az postgres flexible-server show `
     --resource-group rg-account-opening-dev-eus2 `
     --name psql-account-opening-dev-eus2 `
     --query "state"
   # Should show "Ready"
   ```

### Issue: Pods in CrashLoopBackOff

**Symptom**: Pods keep restarting

**Solutions**:

1. **Check pod logs**:
   ```powershell
   kubectl logs <pod-name> --previous
   ```

2. **Describe the pod**:
   ```powershell
   kubectl describe pod <pod-name>
   ```

3. **Common causes**:
   - Database connection timeout (PostgreSQL not started)
   - Wrong database credentials
   - Not enough resources on node
   - Image pull errors

### Issue: External IP Shows `<pending>` Forever

**Symptom**: LoadBalancer doesn't get an IP after 5+ minutes

**Solutions**:

1. **Check LoadBalancer service**:
   ```powershell
   kubectl describe service frontend-ui
   ```

2. **Check AKS load balancer quota**:
   ```powershell
   az network lb list --resource-group MC_rg-account-opening-dev-eus2_*
   ```

3. **Recreate the service**:
   ```powershell
   kubectl delete service frontend-ui
   kubectl apply -f k8s/frontend-ui-service.yaml
   ```

---

## Complete Test Checklist

Use this checklist after each deployment:

### Infrastructure
- [ ] AKS cluster is running
- [ ] PostgreSQL is running
- [ ] All pods are in Running state (1/1 ready)
- [ ] Frontend LoadBalancer has external IP assigned

### Frontend UI
- [ ] UI loads at `http://<EXTERNAL-IP>`
- [ ] No console errors in browser
- [ ] All pages load successfully
- [ ] Can navigate between pages

### API Functionality
- [ ] Create customer successfully
- [ ] Upload document successfully
- [ ] Open account successfully
- [ ] View notifications successfully
- [ ] Data persists after page refresh

### Backend Health
- [ ] All health endpoints return UP status
- [ ] No ERROR logs in pod logs
- [ ] Database connections working

### Performance
- [ ] Page loads in < 3 seconds
- [ ] API responses in < 1 second
- [ ] No timeout errors

---

## Quick Reference Commands

```powershell
# Connect to cluster
az aks get-credentials --resource-group rg-account-opening-dev-eus2 --name aks-account-opening-dev-eus2

# Get frontend IP
kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Check all pods
kubectl get pods

# View logs
kubectl logs -l app=customer-service --tail=50

# Check services
kubectl get services

# Port forward for direct backend access
kubectl port-forward service/customer-service 8081:80

# Start infrastructure (if stopped)
gh workflow run "Start Infrastructure" -f environment=dev

# Stop infrastructure (to save costs)
gh workflow run "Stop Infrastructure" -f environment=dev
```

---

## Support

If you encounter issues not covered here:

1. Check pod logs: `kubectl logs <pod-name>`
2. Check events: `kubectl get events --sort-by='.lastTimestamp'`
3. Verify infrastructure is running (not stopped)
4. Review deployment workflow logs in GitHub Actions
5. Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for deployment issues

---

**💡 Pro Tip**: Bookmark the frontend UI URL (`http://<EXTERNAL-IP>`) for quick access. Remember to stop infrastructure when not in use to save costs!
