# Educational Scripts

This folder contains PowerShell scripts for **educational purposes and local development**. These scripts are **NOT required** for Azure deployment, as the GitHub Actions workflows handle everything automatically.

---

## 📚 Purpose

These scripts help you:
- Understand how the system works locally
- Learn Azure CLI commands
- Test services on your local machine
- Manually interact with Azure resources (if needed)

---

## ⚠️ Important Notes

### **For Azure Deployment:**
- ❌ **You don't need these scripts!**
- ✅ **Use GitHub Actions workflows instead**
- ✅ **Everything is automated in `.github/workflows/`**

### **For Local Development:**
- ✅ **Use these scripts to test locally**
- ✅ **Learn how components work**
- ✅ **Debug issues on your machine**

---

## 📋 Script Reference

### Initial Setup Scripts

#### `bootstrap.ps1`
**Purpose:** One-time setup for GitHub OIDC authentication

**When to use:**
- First time setting up the project
- Configuring GitHub Actions authentication
- Creating service principal for deployments

**How to use:**
```powershell
.\bootstrap.ps1
```

**Note:** You only run this **ONCE** during initial setup. After that, GitHub Actions handles everything.

---

#### `setup-oidc-cli.ps1`
**Purpose:** PowerShell version of OIDC setup (Linux/Mac users use `setup-oidc-cli.sh` at root)

**When to use:**
- Windows users setting up OIDC authentication
- Configuring federated credentials for GitHub Actions

**How to use:**
```powershell
.\setup-oidc-cli.ps1
```

**Equivalent:** See `setup-oidc-cli.sh` in root directory for Linux/Mac version

---

#### `verify-oidc-setup.ps1`
**Purpose:** Verify OIDC authentication is configured correctly

**When to use:**
- After running bootstrap or setup-oidc scripts
- Troubleshooting GitHub Actions authentication issues
- Confirming federated credentials are working

**How to use:**
```powershell
.\verify-oidc-setup.ps1
```

---

### Local Development Scripts

#### `setup-databases.ps1`
**Purpose:** Set up local PostgreSQL databases for development

**When to use:**
- Starting local development without Docker
- Creating local database instances
- Testing database migrations

**How to use:**
```powershell
.\setup-databases.ps1
```

**Requirements:**
- PostgreSQL installed locally
- Local PostgreSQL server running

**Note:** Docker Compose is easier - see `docker-compose.yml` at root

---

#### `start-all-services.ps1`
**Purpose:** Start all backend microservices locally

**When to use:**
- Local development without Docker
- Testing services on your machine
- Debugging service-to-service communication

**How to use:**
```powershell
.\start-all-services.ps1
```

**What it does:**
- Starts customer-service (port 8081)
- Starts document-service (port 8082)
- Starts account-service (port 8083)
- Starts notification-service (port 8084)

**Note:** Services must be built first (`mvn clean install`)

---

#### `start-local-dev.ps1`
**Purpose:** Start complete local development environment

**When to use:**
- Starting both databases and services together
- Quick local environment setup

**How to use:**
```powershell
.\start-local-dev.ps1
```

---

#### `check-services.ps1`
**Purpose:** Check health status of all local services

**When to use:**
- Verifying services started correctly
- Debugging local connectivity issues
- Testing actuator health endpoints

**How to use:**
```powershell
.\check-services.ps1
```

**What it checks:**
- customer-service: http://localhost:8081/actuator/health
- document-service: http://localhost:8082/actuator/health
- account-service: http://localhost:8083/actuator/health
- notification-service: http://localhost:8084/actuator/health

---

#### `start-port-forwarding.ps1`
**Purpose:** Forward local ports to AKS pods for debugging

**When to use:**
- Debugging deployed services in AKS
- Accessing backend services from local machine
- Testing APIs in Azure environment

**How to use:**
```powershell
.\start-port-forwarding.ps1
```

**What it does:**
- Port-forward customer-service: localhost:8081 → pod:8081
- Port-forward document-service: localhost:8082 → pod:8082
- Port-forward account-service: localhost:8083 → pod:8083
- Port-forward notification-service: localhost:8084 → pod:8084

**Requirements:**
- kubectl configured for AKS cluster
- AKS cluster running

---

#### `clean-databases.ps1`
**Purpose:** Clean/reset local databases

**When to use:**
- Resetting local database state
- Cleaning test data
- Starting fresh with databases

**How to use:**
```powershell
.\clean-databases.ps1
```

**Warning:** This deletes all data in local databases!

---

### Azure Management Scripts (Educational)

#### `start-infra.ps1`
**Purpose:** Manually start stopped Azure infrastructure

**When to use:**
- Learning Azure CLI commands
- Manual infrastructure control (instead of GitHub Actions)

**How to use:**
```powershell
.\start-infra.ps1
```

**What it does:**
- Starts AKS cluster
- Starts PostgreSQL server
- Waits for resources to be ready

**Note:** GitHub Actions workflow "Start Infrastructure" is better - see `.github/workflows/start-infrastructure.yml`

---

#### `stop-infra.ps1`
**Purpose:** Manually stop running Azure infrastructure

**When to use:**
- Learning Azure CLI commands
- Manual cost control (instead of GitHub Actions)

**How to use:**
```powershell
.\stop-infra.ps1
```

**What it does:**
- Stops AKS cluster
- Stops PostgreSQL server
- Reduces costs to ~$1/month

**Note:** GitHub Actions workflow "Stop Infrastructure" is better - see `.github/workflows/stop-infrastructure.yml`

---

#### `check-infra-status.ps1`
**Purpose:** Check status of Azure infrastructure

