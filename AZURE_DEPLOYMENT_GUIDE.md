# 🚀 Azure Deployment Guide - Complete Steps

This guide will help you deploy your Account Opening Application to Azure using GitHub Actions.

---

## 📋 Prerequisites

Before starting, you need:

### 1. Azure Account
- ✅ Azure subscription (free tier works)
- ✅ Contributor or Owner access
- ✅ Azure CLI installed on your machine

### 2. GitHub Repository
- ✅ Code pushed to GitHub
- ✅ Access to repository settings
- ✅ Ability to add secrets

### 3. Local Tools
- ✅ Azure CLI (`az`)
- ✅ Git
- ✅ PowerShell

---

## 🎯 Deployment Options

You have **2 options** for deployment:

### Option A: Azure Kubernetes Service (AKS) - Recommended
**Best for:** Production, scalability, microservices
- Uses existing Terraform code
- Uses existing GitHub Actions workflow
- More complex but production-ready
- **Cost:** ~$150-300/month

### Option B: Azure App Service + Static Web Apps - Simpler
**Best for:** Quick deployment, lower cost, simpler management
- Easier to set up
- Lower cost
- Good for POC and development
- **Cost:** ~$50-100/month

---

## 🚀 Option A: Deploy to AKS (Full Production Setup)

### Step 1: Install Prerequisites

```powershell
# Install Azure CLI (if not already)
# Download from: https://aka.ms/installazurecliwindows

# Verify installation
az --version

# Login to Azure
az login

# List your subscriptions
az account list --output table

# Set active subscription (if you have multiple)
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Step 2: Create Service Principal for GitHub Actions

```powershell
# Create service principal with Contributor role
az ad sp create-for-rbac `
  --name "github-actions-account-opening" `
  --role contributor `
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID `
  --sdk-auth

# SAVE THE OUTPUT! You'll need it for GitHub secrets
# Output looks like:
# {
#   "clientId": "...",
#   "clientSecret": "...",
#   "subscriptionId": "...",
#   "tenantId": "...",
#   ...
# }
```

### Step 3: Deploy Infrastructure with Terraform

```powershell
# Navigate to infrastructure folder
cd c:\genaiexperiments\accountopening\infrastructure

# Initialize Terraform
terraform init

# Create terraform.tfvars file
@"
environment          = "dev"
location            = "eastus"
resource_group_name = "account-opening-rg"
cluster_name        = "account-opening-aks"
node_count          = 2
vm_size             = "Standard_D2s_v3"
owner               = "your-email@example.com"
project             = "account-opening"

# PostgreSQL settings
postgres_admin_username = "pgadmin"
postgres_admin_password = "YourSecurePassword123!"
postgres_sku_name       = "B_Standard_B1ms"
postgres_storage_mb     = 32768
"@ | Out-File -FilePath terraform.tfvars -Encoding ASCII

# Review the plan
terraform plan

# Apply infrastructure (this takes 10-15 minutes)
terraform apply
```

### Step 4: Get Infrastructure Outputs

```powershell
# Get ACR login server
terraform output acr_login_server

# Get AKS cluster name
terraform output aks_cluster_name

# Get PostgreSQL server name
terraform output postgres_server_name

# Save these values - you'll need them for GitHub secrets
```

### Step 5: Configure GitHub Secrets

Go to your GitHub repository: `https://github.com/uallknowmatt/aksreferenceimplementation`

1. **Click:** Settings → Secrets and variables → Actions → New repository secret

