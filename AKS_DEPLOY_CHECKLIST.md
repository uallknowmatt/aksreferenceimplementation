# 🎯 AKS Deployment - Quick Action Steps

Your complete checklist to deploy to Azure Kubernetes Service. Follow these steps in order.

---

## ✅ Pre-Deployment Checklist

- [ ] Azure CLI installed (`az --version`)
- [ ] Logged into Azure (`az login`)
- [ ] Git configured
- [ ] Have Azure subscription with Contributor access

---

## 🚀 Deployment Steps

### 1️⃣ Create Service Principal (5 minutes)

```powershell
# Get subscription ID
$SUB_ID = az account show --query id -o tsv
Write-Host "Subscription: $SUB_ID"

# Create service principal
az ad sp create-for-rbac `
  --name "github-actions-account-opening" `
  --role contributor `
  --scopes /subscriptions/$SUB_ID `
  --sdk-auth

# 💾 COPY THE ENTIRE JSON OUTPUT - You need it for GitHub!
```

**✅ Done? Check here:** [ ]

---

### 2️⃣ Deploy Infrastructure (15 minutes)

```powershell
cd c:\genaiexperiments\accountopening\infrastructure

# Create variables file
notepad terraform.tfvars
```

**Add this content:**
```hcl
environment          = "dev"
location            = "eastus"
resource_group_name = "account-opening-rg"
cluster_name        = "account-opening-aks"
owner               = "YOUR_EMAIL@example.com"
project             = "account-opening"

node_count          = 2
vm_size             = "Standard_D2s_v3"
enable_auto_scaling = true
min_node_count      = 2
max_node_count      = 5

db_admin_username   = "pgadmin"
db_admin_password   = "SecurePassword123!CHANGE_ME"
db_sku_name         = "B_Standard_B1ms"
db_storage_mb       = 32768
```

**🔒 Change the db_admin_password to something secure!**

```powershell
# Initialize and deploy
terraform init
terraform plan
terraform apply
# Type 'yes' when prompted

# ⏰ This takes 10-15 minutes. Wait for completion.
```

**✅ Done? Check here:** [ ]

---

### 3️⃣ Get Output Values (2 minutes)

```powershell
cd c:\genaiexperiments\accountopening\infrastructure

# Get all important values
terraform output

# Copy these specific values:
terraform output -raw acr_login_server
terraform output -raw acr_name  
terraform output -raw aks_cluster_name
terraform output -raw aks_resource_group
terraform output -raw postgres_server_name

# 💾 SAVE THESE VALUES - You need them for GitHub!
```

**✅ Done? Check here:** [ ]

---

### 4️⃣ Configure GitHub Secrets (5 minutes)

Go to: `https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions`

Click **"New repository secret"** for each:

| Secret Name | Value |
|-------------|-------|
| AZURE_CREDENTIALS | Full JSON from Step 1 |
| ACR_LOGIN_SERVER | Output from terraform (e.g., myacr.azurecr.io) |
| ACR_NAME | Output from terraform |
| ACR_USERNAME | "clientId" from AZURE_CREDENTIALS JSON |
| ACR_PASSWORD | "clientSecret" from AZURE_CREDENTIALS JSON |
| AKS_CLUSTER_NAME | Output from terraform |
| AKS_RESOURCE_GROUP | Output from terraform |
| POSTGRES_HOST | Output from terraform |
| POSTGRES_USERNAME | pgadmin |
| POSTGRES_PASSWORD | Password from terraform.tfvars |

**✅ Done? Verify all 10 secrets added:** [ ]

---

### 5️⃣ Commit and Push (2 minutes)

```powershell
cd c:\genaiexperiments\accountopening

# Stage all changes (Dockerfiles, etc.)
git add .

# Commit
git commit -m "Add Dockerfiles and configure for AKS deployment"

# Push to main (this triggers GitHub Actions)
git push origin main

# Watch deployment at:
# https://github.com/uallknowmatt/aksreferenceimplementation/actions
```

**✅ Done? Check here:** [ ]

---

### 6️⃣ Monitor Deployment (10 minutes)

**Watch GitHub Actions:**
1. Go to: `https://github.com/uallknowmatt/aksreferenceimplementation/actions`
2. Click on the latest workflow run
3. Watch it build and deploy

**What happens:**
- ✅ Builds all 4 microservices
- ✅ Creates Docker images
- ✅ Pushes to Azure Container Registry
- ✅ Deploys to AKS
- ✅ Applies Kubernetes manifests

**✅ Deployment successful?:** [ ]

---

### 7️⃣ Verify Services (5 minutes)

```powershell
# Get AKS credentials
az aks get-credentials `
  --resource-group dev-account-opening-rg `
  --name dev-account-opening-aks

# Check pods are running
kubectl get pods

# Expected: All pods show "Running" status
# customer-service-xxx    1/1   Running
# document-service-xxx    1/1   Running
# account-service-xxx     1/1   Running
# notification-service-xxx 1/1  Running

# Check services
kubectl get services

# Get external IPs (may take a few minutes to assign)
kubectl get service customer-service
kubectl get service document-service
kubectl get service account-service
kubectl get service notification-service
```