**When to use:**
- Verifying infrastructure is running
- Checking resource states
- Learning Azure CLI status commands

**How to use:**
```powershell
.\check-infra-status.ps1
```

**What it checks:**
- AKS cluster status (Running/Stopped)
- PostgreSQL server status (Ready/Stopped)
- Resource group existence

---

#### `deploy-ui-to-azure.ps1`
**Purpose:** Manually deploy frontend UI to Azure

**When to use:**
- Learning deployment process
- Manual UI deployment (not recommended)

**How to use:**
```powershell
.\deploy-ui-to-azure.ps1
```

**Note:** GitHub Actions workflow handles this automatically - see `.github/workflows/aks-deploy.yml`

---

#### `test-deployment.ps1`
**Purpose:** Run automated health checks on deployed infrastructure

**When to use:**
- Testing deployed application
- Verifying deployment health
- Debugging deployment issues

**How to use:**
```powershell
.\test-deployment.ps1
```

**What it tests:**
- Pod status (all running)
- LoadBalancer IP assignment
- Frontend health endpoint
- Backend service health
- Database connectivity

**Note:** GitHub Actions runs these tests automatically after deployment - see "Test Deployment" job in workflow

---

## 🚀 Recommended Workflows

### For Production Deployment (Azure)

**Use GitHub Actions - Zero manual scripts needed!**

1. **Deploy Infrastructure:**
   - Go to: https://github.com/uallknowmatt/aksreferenceimplementation/actions
   - Run: "Deploy to AKS (Dev)" workflow
   - Result: Complete infrastructure + automated testing

2. **Start Infrastructure:**
   - Run: "Start Infrastructure (Dev)" workflow
   - Result: AKS and PostgreSQL started

3. **Stop Infrastructure:**
   - Run: "Stop Infrastructure (Dev)" workflow
   - Result: Infrastructure stopped (saves ~$52/month)

4. **Destroy Infrastructure:**
   - Run: "Destroy Infrastructure (Dev)" workflow
   - Result: All resources deleted

**No scripts needed!** ✅

---

### For Local Development

**Use these scripts or Docker Compose:**

#### Option 1: Docker Compose (Recommended)
```powershell
# Start everything (databases + services)
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

#### Option 2: PowerShell Scripts
```powershell
# 1. Setup databases
.\setup-databases.ps1

# 2. Start all services
.\start-all-services.ps1

# 3. Check health
.\check-services.ps1

# 4. Start frontend (in another terminal)
cd ..\frontend\account-opening-ui
npm start
```

---

### For Learning Azure CLI

**Run scripts and read the code:**

```powershell
# Learn how to start infrastructure
.\start-infra.ps1

# Learn how to check status
.\check-infra-status.ps1

# Learn how to stop infrastructure
.\stop-infra.ps1

# Read the scripts to understand Azure CLI commands!
code start-infra.ps1
```

**Better:** Check the GitHub Actions workflows (`.github/workflows/`) to see production-ready implementations

---

## 📖 Documentation References

### For Azure Deployment
- **[docs/CLEAN_DEPLOYMENT_GUIDE.md](../../docs/CLEAN_DEPLOYMENT_GUIDE.md)** - Complete deployment guide
- **[docs/DEPLOYMENT_GUIDE.md](../../docs/DEPLOYMENT_GUIDE.md)** - General deployment procedures
- **[docs/AUTOMATED_TESTING_GUIDE.md](../../docs/AUTOMATED_TESTING_GUIDE.md)** - Automated testing details
- **[docs/GITHUB_ENVIRONMENT_SETUP.md](../../docs/GITHUB_ENVIRONMENT_SETUP.md)** - GitHub Actions setup

### For Local Development
- **[README.md](../../README.md)** - Project overview and quick start
- **[docker-compose.yml](../../docker-compose.yml)** - Local Docker setup
- **[frontend/account-opening-ui/README.md](../../frontend/account-opening-ui/README.md)** - Frontend development

### For Infrastructure
- **[infrastructure/README.md](../../infrastructure/README.md)** - Terraform documentation
- **[docs/TERRAFORM_STATE_MANAGEMENT.md](../../docs/TERRAFORM_STATE_MANAGEMENT.md)** - State management guide

---

## 🔧 Script Maintenance

### These Scripts Are:
- ✅ **Educational** - Learn Azure CLI and system architecture
- ✅ **Optional** - GitHub Actions handle production deployments
- ✅ **For Local Dev** - Test on your machine before deploying
- ✅ **Documented** - Each script explains what it does

### These Scripts Are NOT:
- ❌ **Required for deployment** - Workflows handle that
- ❌ **Production tools** - Use workflows for production
- ❌ **Automatically updated** - Maintained as examples

---

## 💡 Tips

1. **For Production:** Use GitHub Actions workflows exclusively
2. **For Learning:** Read these scripts to understand Azure CLI
3. **For Local Dev:** Use Docker Compose (easier than scripts)
4. **For Debugging:** Use `test-deployment.ps1` to check Azure deployment
5. **For Port-Forwarding:** Use `start-port-forwarding.ps1` to access AKS pods

---

## 🆘 Need Help?

- **GitHub Actions Issues:** Check `.github/workflows/` and workflow logs
- **Local Development Issues:** Check `docker-compose.yml` or these scripts
- **Azure Issues:** Check `docs/` folder documentation
- **Script Issues:** Read the script code - it's well commented!

---

**Remember:** These scripts are **educational tools** and **local development helpers**. For production Azure deployments, always use the GitHub Actions workflows! 🚀
