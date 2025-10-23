# Deployment Guide

This document explains how to deploy the Account Opening application to different environments.

## Overview

We have two deployment workflows:
1. **Development** - Automatic deployment on push to `main`
2. **Production** - Manual deployment with confirmation required

## Workflows

### 1. Development Deployment (Automatic)

**File**: `.github/workflows/aks-deploy.yml`

**Trigger**: Automatic on push to `main` branch

**Environment**: `dev`

**Steps**:
1. ✅ Automatically creates Terraform state backend (if needed)
2. ✅ Deploys infrastructure using `environments/dev/terraform.tfvars`
3. ✅ Builds and pushes Docker images to ACR
4. ✅ Deploys services to AKS

**Cost**: ~$150-200/month

**Security**: Public cluster for easier development access

**Usage**:
```bash
# Just push to main
git push origin main

# Workflow runs automatically
# View at: https://github.com/uallknowmatt/aksreferenceimplementation/actions
```

---

### 2. Production Deployment (Manual)

**File**: `.github/workflows/deploy-production.yml`

**Trigger**: Manual only (workflow_dispatch)

**Environment**: `prod`

**Safety Features**:
- ⚠️ Requires manual triggering (no auto-deploy)
- ⚠️ Requires typing "deploy-prod" to confirm
- ⚠️ 10-second delay before applying changes
- ⚠️ Separate state file (prod.terraform.tfstate)
- ⚠️ Different network CIDRs (isolated from dev)

**Steps**:
1. ✅ Validates deployment confirmation
2. ✅ Creates/validates Terraform state backend
3. ✅ Deploys production infrastructure using `environments/prod/terraform.tfvars`
4. ✅ Builds and pushes Docker images to production ACR
5. ✅ Deploys services to production AKS

**Cost**: ~$500-800/month

**Security**: Private cluster with restricted access

**Usage**:

#### Via GitHub UI:

1. Go to **Actions** tab
2. Select **"Deploy to Production"** workflow
3. Click **"Run workflow"**
4. In the confirmation field, type: `deploy-prod`
5. Click **"Run workflow"** button
6. Monitor the deployment

#### Via GitHub CLI:
```bash
gh workflow run deploy-production.yml \
  -f confirm="deploy-prod"
```

---

## Environment Comparison

| Feature | Development | Production |
|---------|-------------|------------|
| **Trigger** | Automatic (push to main) | Manual only |
| **Approval** | None | Confirmation required |
| **AKS Nodes** | 2 (scale 1-3) | 3 (scale 3-10) |
| **VM Size** | Standard_DS2_v2 | Standard_D4s_v3 |
| **PostgreSQL** | 32 GB, Burstable | 128 GB, General Purpose |
| **Cluster Type** | Public | Private |
| **Network** | 10.0.0.0/16 | 10.10.0.0/16 |
| **Cost** | ~$150-200/mo | ~$500-800/mo |
| **State File** | dev.terraform.tfstate | prod.terraform.tfstate |

---

## Deployment Process

### Development Deployment Flow

```
Push to main
    ↓
Checkout code
    ↓
Azure Login (OIDC)
    ↓
Setup Terraform State Backend
  - Check if exists
  - Create if needed
  - Grant permissions
    ↓
Terraform Init
  - Download dev.terraform.tfstate
    ↓
Terraform Validate
    ↓
Terraform Plan
  - environments/dev/terraform.tfvars
    ↓
Terraform Apply
  - Create/update infrastructure
  - Save state back to storage
    ↓
Build Docker Images
  - Maven build (skip tests)
  - Docker build for each service
  - Push to ACR
    ↓
Deploy to AKS
  - Update manifests
  - Apply ConfigMaps
  - Apply Secrets
  - Apply Services
  - Apply Deployments
  - Wait for rollout
    ↓
✅ Deployment Complete!
```

### Production Deployment Flow

```
Manual Trigger
    ↓
Validate Confirmation
  - Must type "deploy-prod"
    ↓
[Same as dev but with:]
  - environments/prod/terraform.tfvars
  - prod.terraform.tfstate
  - 10-second warning delay
  - Production AKS cluster
    ↓
✅ Production Deployment Complete!
```

---

## Pre-Deployment Checklist

### Development
- [ ] Code merged to `main` branch
- [ ] Tests passing locally
- [ ] No breaking changes
- [ ] Database migrations tested

### Production
- [ ] All dev testing complete
- [ ] Security review passed
- [ ] Performance testing done
- [ ] Database backup verified
- [ ] Rollback plan documented
- [ ] Change window scheduled
- [ ] Stakeholders notified
- [ ] Monitor dashboards ready

