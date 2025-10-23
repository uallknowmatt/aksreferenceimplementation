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
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Support](#support)

---

## Overview

The **Bank Account Opening System** is a production-ready, cloud-native application that demonstrates enterprise-level microservices architecture deployed on Azure. It provides a complete digital workflow for opening bank accounts, including customer onboarding, document verification, account creation, and notifications.

### Business Value

- **Faster Time to Market** - Deploy complete infrastructure in 15-20 minutes
- **Cost Efficiency** - Automated cost management (~$53/month running, ~$1/month stopped)
- **High Availability** - Kubernetes auto-scaling and self-healing
- **Security First** - Private networking, secret management, Azure RBAC
- **Developer Productivity** - One-command deployments, automated testing
- **Compliance Ready** - Audit logs, security policies, encrypted data

---

## Quick Start

### For Developers (Local Development)

```bash
# Start all services with Docker Compose
docker-compose up -d

# Access application
open http://localhost:3000
```

**See:** [Local Development Guide](docs/LOCAL_DEVELOPMENT.md)

### For DevOps (Azure Deployment)

```bash
# Deploy to Azure (automated via GitHub Actions)
git push origin main

# OR manual deployment
cd infrastructure/environments/dev
terraform init
terraform apply
```

**See:** [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) | [Infrastructure Management](docs/INFRASTRUCTURE_MANAGEMENT.md)

### For Business Users (Testing)

1. Get application URL from IT/DevOps
2. Open browser: `http://<EXTERNAL-IP>`
3. Follow testing scenarios

**See:** [Business User Testing Guide](docs/BUSINESS_USER_TESTING.md) | [Application Access](docs/APPLICATION_ACCESS.md)

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

### Azure Architecture

```
Internet → Azure Load Balancer → AKS Cluster → 4 Microservices → PostgreSQL (Private VNet)
```

**For detailed diagrams:** See [Technology Deep Dive](docs/TECHNOLOGY_DEEP_DIVE.md)

---

## Documentation

### 📚 Complete Documentation Library

#### For Developers
- **[Local Development Guide](docs/LOCAL_DEVELOPMENT.md)** - Setup and run locally with Docker Compose
- **[Technology Deep Dive](docs/TECHNOLOGY_DEEP_DIVE.md)** - Architecture, components, network design
- **[Testing Guide](docs/TESTING_GUIDE.md)** - Automated and manual testing procedures

#### For DevOps Engineers
- **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** - CI/CD pipeline and deployment procedures
- **[Infrastructure Management](docs/INFRASTRUCTURE_MANAGEMENT.md)** - Create, start, stop, destroy infrastructure
- **[Application Access](docs/APPLICATION_ACCESS.md)** - How to get LoadBalancer IP and access application
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Azure Portal Guide](docs/AZURE_PORTAL_GUIDE.md)** - Using Azure Portal for management
- **[Cost Optimization Guide](docs/COST_OPTIMIZATION_GUIDE.md)** - Reduce Azure costs

#### For Business Users
- **[Business User Testing Guide](docs/BUSINESS_USER_TESTING.md)** - Step-by-step manual testing scenarios
- **[Application Access](docs/APPLICATION_ACCESS.md)** - How to access and use the application

#### Reference Documentation
- **[GitHub Environment Setup](docs/GITHUB_ENVIRONMENT_SETUP.md)** - Configure GitHub Actions and OIDC
- **[Terraform State Management](docs/TERRAFORM_STATE_MANAGEMENT.md)** - Remote state configuration
- **[Bash Conversion Summary](docs/BASH_CONVERSION_SUMMARY.md)** - PowerShell to Bash migration

---

## Key Features

### Application Features
✅ **Customer Onboarding** - Digital registration with KYC verification
✅ **Document Management** - Secure upload and verification of ID proofs
✅ **Account Creation** - Multiple account types (Checking, Savings, Money Market)
✅ **Notifications** - Email/SMS alerts for status updates
✅ **Audit Trail** - Complete tracking of all operations

### Technical Features
✅ **Microservices Architecture** - 4 independent, scalable services
✅ **Cloud-Native** - Containerized with Docker, orchestrated with Kubernetes
✅ **Secure Private Networking** - PostgreSQL with VNet integration (no public access)
✅ **Infrastructure as Code** - Full Terraform automation
✅ **CI/CD Pipeline** - GitHub Actions with OIDC authentication
✅ **Automated Testing** - 6 comprehensive health checks after deployment
✅ **Self-Healing** - Kubernetes auto-recovery and health checks
✅ **Cost Optimized** - Start/stop infrastructure to save 85% costs

---

## Technology Stack

### Frontend
- **React 19.x** - Modern UI framework
- **React Router** - Client-side routing
- **Axios** - HTTP client
- **Nginx** - Production web server

