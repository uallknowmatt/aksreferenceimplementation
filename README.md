# Bank Account Opening System

> **Enterprise-grade microservices application for digital bank account opening, deployed on Azure Kubernetes Service (AKS) with full automation, self-healing capabilities, and secure private networking.**

[![Azure](https://img.shields.io/badge/Azure-AKS-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/en-us/services/kubernetes-service/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?logo=spring-boot)](https://spring.io/projects/spring-boot)
[![React](https://img.shields.io/badge/React-19.x-61DAFB?logo=react)](https://reactjs.org/)
[![Terraform](https://img.shields.io/badge/Terraform-1.6+-844FBA?logo=terraform)](https://www.terraform.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql)](https://www.postgresql.org/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
  - [Business Functional Diagram](#business-functional-diagram)
  - [Azure Architecture Diagram](#azure-architecture-diagram)
  - [Component Architecture](#component-architecture)
- [Technology Deep Dive](#technology-deep-dive)
  - [Application Layer](#application-layer)
  - [Infrastructure Layer](#infrastructure-layer)
  - [Network Architecture](#network-architecture)
  - [Database Layer](#database-layer)
  - [Load Balancer](#load-balancer)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Local Development](#local-development)
  - [Local Testing](#local-testing)
- [Azure Deployment](#azure-deployment)
  - [Clean Deployment](#clean-deployment)
  - [Starting Infrastructure](#starting-infrastructure)
  - [Stopping Infrastructure](#stopping-infrastructure)
  - [Destroying Infrastructure](#destroying-infrastructure)
- [Application Access](#application-access)
  - [Get Application URL](#get-application-url)
  - [Business User Testing](#business-user-testing)
- [Troubleshooting](#troubleshooting)
  - [Pods Not Running](#pods-not-running)
  - [Database Connectivity Issues](#database-connectivity-issues)
  - [LoadBalancer Issues](#loadbalancer-issues)
- [Documentation](#documentation)
- [Cost Management](#cost-management)
- [Contributing](#contributing)

---

## Overview

The **Bank Account Opening System** is a production-ready, cloud-native application that demonstrates enterprise-level microservices architecture deployed on Azure. It provides a complete digital workflow for opening bank accounts, including customer onboarding, document verification, account creation, and notifications.

### Key Features

✅ **Microservices Architecture** - 4 independent, scalable services  
✅ **Cloud-Native** - Containerized with Docker, orchestrated with Kubernetes  
✅ **Secure Private Networking** - PostgreSQL with VNet integration (no public access)  
✅ **Automated Testing** - 6 comprehensive health checks after every deployment  
✅ **Self-Healing** - Automatically stops infrastructure on test failures (saves ~$52/month)  
✅ **Infrastructure as Code** - Full Terraform automation  
✅ **CI/CD** - GitHub Actions with OIDC authentication  
✅ **Cost Optimized** - ~$1/month when stopped, ~$53/month when running  
✅ **Production Ready** - Automated validation before customer delivery

### Business Value

- **Faster Time to Market** - Deploy complete infrastructure in 15-20 minutes
- **Cost Efficiency** - Automated cost management with infrastructure decision gates
- **High Availability** - Kubernetes auto-scaling and self-healing
- **Security First** - Private networking, secret management, Azure RBAC
- **Developer Productivity** - One-command deployments, automated testing
- **Compliance Ready** - Audit logs, security policies, encrypted data

---

## Architecture

### Business Functional Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         BANK CUSTOMER                                    │
│                     (Web Browser / Mobile)                               │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 │ HTTPS
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     FRONTEND UI (React)                                  │
│  • Customer Registration Form                                            │
│  • Document Upload Interface                                             │
│  • Account Type Selection                                                │
│  • Application Status Tracking                                           │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 │ REST API
                                 ▼
         ┌───────────────────────┴────────────────────────┐
         │                                                 │
         ▼                                                 ▼
┌──────────────────────┐                      ┌──────────────────────┐
│  CUSTOMER SERVICE    │◄────────────────────►│  ACCOUNT SERVICE     │
│                      │                      │                      │
│  • KYC Verification  │                      │  • Account Creation  │
│  • Customer Profile  │                      │  • Account Types     │
│  • Compliance Checks │                      │  • Account Status    │
└──────────┬───────────┘                      └──────────┬───────────┘
           │                                             │
           │                                             │
           ▼                                             ▼
┌──────────────────────┐                      ┌──────────────────────┐
│  DOCUMENT SERVICE    │                      │ NOTIFICATION SERVICE │
│                      │                      │                      │
│  • ID Upload         │                      │  • Email Alerts      │
│  • Proof of Address  │                      │  • SMS Notifications │
│  • Document Verify   │                      │  • Status Updates    │
└──────────┬───────────┘                      └──────────┬───────────┘
           │                                             │
           │                                             │
           └──────────────────┬──────────────────────────┘
                              │
                              ▼
                 ┌────────────────────────┐
                 │   POSTGRESQL DATABASE  │
                 │  • Customer Data       │
                 │  • Documents Metadata  │
                 │  • Account Records     │
                 │  • Audit Logs          │
                 └────────────────────────┘

BUSINESS WORKFLOW:
1. Customer fills registration form → Customer Service (KYC check)
2. Customer uploads documents → Document Service (verification)
3. System creates account → Account Service (account setup)
4. Customer receives confirmation → Notification Service (email/SMS)
```

### Azure Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AZURE SUBSCRIPTION                                      │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                      RESOURCE GROUP: rg-account-opening-dev-eus2              │ │
│  │                                                                                │ │
│  │  ┌──────────────────────────────────────────────────────────────────────────┐ │ │
│  │  │               VIRTUAL NETWORK (VNet): 10.0.0.0/16                        │ │ │
│  │  │                                                                          │ │ │
│  │  │  ┌─────────────────────────────────────────────────────────────────┐    │ │ │
│  │  │  │  AKS SUBNET: 10.0.1.0/24                                        │    │ │ │
│  │  │  │                                                                 │    │ │ │
│  │  │  │   ┌──────────────────────────────────────────────────────┐     │    │ │ │
│  │  │  │   │  AZURE KUBERNETES SERVICE (AKS)                     │     │    │ │ │
│  │  │  │   │  Cluster: aks-account-opening-dev-eus2              │     │    │ │ │
│  │  │  │   │  Node Pool: Standard_B2s (1 node)                   │     │    │ │ │
│  │  │  │   │                                                      │     │    │ │ │
│  │  │  │   │  ┌────────────────────────────────────────────┐     │     │    │ │ │
│  │  │  │   │  │         POD: frontend-ui                   │     │     │    │ │ │
│  │  │  │   │  │         • React Application                │     │     │    │ │ │
│  │  │  │   │  │         • Nginx Server                     │     │     │    │ │ │
│  │  │  │   │  │         • Port 80                          │     │     │    │ │ │
│  │  │  │   │  └────────────────────────────────────────────┘     │     │    │ │ │
│  │  │  │   │                                                      │     │    │ │ │
│  │  │  │   │  ┌────────────────────────────────────────────┐     │     │    │ │ │
│  │  │  │   │  │         POD: customer-service              │     │     │    │ │ │
│  │  │  │   │  │         • Spring Boot App                  │     │     │    │ │ │
│  │  │  │   │  │         • Port 8081                        │     │     │    │ │ │
│  │  │  │   │  │         • Health: /actuator/health         │     │     │    │ │ │
│  │  │  │   │  └────────────────────────────────────────────┘     │     │    │ │ │
│  │  │  │   │                                                      │     │    │ │ │
│  │  │  │   │  ┌────────────────────────────────────────────┐     │     │    │ │ │
│  │  │  │   │  │         POD: document-service              │     │     │    │ │ │
│  │  │  │   │  └────────────────────────────────────────────┘     │     │    │ │ │
│  │  │  │   │                                                      │     │    │ │ │
│  │  │  │   │  ┌────────────────────────────────────────────┐     │     │    │ │ │
│  │  │  │   │  │         POD: account-service               │     │     │    │ │ │
│  │  │  │   │  └────────────────────────────────────────────┘     │     │    │ │ │
│  │  │  │   │                                                      │     │    │ │ │
│  │  │  │   │  ┌────────────────────────────────────────────┐     │     │    │ │ │
│  │  │  │   │  │         POD: notification-service          │     │     │    │ │ │
│  │  │  │   │  └────────────────────────────────────────────┘     │     │    │ │ │
│  │  │  │   │                                                      │     │    │ │ │
│  │  │  │   │  ┌────────────────────────────────────────────┐     │     │    │ │ │
│  │  │  │   │  │   KUBERNETES SERVICE: frontend-ui          │     │     │    │ │ │
│  │  │  │   │  │   Type: LoadBalancer                       │     │     │    │ │ │
│  │  │  │   │  │   External IP: 68.220.25.83 (example)      │     │     │    │ │ │
│  │  │  │   │  └────────────────────────────────────────────┘     │     │    │ │ │
│  │  │  │   └──────────────────────────────────────────────────────┘     │    │ │ │
│  │  │  └─────────────────────────────────────────────────────────────────┘    │ │ │
│  │  │                                                                          │ │ │
│  │  │  ┌─────────────────────────────────────────────────────────────────┐    │ │ │
│  │  │  │  ACR SUBNET: 10.0.2.0/24                                        │    │ │ │
│  │  │  │                                                                 │    │ │ │
│  │  │  │   [Azure Container Registry - Private Endpoint]                │    │ │ │
│  │  │  └─────────────────────────────────────────────────────────────────┘    │ │ │
│  │  │                                                                          │ │ │
│  │  │  ┌─────────────────────────────────────────────────────────────────┐    │ │ │
│  │  │  │  POSTGRESQL SUBNET: 10.0.3.0/24                                 │    │ │ │
│  │  │  │  Delegation: Microsoft.DBforPostgreSQL/flexibleServers          │    │ │ │
│  │  │  │                                                                 │    │ │ │
│  │  │  │   ┌──────────────────────────────────────────────────────┐     │    │ │ │
│  │  │  │   │  POSTGRESQL FLEXIBLE SERVER                         │     │    │ │ │
│  │  │  │   │  Name: psql-account-opening-dev-eus2                │     │    │ │ │
│  │  │  │   │  SKU: Burstable B1ms                                │     │    │ │ │
│  │  │  │   │  Storage: 32 GB                                     │     │    │ │ │
│  │  │  │   │  Private IP: 10.0.3.x (VNet integrated)             │     │    │ │ │
│  │  │  │   │  NO PUBLIC ACCESS ✅                                │     │    │ │ │
│  │  │  │   │                                                      │     │    │ │ │
│  │  │  │   │  Databases:                                          │     │    │ │ │
│  │  │  │   │  • customerdb                                        │     │    │ │ │
│  │  │  │   │  • documentdb                                        │     │    │ │ │
│  │  │  │   │  • accountdb                                         │     │    │ │ │
│  │  │  │   │  • notificationdb                                    │     │    │ │ │
│  │  │  │   └──────────────────────────────────────────────────────┘     │    │ │ │
│  │  │  └─────────────────────────────────────────────────────────────────┘    │ │ │
│  │  │                                                                          │ │ │
│  │  │  ┌──────────────────────────────────────────────────────────────┐       │ │ │
│  │  │  │  PRIVATE DNS ZONE                                           │       │ │ │
│  │  │  │  Name: privatelink.postgres.database.azure.com              │       │ │ │
│  │  │  │  Linked to VNet ✅                                          │       │ │ │
│  │  │  └──────────────────────────────────────────────────────────────┘       │ │ │
│  │  └──────────────────────────────────────────────────────────────────────────┘ │ │
│  │                                                                                │ │
│  │  ┌──────────────────────────────────────────────────────────────────────────┐ │ │
│  │  │  AZURE CONTAINER REGISTRY (ACR)                                          │ │ │
│  │  │  Name: acr<uniqueid>accountopeningdev                                    │ │ │
│  │  │  SKU: Basic                                                              │ │ │
│  │  │  Docker Images:                                                          │ │ │
│  │  │  • customer-service:latest                                               │ │ │
│  │  │  • document-service:latest                                               │ │ │
│  │  │  • account-service:latest                                                │ │ │
│  │  │  • notification-service:latest                                           │ │ │
│  │  │  • frontend-ui:latest                                                    │ │ │
│  │  └──────────────────────────────────────────────────────────────────────────┘ │ │
│  │                                                                                │ │
│  │  ┌──────────────────────────────────────────────────────────────────────────┐ │ │
│  │  │  LOG ANALYTICS WORKSPACE                                                 │ │ │
│  │  │  • Container Insights                                                    │ │ │
│  │  │  • Application Logs                                                      │ │ │
│  │  │  • Performance Metrics                                                   │ │ │
│  │  └──────────────────────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │             TERRAFORM STATE RESOURCE GROUP: terraform-state-rg                │ │
│  │                                                                                │ │
│  │  ┌──────────────────────────────────────────────────────────────────────────┐ │ │
│  │  │  STORAGE ACCOUNT: tfstateaccountopening                                  │ │ │
│  │  │  Container: tfstate                                                      │ │ │
│  │  │  Blob: dev.terraform.tfstate                                             │ │ │
│  │  └──────────────────────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────────┐ │
│  │                         GITHUB ACTIONS (CI/CD)                                │ │ │
│  │  Workflows:                                                                   │ │ │
│  │  • Deploy to AKS (Dev) - Full deployment with automated testing              │ │ │
│  │  • Start Infrastructure - Start stopped AKS and PostgreSQL                   │ │ │
│  │  • Stop Infrastructure - Stop running infrastructure                         │ │ │
│  │  • Destroy Infrastructure - Delete all resources                             │ │ │
│  │                                                                                │ │ │
│  │  Authentication: OIDC (No secrets stored)                                     │ │ │
│  └────────────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────────────┘

INTERNET
   ↓
[Azure Load Balancer]
   ↓
68.220.25.83 (Public IP)
   ↓
[Frontend UI Service]
   ↓
[Frontend UI Pod] → [Backend Services] → [PostgreSQL via Private Network]
```

### Component Architecture

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

## Testing in Azure

After deployment, test your application:

### Quick Access
1. Get the frontend LoadBalancer IP:
   ```powershell
   kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

2. Open in browser: `http://<EXTERNAL-IP>` (e.g., `http://68.220.25.83`)

3. Test the UI:
   - Create customers
   - Upload documents
   - Open accounts
   - View notifications

### Detailed Testing
See **[TESTING_GUIDE.md](TESTING_GUIDE.md)** for complete testing instructions including:
- How to find external IPs
- Testing frontend UI functionality
- Testing backend services
- Health checks and troubleshooting
- Database connectivity testing

## Database Setup

The application uses PostgreSQL with the following databases:
- `customerdb` - Customer Service
- `documentdb` - Document Service
- `accountdb` - Account Service
- `notificationdb` - Notification Service

**Security:** PostgreSQL is deployed with **private VNet integration** (no public access). The database is only accessible from the AKS subnet via private networking.

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