---

## Post-Deployment Verification

### Check Deployment Status

```bash
# Get pods status
kubectl get pods

# Check deployments
kubectl get deployments

# View services
kubectl get services

# Check logs
kubectl logs -l app=customer-service
kubectl logs -l app=document-service
kubectl logs -l app=account-service
kubectl logs -l app=notification-service
```

### Health Checks

```bash
# Customer Service
curl http://<service-ip>:8081/actuator/health

# Document Service
curl http://<service-ip>:8082/actuator/health

# Account Service
curl http://<service-ip>:8083/actuator/health

# Notification Service
curl http://<service-ip>:8084/actuator/health
```

### Database Verification

```bash
# Connect to PostgreSQL
az postgres flexible-server execute \
  --name psql-account-opening-dev-eus \
  --admin-user psqladmin \
  --admin-password "YourPassword" \
  --database-name customerdb \
  --query-text "SELECT COUNT(*) FROM customers;"
```

---

## Rollback Procedures

### Rollback Infrastructure Changes

```bash
# Restore previous Terraform state
cd infrastructure

# For dev
terraform init
az storage blob download \
  --account-name tfstateaccountopening \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --version-id <PREVIOUS_VERSION_ID> \
  --file dev.terraform.tfstate

# Apply previous state
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Rollback Application Deployment

```bash
# Rollback to previous deployment
kubectl rollout undo deployment/customer-service
kubectl rollout undo deployment/document-service
kubectl rollout undo deployment/account-service
kubectl rollout undo deployment/notification-service

# Or rollback to specific revision
kubectl rollout undo deployment/customer-service --to-revision=2
```

### Rollback Docker Images

```bash
# Re-tag and deploy previous image
docker pull <acr-server>/customer-service:<previous-tag>
docker tag <acr-server>/customer-service:<previous-tag> <acr-server>/customer-service:rollback
docker push <acr-server>/customer-service:rollback

# Update deployment
kubectl set image deployment/customer-service customer-service=<acr-server>/customer-service:rollback
```

---

## Monitoring & Alerts

### View Logs

```bash
# Stream logs
kubectl logs -f deployment/customer-service

# Last 100 lines
kubectl logs --tail=100 deployment/customer-service

# All services
kubectl logs -l tier=backend
```

### Azure Monitor

1. Go to Azure Portal
2. Navigate to AKS cluster
3. Select "Insights" from left menu
4. View:
   - Container metrics
   - Node performance
   - Application logs

### Cost Monitoring

```bash
# View current costs
az consumption usage list \
  --start-date 2025-10-01 \
  --end-date 2025-10-31 \
  --query "[?contains(instanceName, 'account-opening')].{Name:instanceName, Cost:pretaxCost}"
```

---

## Troubleshooting

### Deployment Failed

**Check workflow logs**:
1. Go to Actions tab in GitHub
2. Click on the failed workflow run
3. Expand failed step to see error

**Common issues**:
- **Terraform errors**: Check tfvars file syntax
- **Docker build fails**: Check Dockerfile and Maven build
- **AKS deployment fails**: Check Kubernetes manifests
- **State lock**: Break lease if stuck

### Application Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name>

# View events
kubectl get events --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name>

# Check container status
kubectl get pods -o jsonpath='{.items[*].status.containerStatuses[*].state}'
```

### Database Connection Issues

```bash
# Test connection from pod
kubectl exec -it <pod-name> -- /bin/sh
psql -h <postgres-host> -U psqladmin -d customerdb

# Check network connectivity
kubectl exec -it <pod-name> -- nc -zv <postgres-host> 5432
```

---

## Security Best Practices

### Pre-Production
1. ✅ Review all Terraform changes
2. ✅ Scan Docker images for vulnerabilities
3. ✅ Rotate database passwords
4. ✅ Update API keys and secrets
5. ✅ Enable Azure Defender

### Post-Production
1. ✅ Monitor for anomalies
2. ✅ Check audit logs
3. ✅ Verify RBAC permissions
4. ✅ Review network traffic
5. ✅ Test disaster recovery

---

## Additional Resources

- [Infrastructure Documentation](infrastructure/README.md)
- [Environment Configurations](infrastructure/environments/README.md)
- [Terraform State Backend](TERRAFORM_STATE_BACKEND.md)
- [GitHub Actions Workflows](.github/workflows/)

---

## Support

For deployment issues:
1. Check [Troubleshooting](#troubleshooting) section
2. Review workflow logs in GitHub Actions
3. Check Azure Portal for resource status
4. Review Terraform state for inconsistencies

**Emergency Rollback**: Follow [Rollback Procedures](#rollback-procedures)