### Backend
- **Spring Boot 3.x** - Java 17 microservices framework
- **Spring Data JPA** - Database access layer
- **Liquibase** - Database migrations
- **Spring Boot Actuator** - Health checks and monitoring

### Infrastructure
- **Azure Kubernetes Service (AKS)** - Container orchestration
- **Azure Container Registry (ACR)** - Docker image storage
- **PostgreSQL 15 Flexible Server** - Database (VNet integrated)
- **Azure Virtual Network** - Private networking
- **Azure Load Balancer** - Traffic distribution
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD automation

### Development Tools
- **Docker & Docker Compose** - Local development
- **Maven** - Java build tool
- **Git** - Version control
- **VS Code** - Recommended IDE

---

## Project Structure

```
accountopening/
├── customer-service/          # Customer management microservice
├── document-service/          # Document upload microservice
├── account-service/           # Account creation microservice
├── notification-service/      # Notification microservice
├── frontend/
│   └── account-opening-ui/    # React frontend application
├── infrastructure/            # Terraform IaC
│   ├── main.tf               # Main configuration
│   ├── aks.tf                # AKS cluster
│   ├── postgres.tf           # PostgreSQL database
│   ├── network.tf            # VNet and subnets
│   └── environments/
│       ├── dev/              # Dev environment
│       └── prod/             # Prod environment
├── k8s/                      # Kubernetes manifests
│   ├── *-deployment.yaml     # Deployments
│   ├── *-service.yaml        # Services
│   ├── *-configmap.yaml      # ConfigMaps
│   └── *-secret.yaml         # Secrets
├── scripts/
│   └── educational/          # Helper scripts
├── docs/                     # Documentation
├── docker-compose.yml        # Local development
└── README.md                 # This file
```

---

## Component Services

| Service | Port | Purpose | Health Check | Database |
|---------|------|---------|--------------|----------|
| **Customer Service** | 8081 | Customer registration & KYC | /actuator/health | customerdb |
| **Document Service** | 8082 | Document upload & verification | /actuator/health | documentdb |
| **Account Service** | 8083 | Account creation & management | /actuator/health | accountdb |
| **Notification Service** | 8084 | Email/SMS notifications | /actuator/health | notificationdb |
| **Frontend UI** | 80 | React web application | /health | N/A |
| **PostgreSQL** | 5432 | Database server (private) | TCP check | All databases |

---

## Cost Management

### Monthly Costs (Development Environment)

| Scenario | Monthly Cost | Savings |
|----------|--------------|---------|
| **Running 24/7** | ~$110-135 | - |
| **Stopped (nights/weekends)** | ~$50-75 | 47% |
| **Completely Stopped** | ~$10-20 | 85% |

### Quick Commands

```bash
# Stop infrastructure (save money)
cd scripts/educational && ./stop-infra.sh

# Start infrastructure
cd scripts/educational && ./start-infra.sh

# Check status
cd scripts/educational && ./check-infra-status.sh
```

**For detailed cost optimization:** See [Infrastructure Management](docs/INFRASTRUCTURE_MANAGEMENT.md#cost-management)

---

## Contributing

### Development Workflow

1. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes and test locally:**
   ```bash
   docker-compose up -d
   # Test your changes
   ```

3. **Commit with conventional commits:**
   ```bash
   git commit -m "feat: add new feature"
   git commit -m "fix: resolve bug"
   git commit -m "docs: update documentation"
   ```

4. **Push and create PR:**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Automated deployment to dev:**
   - Push to `main` → Deploys to dev automatically
   - Complete UAT testing
   - Approve for production deployment

---

## Support

### Getting Help

**For Issues:**
1. Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Review [Documentation](#documentation) for your role
3. Check GitHub Issues
4. Contact DevOps team

**For Questions:**
- Technical: See [Technology Deep Dive](docs/TECHNOLOGY_DEEP_DIVE.md)
- Deployment: See [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- Testing: See [Testing Guide](docs/TESTING_GUIDE.md)

### Quick Diagnostic

```bash
# Check all services
cd scripts/educational
./check-services.sh          # Local services
./check-infra-status.sh      # Azure infrastructure

# Get application URL
kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

---

## License

[Your License Here]

---

## Acknowledgments

Built with enterprise-grade practices for cloud-native microservices on Azure.

**Key Technologies:**
- Microsoft Azure (AKS, ACR, PostgreSQL, VNet)
- Kubernetes & Docker
- Spring Boot & React
- Terraform & GitHub Actions

---

**📖 For detailed information, see the [Documentation](#documentation) section above.**

**🚀 Ready to get started? Choose your path:**
- **Developer:** [Local Development Guide](docs/LOCAL_DEVELOPMENT.md)
- **DevOps:** [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- **Business User:** [Business User Testing Guide](docs/BUSINESS_USER_TESTING.md)