**✅ All pods running?:** [ ]

---

### 8️⃣ Test Backend APIs (3 minutes)

```powershell
# Get customer service external IP
$CUSTOMER_IP = kubectl get service customer-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Test endpoints
curl http://${CUSTOMER_IP}:8081/api/customers
curl http://${DOCUMENT_IP}:8082/api/documents
curl http://${ACCOUNT_IP}:8083/api/accounts
curl http://${NOTIFICATION_IP}:8084/api/notifications

# All should return [] (empty array) with 200 OK
```

**✅ APIs responding?:** [ ]

---

### 9️⃣ Deploy Frontend (10 minutes)

```powershell
cd c:\genaiexperiments\accountopening\frontend\account-opening-ui

# Update .env.production with service IPs
@"
REACT_APP_CUSTOMER_SERVICE_URL=http://$CUSTOMER_IP:8081
REACT_APP_DOCUMENT_SERVICE_URL=http://$DOCUMENT_IP:8082
REACT_APP_ACCOUNT_SERVICE_URL=http://$ACCOUNT_IP:8083
REACT_APP_NOTIFICATION_SERVICE_URL=http://$NOTIFICATION_IP:8084
"@ | Out-File -FilePath .env.production -Encoding ASCII

# Build for production
npm run build

# Create Static Web App
az staticwebapp create `
  --name account-opening-frontend `
  --resource-group dev-account-opening-rg `
  --location "East US 2"

# Get deployment token
$DEPLOY_TOKEN = az staticwebapp secrets list `
  --name account-opening-frontend `
  --resource-group dev-account-opening-rg `
  --query "properties.apiKey" -o tsv

# Deploy
npx @azure/static-web-apps-cli deploy `
  --app-location ./build `
  --deployment-token $DEPLOY_TOKEN
```

**✅ Frontend deployed?:** [ ]

---

### 🔟 Final Verification (5 minutes)

```powershell
# Get frontend URL
az staticwebapp show `
  --name account-opening-frontend `
  --resource-group dev-account-opening-rg `
  --query "defaultHostname" -o tsv

# Open in browser
start https://YOUR-FRONTEND-URL.azurestaticapps.net
```

**Test the application:**
- [ ] Click "Open New Account"
- [ ] Complete all 4 wizard steps
- [ ] Submit application
- [ ] See success message
- [ ] View data in Customers page
- [ ] Verify data saved in Azure PostgreSQL

**✅ End-to-end working?:** [ ]

---

## 🎉 Success Criteria

All checkboxes above should be checked! You now have:

- ✅ AKS cluster running in Azure
- ✅ 4 microservices deployed
- ✅ Azure PostgreSQL with 4 databases
- ✅ React frontend on Static Web Apps
- ✅ CI/CD via GitHub Actions
- ✅ Production-ready infrastructure

---

## 📊 What You've Deployed

### Azure Resources
- **Resource Group:** dev-account-opening-rg
- **AKS Cluster:** 2-node cluster
- **Container Registry:** For Docker images
- **PostgreSQL:** Flexible Server with 4 databases
- **Static Web App:** For React frontend
- **Virtual Network:** For secure communication
- **Log Analytics:** For monitoring

### Cost Estimate
- **AKS:** ~$150/month
- **PostgreSQL:** ~$30/month
- **ACR:** ~$5/month
- **Static Web Apps:** Free tier
- **Total:** ~$185/month

---

## 🐛 Troubleshooting

### GitHub Actions Failed?
```powershell
# Check workflow logs at:
# https://github.com/uallknowmatt/aksreferenceimplementation/actions

# Common issues:
# - Missing GitHub secret
# - Wrong secret value
# - Service principal doesn't have access
```

### Pods Not Starting?
```powershell
# Check pod status
kubectl get pods

# View logs
kubectl logs POD_NAME

# Common issues:
# - Can't connect to database
# - Image pull error
# - Configuration error
```

### Can't Connect to Database?
```powershell
# Check PostgreSQL firewall rules
az postgres flexible-server firewall-rule list `
  --resource-group dev-account-opening-rg `
  --name dev-postgresql-flex

# Add AKS IP range if needed
```

---

## 📞 Need Help?

If you get stuck on any step:

1. **Check the detailed guide:** [AZURE_DEPLOYMENT_GUIDE.md](AZURE_DEPLOYMENT_GUIDE.md)
2. **View GitHub Actions logs:** Check what failed
3. **Check Kubernetes events:** `kubectl get events`
4. **View pod logs:** `kubectl logs POD_NAME`

---

## 🚀 Ready to Start?

Begin with **Step 1** and work through each step in order. Check off each box as you complete it!

**Estimated Total Time:** ~1 hour

**Let's deploy! 🎯**