2. **Add these secrets:**

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AZURE_CREDENTIALS` | Full JSON from Step 2 | Output of `az ad sp create-for-rbac` |
| `ACR_LOGIN_SERVER` | your-acr.azurecr.io | `terraform output acr_login_server` |
| `ACR_USERNAME` | service principal clientId | From AZURE_CREDENTIALS JSON |
| `ACR_PASSWORD` | service principal clientSecret | From AZURE_CREDENTIALS JSON |
| `AKS_CLUSTER_NAME` | account-opening-aks | `terraform output aks_cluster_name` |
| `AKS_RESOURCE_GROUP` | dev-account-opening-rg | From terraform.tfvars |
| `POSTGRES_HOST` | your-postgres.postgres.database.azure.com | `terraform output postgres_server_name` |
| `POSTGRES_PASSWORD` | YourSecurePassword123! | From terraform.tfvars |

### Step 6: Update Kubernetes Manifests

Update database connection strings in `k8s/*-configmap.yaml` files:

```powershell
# Customer Service ConfigMap
# Edit: k8s/customer-service-configmap.yaml
# Update:
SPRING_DATASOURCE_URL: jdbc:postgresql://YOUR-POSTGRES-SERVER.postgres.database.azure.com:5432/customerdb?sslmode=require
SPRING_DATASOURCE_USERNAME: pgadmin

# Repeat for document-service, account-service, notification-service
```

### Step 7: Create Dockerfiles (if not exist)

Create `Dockerfile` in each service directory:

```dockerfile
# customer-service/Dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Step 8: Push to GitHub and Deploy

```powershell
# Stage all changes
git add .

# Commit
git commit -m "Configure Azure deployment"

# Push to main branch (triggers GitHub Actions)
git push origin main
```

**GitHub Actions will automatically:**
1. Build all 4 microservices
2. Build Docker images
3. Push to Azure Container Registry
4. Deploy to AKS
5. Apply Kubernetes manifests

### Step 9: Monitor Deployment

```powershell
# Watch GitHub Actions
# Go to: https://github.com/uallknowmatt/aksreferenceimplementation/actions

# Or check locally
az aks get-credentials `
  --resource-group dev-account-opening-rg `
  --name account-opening-aks

# Check pods
kubectl get pods

# Check services
kubectl get services

# Get external IP
kubectl get service customer-service
```

### Step 10: Deploy Frontend

```powershell
# Install Azure Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Build frontend
cd frontend/account-opening-ui
npm run build

# Deploy to Azure Static Web Apps
az staticwebapp create `
  --name account-opening-frontend `
  --resource-group dev-account-opening-rg `
  --location "East US 2" `
  --source ./build `
  --branch main

# Update API URLs in frontend/.env for production
```

---

## 🎯 Option B: Deploy to App Service (Simpler)

### Step 1: Login to Azure

```powershell
az login
```

### Step 2: Create Resource Group

```powershell
az group create `
  --name account-opening-rg `
  --location eastus
```

### Step 3: Create PostgreSQL Flexible Server

```powershell
az postgres flexible-server create `
  --resource-group account-opening-rg `
  --name account-opening-postgres `
  --location eastus `
  --admin-user pgadmin `
  --admin-password "YourSecurePassword123!" `
  --sku-name Standard_B1ms `
  --tier Burstable `
  --storage-size 32 `
  --version 15 `
  --public-access 0.0.0.0

# Create databases
az postgres flexible-server db create `
  --resource-group account-opening-rg `
  --server-name account-opening-postgres `
  --database-name customerdb

az postgres flexible-server db create `
  --resource-group account-opening-rg `
  --server-name account-opening-postgres `
  --database-name documentdb

az postgres flexible-server db create `
  --resource-group account-opening-rg `
  --server-name account-opening-postgres `
  --database-name accountdb

az postgres flexible-server db create `
  --resource-group account-opening-rg `
  --server-name account-opening-postgres `
  --database-name notificationdb
```

### Step 4: Create App Service Plan

```powershell
az appservice plan create `
  --name account-opening-plan `
  --resource-group account-opening-rg `
  --location eastus `
  --sku B1 `
  --is-linux
```

### Step 5: Create Web Apps for Each Service

```powershell
# Customer Service
az webapp create `
  --resource-group account-opening-rg `
  --plan account-opening-plan `
  --name account-opening-customer `
  --runtime "JAVA:17-java17"

# Document Service
az webapp create `
  --resource-group account-opening-rg `
  --plan account-opening-plan `
  --name account-opening-document `
  --runtime "JAVA:17-java17"

# Account Service
az webapp create `
  --resource-group account-opening-rg `
  --plan account-opening-plan `
  --name account-opening-account `
  --runtime "JAVA:17-java17"

# Notification Service
az webapp create `
  --resource-group account-opening-rg `
  --plan account-opening-plan `
  --name account-opening-notification `
  --runtime "JAVA:17-java17"
```

### Step 6: Configure App Settings

```powershell
$POSTGRES_HOST = "account-opening-postgres.postgres.database.azure.com"

# Customer Service
az webapp config appsettings set `
  --resource-group account-opening-rg `
  --name account-opening-customer `
  --settings `
    SPRING_DATASOURCE_URL="jdbc:postgresql://$POSTGRES_HOST:5432/customerdb?sslmode=require" `
    SPRING_DATASOURCE_USERNAME="pgadmin" `
    SPRING_DATASOURCE_PASSWORD="YourSecurePassword123!" `
    SERVER_PORT="8080"

# Repeat for other services with their respective database names
```

### Step 7: Deploy JAR Files

```powershell
# Build all services
cd c:\genaiexperiments\accountopening
mvn clean package -DskipTests

# Deploy Customer Service
az webapp deploy `
  --resource-group account-opening-rg `
  --name account-opening-customer `
  --src-path customer-service/target/customer-service-1.0.0-SNAPSHOT.jar `
  --type jar

# Repeat for other services
```

### Step 8: Deploy Frontend to Static Web Apps

```powershell
# Create Static Web App
az staticwebapp create `
  --name account-opening-frontend `
  --resource-group account-opening-rg `
  --location "East US 2"

# Build and deploy
cd frontend/account-opening-ui

# Update .env with production URLs
@"
REACT_APP_CUSTOMER_SERVICE_URL=https://account-opening-customer.azurewebsites.net
REACT_APP_DOCUMENT_SERVICE_URL=https://account-opening-document.azurewebsites.net
REACT_APP_ACCOUNT_SERVICE_URL=https://account-opening-account.azurewebsites.net
REACT_APP_NOTIFICATION_SERVICE_URL=https://account-opening-notification.azurewebsites.net
"@ | Out-File -FilePath .env.production -Encoding ASCII

# Build
npm run build

# Deploy
az staticwebapp deploy `
  --name account-opening-frontend `
  --resource-group account-opening-rg `
  --app-location "./build"
```

---

## ✅ Verification Steps

### Check Backend Services

```powershell
# Test endpoints
curl https://account-opening-customer.azurewebsites.net/api/customers
curl https://account-opening-document.azurewebsites.net/api/documents
curl https://account-opening-account.azurewebsites.net/api/accounts
curl https://account-opening-notification.azurewebsites.net/api/notifications
```

### Check Frontend

```powershell
# Get frontend URL
az staticwebapp show `
  --name account-opening-frontend `
  --resource-group account-opening-rg `
  --query "defaultHostname" -o tsv

# Open in browser
start https://YOUR-FRONTEND-URL.azurestaticapps.net
```

### Check Database

```powershell
# Connect to PostgreSQL
az postgres flexible-server connect `
  --name account-opening-postgres `
  --admin-user pgadmin `
  --admin-password "YourSecurePassword123!" `
  --database-name customerdb

# Check tables
\dt

# Check data
SELECT * FROM customer;
```

---

## 💰 Cost Estimation

### Option A: AKS (Production)
- AKS Cluster (2 nodes): ~$150/month
- PostgreSQL Flexible Server: ~$30/month
- Container Registry: ~$5/month
- Static Web Apps: Free tier
- **Total: ~$185/month**

### Option B: App Service (Simpler)
- App Service Plan (B1): ~$13/month
- 4 Web Apps: Included in plan
- PostgreSQL Flexible Server (B1ms): ~$12/month
- Static Web Apps: Free tier
- **Total: ~$25/month**

---

## 🔒 Security Best Practices

### 1. Secure Secrets
- ✅ Use Azure Key Vault for secrets
- ✅ Never commit passwords to Git
- ✅ Rotate credentials regularly

### 2. Network Security
- ✅ Enable private endpoints for PostgreSQL
- ✅ Use VNet integration for App Services
- ✅ Configure firewall rules

### 3. SSL/TLS
- ✅ Enforce SSL for PostgreSQL
- ✅ Use HTTPS for all endpoints
- ✅ Configure custom domains

---

## 📊 Monitoring

### Enable Application Insights

```powershell
# Create Application Insights
az monitor app-insights component create `
  --app account-opening-insights `
  --location eastus `
  --resource-group account-opening-rg `
  --application-type web

# Get instrumentation key
az monitor app-insights component show `
  --app account-opening-insights `
  --resource-group account-opening-rg `
  --query instrumentationKey -o tsv

# Add to application.yml or app settings
```

---

## 🐛 Troubleshooting

### Common Issues

**1. Services can't connect to PostgreSQL**
```powershell
# Check firewall rules
az postgres flexible-server firewall-rule list `
  --resource-group account-opening-rg `
  --name account-opening-postgres

# Add your IP
az postgres flexible-server firewall-rule create `
  --resource-group account-opening-rg `
  --name account-opening-postgres `
  --rule-name AllowMyIP `
  --start-ip-address YOUR_IP `
  --end-ip-address YOUR_IP
```

**2. GitHub Actions failing**
- Check secrets are configured correctly
- Verify service principal has Contributor role
- Check workflow logs for specific errors

**3. Pods not starting (AKS)**
```powershell
# Check pod status
kubectl get pods

# View logs
kubectl logs POD_NAME

# Describe pod
kubectl describe pod POD_NAME
```

---

## 📚 Next Steps

After deployment:

1. **Configure CI/CD**
   - Set up automatic deployments on push
   - Add staging environment
   - Configure approval gates

2. **Add Monitoring**
   - Set up Application Insights
   - Configure alerts
   - Create dashboards

3. **Enhance Security**
   - Move to Azure Key Vault
   - Enable managed identities
   - Configure private endpoints

4. **Add Features**
   - Configure custom domains
   - Set up CDN
   - Add authentication (Azure AD B2C)

---

## 🆘 Need Help?

**Azure Documentation:**
- AKS: https://docs.microsoft.com/en-us/azure/aks/
- App Service: https://docs.microsoft.com/en-us/azure/app-service/
- PostgreSQL: https://docs.microsoft.com/en-us/azure/postgresql/

**Support:**
- Azure Support Portal
- GitHub Issues
- Stack Overflow

---

## ✅ Deployment Checklist

- [ ] Azure subscription ready
- [ ] Azure CLI installed and logged in
- [ ] GitHub repository accessible
- [ ] Choose deployment option (AKS or App Service)
- [ ] Create service principal (if using GitHub Actions)
- [ ] Deploy infrastructure (Terraform or Azure CLI)
- [ ] Configure GitHub secrets
- [ ] Update configuration files
- [ ] Push to GitHub (triggers deployment)
- [ ] Verify services are running
- [ ] Test frontend application
- [ ] Check database connectivity
- [ ] Configure monitoring
- [ ] Set up alerts

---

**Ready to deploy? Let me know which option you want to use and I'll help you through each step!** 🚀
