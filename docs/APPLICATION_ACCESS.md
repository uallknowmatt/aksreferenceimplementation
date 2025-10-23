# Application Access Guide

This guide explains how to access the deployed application in Azure, including multiple methods to get the LoadBalancer IP address and access URL.

## Table of Contents
- [Quick Access](#quick-access)
- [Method 1: kubectl (Fastest)](#method-1-kubectl-fastest)
- [Method 2: Azure Portal](#method-2-azure-portal)
- [Method 3: Azure CLI](#method-3-azure-cli)
- [Method 4: kubectl describe](#method-4-kubectl-describe)
- [Backend Service Access](#backend-service-access)
- [Troubleshooting Access](#troubleshooting-access)

---

## Quick Access

The fastest way to access the application:

```bash
# Get the LoadBalancer IP
kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Output: 68.220.25.83 (example)

# Access the application
# Open browser to: http://68.220.25.83
```

---

## Method 1: kubectl (Fastest)

### Get LoadBalancer IP

```bash
kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

**Output:**
```
68.220.25.83
```

### Alternative kubectl Commands

```bash
# Simple format
kubectl get service frontend-ui

# Output:
# NAME          TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
# frontend-ui   LoadBalancer   10.0.15.234   68.220.25.83   80:30123/TCP   5m

# JSON output (more details)
kubectl get service frontend-ui -o json | grep -A 2 "loadBalancer"

# YAML output
kubectl get service frontend-ui -o yaml | grep -A 5 "status:"
```

### Save to Variable

```bash
# Bash
FRONTEND_URL=$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application URL: http://$FRONTEND_URL"

# PowerShell
$FRONTEND_URL = kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
Write-Host "Application URL: http://$FRONTEND_URL"
```

### Open in Browser Automatically

```bash
# macOS
open "http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# Linux
xdg-open "http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# Windows (PowerShell)
Start-Process "http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# Windows (Git Bash)
start "http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
```

---

## Method 2: Azure Portal

### Step-by-Step Instructions

1. **Login to Azure Portal**
   - Navigate to: https://portal.azure.com
   - Sign in with your credentials

2. **Navigate to AKS Cluster**
   - In the search bar (top), type: `Kubernetes services`
   - Click on "Kubernetes services"
   - Select your cluster: `aks-account-opening-dev-eus2`

3. **Go to Services and Ingresses**
   - In the left sidebar, under "Kubernetes resources"
   - Click **"Services and ingresses"**

4. **Find frontend-ui Service**
   - In the services list, look for:
     - **Name:** `frontend-ui`
     - **Type:** `LoadBalancer`
   - Note the **External IP** column

5. **Copy External IP**
   - Click on the IP address to copy it
   - Or manually copy from the table

6. **Access Application**
   - Open a new browser tab
   - Navigate to: `http://<EXTERNAL-IP>`
   - Example: `http://68.220.25.83`

### Portal Screenshots Reference

See [AZURE_PORTAL_GUIDE.md](AZURE_PORTAL_GUIDE.md) for detailed screenshots.

### Alternative Portal Method: Public IP Resource

1. **Navigate to Resource Group**
   - Search for: `rg-account-opening-dev-eus2`
   - Click on the resource group

2. **Find Public IP Resource**
   - Look for resource type: "Public IP address"
   - Name will be like: `kubernetes-a1b2c3d4e5f6g7h8i9j0`

3. **View IP Address**
   - Click on the public IP resource
   - See **IP address** field in Overview
   - This is your LoadBalancer IP

---

## Method 3: Azure CLI

### Get LoadBalancer IP

```bash
# Set variables
RG_NAME="rg-account-opening-dev-eus2"
CLUSTER_NAME="aks-account-opening-dev-eus2"

# Method A: List all public IPs in resource group
az network public-ip list \
  --resource-group $RG_NAME \
  --query "[].{Name:name, IP:ipAddress, Status:provisioningState}" \
  --output table
```

**Output:**
```
Name                              IP              Status
---------------------------------  ---------------  -------
kubernetes-a1b2c3d4e5f6g7h8i9j0  68.220.25.83     Succeeded
```

### Get Specific LoadBalancer IP

```bash
# Method B: Query LoadBalancer service via AKS
az aks show \
  --resource-group $RG_NAME \
  --name $CLUSTER_NAME \
  --query "networkProfile.loadBalancerProfile.effectiveOutboundIps[0].id" \
  --output tsv
```

### Get All Services with IPs

```bash
# Get AKS credentials first
az aks get-credentials \
  --resource-group $RG_NAME \
  --name $CLUSTER_NAME \
  --overwrite-existing

# List all services with kubectl via Azure CLI
az aks command invoke \
  --resource-group $RG_NAME \
  --name $CLUSTER_NAME \
  --command "kubectl get services -o wide"
```

### Save to Variable

```bash
# Get LoadBalancer IP
FRONTEND_IP=$(az network public-ip list \
  --resource-group $RG_NAME \
  --query "[?contains(name, 'kubernetes')].ipAddress | [0]" \
  --output tsv)

echo "Application URL: http://$FRONTEND_IP"

# Test connectivity
curl -I http://$FRONTEND_IP
```

---

## Method 4: kubectl describe

Get detailed information including events and status:

```bash
kubectl describe service frontend-ui
```

**Output includes:**
```
Name:                     frontend-ui
Namespace:                default
Labels:                   app=frontend-ui
Annotations:              <none>
Selector:                 app=frontend-ui
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.0.15.234
IPs:                      10.0.15.234
LoadBalancer Ingress:     68.220.25.83
Port:                     http  80/TCP
TargetPort:               80/TCP
NodePort:                 http  30123/TCP
Endpoints:                10.0.1.45:80,10.0.1.67:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  5m    service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   4m    service-controller  Ensured load balancer
```

**Key fields:**
- **LoadBalancer Ingress:** Your external IP (68.220.25.83)
- **Port:** External port (80)
- **TargetPort:** Container port (80)
- **Endpoints:** Pod IPs receiving traffic
- **Events:** Shows when LoadBalancer was created

---

## Backend Service Access

Backend services are **ClusterIP** type (internal only for security).

### List All Services

```bash
kubectl get services
```

**Output:**
```
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
customer-service        ClusterIP   10.0.10.10      <none>        8081/TCP   5m
document-service        ClusterIP   10.0.10.11      <none>        8082/TCP   5m
account-service         ClusterIP   10.0.10.12      <none>        8083/TCP   5m
notification-service    ClusterIP   10.0.10.13      <none>        8084/TCP   5m
frontend-ui             LoadBalancer 10.0.15.234    68.220.25.83  80/TCP     5m
```

**Note:** Backend services have `EXTERNAL-IP: <none>` (internal only)

### Access Backend Services

#### Option A: Port-Forward (for debugging)

```bash
# Forward local port to service
kubectl port-forward service/customer-service 8081:8081

# In another terminal, test
curl http://localhost:8081/actuator/health
```

**Use cases:**
- Testing backend directly
- Debugging issues
- Development purposes

#### Option B: From Within Cluster

```bash
# Execute into a pod
kubectl exec -it <frontend-pod-name> -- /bin/sh

# Test backend service (DNS resolution works)
curl http://customer-service:8081/actuator/health
```

#### Option C: Through Frontend (Production)

**Frontend nginx.conf proxies API calls:**

```nginx
location /api/customers {
    proxy_pass http://customer-service:8081;
}
location /api/documents {
    proxy_pass http://document-service:8082;
}
location /api/accounts {
    proxy_pass http://account-service:8083;
}
location /api/notifications {
    proxy_pass http://notification-service:8084;
}
```

**Access via frontend:**
```bash
# Get frontend IP
FRONTEND_IP=$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test backend APIs through frontend
curl http://$FRONTEND_IP/api/customers
curl http://$FRONTEND_IP/api/documents
curl http://$FRONTEND_IP/api/accounts
curl http://$FRONTEND_IP/api/notifications
```

**This is the recommended way for business users.**

---

## Troubleshooting Access

### No External IP (Pending)

**Symptom:**
```bash
kubectl get service frontend-ui
NAME          TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
frontend-ui   LoadBalancer   10.0.15.234   <pending>     80:30123/TCP   10m
```

**Diagnosis:**
```bash
kubectl describe service frontend-ui
```

**Common causes:**
1. Azure quota exceeded
2. AKS managed identity missing permissions
3. Subnet full (no IPs available)
4. Service type incorrect

**Solutions:** See [Troubleshooting Guide - LoadBalancer Issues](TROUBLESHOOTING.md#loadbalancer-issues)

### Can't Access LoadBalancer IP

**Symptom:**
- LoadBalancer IP assigned
- Browser shows "Connection refused" or "Timeout"

**Quick checks:**
```bash
# Check if pods are ready
kubectl get pods -l app=frontend-ui

# Check pod logs
kubectl logs -l app=frontend-ui

# Test from command line
FRONTEND_IP=$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -v http://$FRONTEND_IP
```

**Common causes:**
1. Pods not ready
2. NSG blocking traffic
3. Wrong container port
4. Health probe failing

**Solutions:** See [Troubleshooting Guide - LoadBalancer Access](TROUBLESHOOTING.md#cant-access-loadbalancer-ip)

### LoadBalancer IP Changes

**Symptom:**
- IP was 68.220.25.83, now it's 52.142.18.45

**Why it happens:**
- AKS cluster restarted
- Service deleted and recreated
- Load balancer configuration changed

**Prevention:**

#### Option 1: Reserve Static IP

```bash
# Create static public IP
az network public-ip create \
  --resource-group rg-account-opening-dev-eus2 \
  --name pip-frontend-lb-static \
  --sku Standard \
  --allocation-method Static

# Get IP address
STATIC_IP=$(az network public-ip show \
  --resource-group rg-account-opening-dev-eus2 \
  --name pip-frontend-lb-static \
  --query "ipAddress" \
  --output tsv)

# Update service to use static IP
kubectl patch service frontend-ui \
  -p "{\"spec\":{\"loadBalancerIP\":\"$STATIC_IP\"}}"
```

#### Option 2: Use Azure DNS

```bash
# Create DNS A record
az network dns record-set a add-record \
  --resource-group rg-account-opening-dev-eus2 \
  --zone-name accountopening.com \
  --record-set-name app \
  --ipv4-address $FRONTEND_IP

# Access via: http://app.accountopening.com
```

### Service Not Found

**Symptom:**
```bash
kubectl get service frontend-ui
Error from server (NotFound): services "frontend-ui" not found
```

**Solutions:**
```bash
# Check if service exists in different namespace
kubectl get services --all-namespaces | grep frontend

# Deploy service
kubectl apply -f k8s/frontend-ui-service.yaml

# Verify deployment
kubectl get service frontend-ui
```

### Access from Specific Location

**Corporate network blocking access:**

1. **Verify IP is accessible:**
   ```bash
   # Test connectivity
   telnet <EXTERNAL-IP> 80
   ```

2. **Check NSG rules allow your IP:**
   ```bash
   az network nsg rule list \
     --resource-group rg-account-opening-dev-eus2 \
     --nsg-name nsg-aks-account-opening-dev-eus2 \
     --output table
   ```

3. **Add your IP to allowed list (if needed):**
   ```bash
   MY_IP=$(curl -s ifconfig.me)
   
   az network nsg rule create \
     --resource-group rg-account-opening-dev-eus2 \
     --nsg-name nsg-aks-account-opening-dev-eus2 \
     --name AllowMyIP \
     --priority 110 \
     --source-address-prefixes $MY_IP \
     --destination-port-ranges 80 443 \
     --access Allow \
     --protocol Tcp
   ```

---

## Quick Reference

### Get Application URL (One Command)

```bash
echo "http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
```

### Test Application is Responding

```bash
FRONTEND_IP=$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -I http://$FRONTEND_IP
```

**Expected output:**
```
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
```

### Get All Application Endpoints

```bash
echo "Frontend UI: http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "Customer API: http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/api/customers"
echo "Document API: http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/api/documents"
echo "Account API: http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/api/accounts"
echo "Notification API: http://$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/api/notifications"
```

---

**See Also:**
- [Testing Guide](TESTING_GUIDE.md) - How to test the application
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common access issues
- [Azure Portal Guide](AZURE_PORTAL_GUIDE.md) - Portal screenshots
