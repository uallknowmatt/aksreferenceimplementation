# Bank Account Opening System

A complete microservices-based bank account opening system built with Spring Boot and React, deployed on Azure Kubernetes Service (AKS).

## Architecture

The system consists of four microservices:

- **Customer Service** - Customer information and KYC processes
- **Document Service** - Document upload and verification
- **Account Service** - Account creation and management
- **Notification Service** - Notifications and communications

## Technology Stack

**Backend:**
- Java 17
- Spring Boot 3.x
- Spring Cloud (Config, Gateway, Eureka)
- PostgreSQL
- Maven

**Frontend:**
- React 18
- TypeScript
- Axios
- React Router

**Infrastructure:**
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Azure Database for PostgreSQL
- Terraform for IaC
- GitHub Actions for CI/CD

## Project Structure

```
account-opening-system/
├── customer-service/        # Customer management
├── document-service/        # Document handling
├── account-service/         # Account management
├── notification-service/    # Notifications
├── frontend/
│   └── account-opening-ui/  # React frontend
├── infrastructure/          # Terraform configurations
├── k8s/                     # Kubernetes manifests
└── .github/workflows/       # CI/CD pipelines
```

## Documentation

### Getting Started
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete deployment guide for dev and production
- **[infrastructure/README.md](infrastructure/README.md)** - Infrastructure setup and configuration
- **[infrastructure/environments/README.md](infrastructure/environments/README.md)** - Environment-specific configurations

### Frontend
- **[frontend/account-opening-ui/README.md](frontend/account-opening-ui/README.md)** - Frontend documentation

### Historical Documentation
- **[pasthistory/](pasthistory/)** - Historical docs and progress tracking (for reference only)

## Quick Start

### Prerequisites
- Java 17+
- Maven 3.8+
- Node.js 18+
- Docker (optional)
- Azure CLI
- Terraform 1.6+
- kubectl

### Local Development

1. **Build all services:**
   ```bash
   mvn clean install
   ```

2. **Start backend services:**
   ```powershell
   .\start-all-services.ps1
   ```

3. **Start frontend:**
   ```bash
   cd frontend\account-opening-ui
   npm install
   npm start
   ```

4. **Check service health:**
   ```powershell
   .\check-services.ps1
   ```

### Services

| Service | Port | Health Check |
|---------|------|--------------|
| Customer Service | 8081 | http://localhost:8081/actuator/health |
| Document Service | 8082 | http://localhost:8082/actuator/health |
| Account Service | 8083 | http://localhost:8083/actuator/health |
| Notification Service | 8084 | http://localhost:8084/actuator/health |
| Frontend | 3000 | http://localhost:3000 |

## Deployment

### Automatic (Development)
Deployments to the **dev** environment happen automatically when code is pushed to the `main` branch.

### Manual (Production)
Production deployments require manual approval:
1. Push to `main` branch (dev deploys automatically)
2. Complete UAT testing
3. Navigate to GitHub Actions
4. Approve the "UAT Testing Complete" job
5. Production deployment proceeds after approval

See **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** for complete deployment instructions.

## Database Setup

The application uses PostgreSQL with the following databases:
- `customerdb` - Customer Service
- `documentdb` - Document Service
- `accountdb` - Account Service
- `notificationdb` - Notification Service

Database scripts are managed with Liquibase for version control and automated migrations.

## GitHub Actions Workflows

### CI/CD Pipeline
The system uses a unified workflow that handles both dev and production deployments:

**File:** `.github/workflows/aks-deploy.yml`

**Jobs:**
1. Deploy to Dev (automatic)
2. Build and push Docker images (dev)
3. Deploy to AKS (dev)
4. **UAT Test Complete** (manual approval gate)
5. Deploy to Prod (after approval)
6. Build and push Docker images (prod)
7. Deploy to AKS (prod)

### GitHub Secrets Required
- `AZURE_CLIENT_ID` - Service principal client ID
- `AZURE_TENANT_ID` - Azure tenant ID
- `AZURE_SUBSCRIPTION_ID` - Azure subscription ID

Authentication uses OIDC (OpenID Connect) - no secrets stored!

## Environment Configuration

### Development
- **Location:** East US
- **Nodes:** 2 (auto-scale 1-3)
- **VM Size:** Standard_DS2_v2
- **Cost:** ~$150-200/month
- **Access:** Public cluster

### Production
- **Location:** East US
- **Nodes:** 3 (auto-scale 3-10)
- **VM Size:** Standard_D4s_v3
- **Cost:** ~$500-800/month
- **Access:** Private cluster

See **[infrastructure/environments/](infrastructure/environments/)** for detailed configurations.

## Terraform State Management

Terraform state is stored remotely in Azure Storage:
- **Storage Account:** `tfstateaccountopening`
- **Resource Group:** `terraform-state-rg`
- **Container:** `tfstate`
- **State Files:** 
  - `dev.terraform.tfstate`
  - `prod.terraform.tfstate`

State backend includes versioning and soft delete (30 days retention).

## Contributing

1. Create a feature branch
2. Make changes
3. Test locally
4. Push to trigger dev deployment
5. Complete UAT testing
6. Approve for production

## License

[Your License Here]

## Support

For issues and questions:
- Check **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** troubleshooting section
- Review **[infrastructure/README.md](infrastructure/README.md)**
- Check GitHub Issues

---

**Note:** For historical documentation and progress tracking, see the [pasthistory/](pasthistory/) directory.
