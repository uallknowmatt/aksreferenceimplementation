# Quick Deployment Guide

## Overview
This guide provides a streamlined process to deploy your microservices to Azure AKS using GitHub Actions.

## Prerequisites Checklist
- [x] All services tested locally with Docker PostgreSQL
- [x] GitHub repository: `uallknowmatt/aksreferenceimplementation`
- [x] Azure CLI installed
- [x] Logged into Azure: `az login`

---

## 3-Step Deployment

### Step 1: Deploy Infrastructure (~10 minutes)

```powershell
cd c:\genaiexperiments\accountopening\infrastructure

# Initialize and deploy
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars" -auto-approve

# Save outputs for next step
terraform output -json > outputs.json
```

### Step 2: Configure GitHub Secrets (~5 minutes)

**Get values from Terraform:**
```powershell
# View all outputs
terraform output

# These are your secret values - save them
```

**Required Secrets (11 total):**

1. **AZURE_CREDENTIALS** - Create service principal:
   ```powershell
   $subscriptionId = (az account show --query id -o tsv)
   $resourceGroup = "account-opening-rg-dev"  # From terraform output
   
   az ad sp create-for-rbac `
     --name "github-actions-account-opening" `
     --role contributor `
     --scopes /subscriptions/$subscriptionId/resourceGroups/$resourceGroup `
     --sdk-auth
   ```
   Copy the entire JSON output.

2. **ACR Secrets** - From terraform output:
   - ACR_LOGIN_SERVER
   - ACR_NAME
   - ACR_USERNAME (enable admin or use SP)
   - ACR_PASSWORD

3. **AKS Secrets** - From terraform output:
   - AKS_CLUSTER_NAME
   - AKS_RESOURCE_GROUP

4. **PostgreSQL Secrets** - From terraform output:
   - POSTGRES_HOST
   - POSTGRES_USERNAME
   - POSTGRES_PASSWORD

5. **Optional:**
   - MANAGED_IDENTITY_CLIENT_ID (leave empty for now)

**Add to GitHub:**
1. Go to: https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
2. Click "New repository secret" for each secret above

### Step 3: Deploy to AKS (~5 minutes)

```powershell
cd c:\genaiexperiments\accountopening

# Commit and push (triggers GitHub Actions)
git add .
git commit -m "Add dev profile and k8s configurations for Azure deployment"
git push origin main
```

**Monitor deployment:**
- GitHub Actions: https://github.com/uallknowmatt/aksreferenceimplementation/actions
- Watch the workflow complete (~3-5 minutes)

---

## Verification

After GitHub Actions completes successfully:

```powershell
# Connect to your AKS cluster
$aksName = terraform output -raw aks_cluster_name
$aksRg = terraform output -raw aks_resource_group_name
az aks get-credentials --resource-group $aksRg --name $aksName --overwrite-existing

# Check everything is running
kubectl get pods
kubectl get services

# Get service URLs (wait for EXTERNAL-IP)
kubectl get services -o wide
```

You should see:
- 8 pods running (2 replicas × 4 services)
- 4 LoadBalancer services with external IPs
- All pods in "Running" state

---

## Quick Commands Reference

```powershell
# View logs
kubectl logs -l app=customer-service --tail=50
kubectl logs -l app=document-service --tail=50
kubectl logs -l app=account-service --tail=50
kubectl logs -l app=notification-service --tail=50

# Restart a service
kubectl rollout restart deployment/customer-service

# Scale a service
kubectl scale deployment/customer-service --replicas=3

# Delete all deployments (careful!)
kubectl delete -f k8s/

# Redeploy everything
kubectl apply -f k8s/
```

---

## Service Endpoints

After deployment, get your service URLs:

```powershell
kubectl get services
```

Example output:
```
NAME                   TYPE           EXTERNAL-IP      PORT(S)
customer-service       LoadBalancer   20.12.34.56     8081:30001/TCP
document-service       LoadBalancer   20.12.34.57     8082:30002/TCP
account-service        LoadBalancer   20.12.34.58     8083:30003/TCP
notification-service   LoadBalancer   20.12.34.59     8084:30004/TCP
```

Test your services:
```powershell
# Customer Service
curl http://20.12.34.56:8081/api/customers

# Document Service
curl http://20.12.34.57:8082/api/documents

# Account Service
curl http://20.12.34.58:8083/api/accounts

# Notification Service
curl http://20.12.34.59:8084/api/notifications
```

---

## Troubleshooting

**Issue: Pods not starting**
```powershell
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Issue: Database connection errors**
- Check PostgreSQL firewall allows AKS subnet
- Verify POSTGRES_HOST, POSTGRES_USERNAME, POSTGRES_PASSWORD secrets

**Issue: Image pull errors**
- Verify ACR credentials in secrets
- Check service principal has AcrPull permission

**Issue: GitHub Actions fails**
```powershell
# Check all secrets are configured
# Go to: https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
# Should have 11 secrets
```

---

## Clean Up (when needed)

```powershell
# Delete AKS deployments
kubectl delete -f k8s/

# Destroy infrastructure
cd infrastructure
terraform destroy -var-file="dev.tfvars" -auto-approve
```

---

## Next Steps

1. ✅ All services deployed to AKS
2. ✅ Connected to Azure PostgreSQL
3. ⬜ Deploy React frontend to Azure Static Web Apps
4. ⬜ Configure custom domain and SSL
5. ⬜ Setup monitoring and alerts
6. ⬜ Create staging environment

---

## Cost Estimate

Monthly cost: **~$185**
- AKS: $140
- PostgreSQL: $15
- ACR: $5
- Load Balancers: $20
- Other: $5

You can reduce costs by:
- Using 1 node instead of 2 for dev
- Stopping the cluster when not in use
- Using smaller VM sizes
