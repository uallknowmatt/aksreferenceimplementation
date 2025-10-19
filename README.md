# 🏦 Account Opening Application# Bank Account Opening System



A complete account opening system built with **Spring Boot microservices** and **React frontend**.This is a microservices-based system for bank account opening, built with Spring Boot and deployed on Azure Kubernetes Service (AKS).



---## Architecture



## 🚀 Quick StartThe system consists of the following microservices:



**New to this project? Start here:**- **Customer Service**: Handles customer information and KYC processes

- **Document Service**: Manages document upload and verification

1. **[QUICK_START.md](QUICK_START.md)** - Fast-track setup guide (⭐ start here!)- **Account Service**: Handles account creation and management

2. **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** - Step-by-step checklist to track your progress- **Notification Service**: Manages all notifications and communications

3. **[POSTGRESQL_WINDOWS_SETUP.md](POSTGRESQL_WINDOWS_SETUP.md)** - Database installation guide

## Technology Stack

**Already set up?**

```powershell- Java 17

# Start everything- Spring Boot 3.x

.\start-all-services.ps1           # Backend (4 services)- Maven

cd frontend\account-opening-ui; npm start  # Frontend- Azure Kubernetes Service (AKS)

- Terraform for infrastructure

# Check health

.\check-services.ps1## Project Structure

```

```

---account-opening-system/

├── customer-service/     # Customer management and KYC

## 📚 Documentation├── document-service/     # Document handling

├── account-service/      # Account management

### Setup & Installation├── notification-service/ # Notifications

- **[QUICK_START.md](QUICK_START.md)** - Complete setup in under 10 minutes└── infrastructure/      # Terraform IaC for AKS

- **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** - 159-point checklist for setup validation```

- **[POSTGRESQL_WINDOWS_SETUP.md](POSTGRESQL_WINDOWS_SETUP.md)** - PostgreSQL installation and configuration

- **[COMPLETE_SETUP_SUMMARY.md](COMPLETE_SETUP_SUMMARY.md)** - Comprehensive overview of everything## Prerequisites



### Troubleshooting & Fixes- Java 17 or higher

- **[CRITICAL_FIX_GUIDE.md](CRITICAL_FIX_GUIDE.md)** - Application troubleshooting- Maven 3.8+

- **[COMPLETE_FIX_SUMMARY.md](COMPLETE_FIX_SUMMARY.md)** - All fixes applied to the application- Docker

- **[BACKEND_STARTUP_GUIDE.md](BACKEND_STARTUP_GUIDE.md)** - Backend service details- Azure CLI

- Terraform

### Frontend- Kubernetes CLI (kubectl)

- **[frontend/account-opening-ui/FRONTEND_README.md](frontend/account-opening-ui/FRONTEND_README.md)** - React app documentation

- **[frontend/account-opening-ui/QUICKSTART.md](frontend/account-opening-ui/QUICKSTART.md)** - Frontend quick reference## Building the Project

- **[frontend/account-opening-ui/TESTING_CHECKLIST.md](frontend/account-opening-ui/TESTING_CHECKLIST.md)** - Frontend testing guide

To build all services:

### Docker (Alternative Setup)

- **[DOCKER_LOCAL_SETUP.md](DOCKER_LOCAL_SETUP.md)** - Docker Compose setup```bash

- **[DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md)** - Docker quick referencemvn clean install

- **Note:** Docker requires virtualization. Use native PostgreSQL if Docker not available.```



---## Running Locally



## 🏗️ ArchitectureEach service can be run locally using:



### Microservices```bash

cd <service-name>

| Service | Port | Database | Description |mvn spring-boot:run

|---------|------|----------|-------------|```

| **Customer Service** | 8081 | customerdb | Customer information management |

| **Document Service** | 8082 | documentdb | Document upload and storage |## Deployment

| **Account Service** | 8083 | accountdb | Account creation and management |

| **Notification Service** | 8084 | notificationdb | Notification delivery |The services are deployed to AKS using Terraform and Kubernetes manifests. See the infrastructure directory for details.



### Frontend## Deployment Steps



| Component | Port | Description |1. **Provision Azure Infrastructure**

|-----------|------|-------------|   - Edit `dev.tfvars` or `prod.tfvars` with your environment settings.

| **React UI** | 3000 | Material-UI based account opening wizard |   - Run Terraform to create resources:

     ```bash

### Database     terraform init

     terraform workspace select dev   # or prod

| Database | Type | Connection |     terraform apply -var-file="dev.tfvars"   # or prod.tfvars

|----------|------|------------|     ```

| **PostgreSQL 15** | Single Instance | localhost:5432 |   - This will create AKS, ACR, PostgreSQL, VNet, subnets, and all security resources.

| - customerdb | Database | Customer data |

| - documentdb | Database | Document metadata |2. **Build and Push Microservice Images**

| - accountdb | Database | Account information |   - Ensure Docker and Maven are installed locally or use the provided GitHub Actions pipeline.

| - notificationdb | Database | Notification history |   - Build and push images to Azure Container Registry:

     ```bash

---     mvn clean package -DskipTests

     docker build -t <ACR_LOGIN_SERVER>/customer-service:<tag> ./customer-service

## 🎯 Features     docker build -t <ACR_LOGIN_SERVER>/document-service:<tag> ./document-service

     docker build -t <ACR_LOGIN_SERVER>/account-service:<tag> ./account-service

✅ **Complete Account Opening Workflow**     docker build -t <ACR_LOGIN_SERVER>/notification-service:<tag> ./notification-service

- 4-step wizard with validation     docker push <ACR_LOGIN_SERVER>/customer-service:<tag>

- Customer information capture     docker push <ACR_LOGIN_SERVER>/document-service:<tag>

- Document upload (PDF, JPG, PNG)     docker push <ACR_LOGIN_SERVER>/account-service:<tag>

- Account type selection     docker push <ACR_LOGIN_SERVER>/notification-service:<tag>

- Review and submission     ```

   - Or let GitHub Actions handle this automatically on push to `main`.

✅ **Entity Management**

- View all customers3. **Configure Kubernetes Manifests**

- View all accounts   - Place your deployment and service YAML files in the `k8s/` directory:

- View all documents     - `customer-service-deployment.yaml`, `customer-service-service.yaml`, etc.

- View notification history     - Include environment variables for DB connection, ACR image, etc.

     - Optionally add `ingress.yaml` for API Gateway routing.

✅ **Technical Features**

- RESTful API design4. **Deploy to AKS**

- CORS enabled   - Use `kubectl` to apply manifests:

- Form validation     ```bash

- Error handling     az aks get-credentials --resource-group <resource-group> --name <aks-cluster>

- Material-UI design system     kubectl apply -f k8s/customer-service-deployment.yaml

- Responsive layout     kubectl apply -f k8s/customer-service-service.yaml

- Hot-reload development     # Repeat for other services

     kubectl apply -f k8s/ingress.yaml   # if using ingress

---     ```

   - Or let GitHub Actions deploy automatically via `.github/workflows/aks-deploy.yml`.

## 📋 Prerequisites

5. **Monitor and Troubleshoot**

- ✅ Java 17 or higher   - Use Azure Portal, Log Analytics, and `kubectl` to monitor deployments.

- ✅ Maven 3.6+   - See [aksissues.md](./aksissues.md) for common AKS issues and solutions.

- ✅ Node.js 14+ and npm

- ✅ PostgreSQL 15### Passwordless PostgreSQL Login

- The PostgreSQL Flexible Server is configured for Azure AD authentication (passwordless).

**Check your versions:**- AKS pods/services should use managed identities and Azure AD tokens to connect securely.

```powershell- See [Azure docs](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-azure-ad-authentication) for setup and connection details.

java -version

mvn -version## Azure Architecture Diagram

node -version

``````mermaid

flowchart TD

---    %% Resource Group

    RG["Resource Group"]

## 🚀 Running the Application    %% Virtual Network

    VNet["Virtual Network"]

### First Time Setup    RG --> VNet

    %% AKS Cluster

**Step 1: Install PostgreSQL**    AKS["AKS Cluster"]

```powershell    VNet --> AKS

# Download from https://www.postgresql.org/download/windows/    %% Node Pool

# Install with password: postgres    NodePool["Node Pool (VMSS)"]

# Keep default port: 5432    AKS --> NodePool

```    %% Pods and Containers

    Pod1["Pod: customer-service"]

**Step 2: Create Databases**    Pod2["Pod: document-service"]

```powershell    Pod3["Pod: account-service"]

cd c:\genaiexperiments\accountopening    Pod4["Pod: notification-service"]

.\setup-databases.ps1    NodePool --> Pod1

```    NodePool --> Pod2

    NodePool --> Pod3

**Step 3: Start Backend Services**    NodePool --> Pod4

```powershell    C1["Container: customer-service"]

.\start-all-services.ps1    C2["Container: document-service"]

```    C3["Container: account-service"]

*Waits for 4 PowerShell windows to show "Started...Application"*    C4["Container: notification-service"]

    Pod1 --> C1

**Step 4: Start Frontend**    Pod2 --> C2

```powershell    Pod3 --> C3

cd frontend\account-opening-ui    Pod4 --> C4

npm install  # First time only    %% Ingress Controller

npm start    Ingress["Ingress Controller / API Gateway"]

```    AKS --> Ingress

    Internet((Internet)) --> Ingress

**Step 5: Open Application**    Ingress --> C1

```    Ingress --> C2

http://localhost:3000    Ingress --> C3

```    Ingress --> C4

    %% Azure Container Registry

### Daily Development    ACR["Azure Container Registry"]

    RG --> ACR

```powershell    AKS -.-> ACR

# Start backend    %% Azure PostgreSQL Databases

.\start-all-services.ps1    DB1["Azure PostgreSQL: customerdb"]

    DB2["Azure PostgreSQL: documentdb"]

# Start frontend (new window)    DB3["Azure PostgreSQL: accountdb"]

cd frontend\account-opening-ui    DB4["Azure PostgreSQL: notificationdb"]

npm start    RG --> DB1

    RG --> DB2

# Check everything is running    RG --> DB3

.\check-services.ps1    RG --> DB4

```    C1 -- "JDBC" --> DB1

    C2 -- "JDBC" --> DB2

---    C3 -- "JDBC" --> DB3

    C4 -- "JDBC" --> DB4

## ✅ Testing```



### Backend Tests## AKS Troubleshooting & Solutions

```powershell

mvn testSee [aksissues.md](./aksissues.md) for common AKS issues and solutions.

```

**Expected:** 123/123 tests passing## Kubernetes Manifests: Purpose & Creation



### Frontend TestsKubernetes manifests are YAML files that define how your microservices are deployed, configured, and exposed in the AKS cluster. They are essential for:

```powershell- Declaring deployments, services, ingress, and other resources in a reproducible, version-controlled way.

cd frontend\account-opening-ui- Specifying container images, resource limits, environment variables, secrets, and configmaps for each microservice.

npm test- Enabling automated, consistent deployments across environments (dev/prod).

```

**Expected:** 78/78 checks passing### Why Use Kubernetes Manifests?

- **Declarative Infrastructure**: Manifests allow you to describe the desired state of your application and infrastructure. Kubernetes ensures the cluster matches this state.

### End-to-End Test- **Portability**: Manifests can be reused across clusters and environments, making it easy to replicate or migrate deployments.

1. Open http://localhost:3000- **Automation**: CI/CD pipelines can apply manifests automatically, enabling rapid, reliable deployments.

2. Click "Open New Account"- **Security & Configuration**: Secrets, configmaps, and identity settings are managed securely and injected into pods via manifests.

3. Complete all 4 steps

4. Submit application### Creating Manifests for Each Microservice

5. Verify success message1. **Create a `k8s/` Directory**

6. Check data persisted in PostgreSQL   - Place all manifest files in the `k8s/` directory at the project root.



---2. **Write Deployment YAMLs**

   - For each microservice, create a deployment file (e.g., `customer-service-deployment.yaml`).

## 🛠️ Common Commands   - Example:

     ```yaml

### Service Management     apiVersion: apps/v1

```powershell     kind: Deployment

# Check all services     metadata:

.\check-services.ps1       name: customer-service

     spec:

# Stop services: Close PowerShell windows or Ctrl+C       replicas: 2

       selector:

# Restart PostgreSQL         matchLabels:

Restart-Service postgresql-x64-15           app: customer-service

       template:

# Check PostgreSQL status         metadata:

Get-Service postgresql*           labels:

```             app: customer-service

         spec:

### Database Operations           containers:

```powershell           - name: customer-service

# List databases             image: <ACR_LOGIN_SERVER>/customer-service:<tag>

psql -U postgres -c "\l"             env:

             - name: SPRING_DATASOURCE_URL

# View customer data               valueFrom:

psql -U postgres -d customerdb -c "SELECT * FROM customer;"                 configMapKeyRef:

                   name: customer-service-config

# View account data                   key: db-url

psql -U postgres -d accountdb -c "SELECT * FROM account;"             - name: SPRING_DATASOURCE_USERNAME

               valueFrom:

# Reset databases (drops all data!)                 secretKeyRef:

psql -U postgres                   name: customer-service-secret

DROP DATABASE customerdb;                   key: db-username

DROP DATABASE documentdb;             - name: SPRING_DATASOURCE_PASSWORD

DROP DATABASE accountdb;               valueFrom:

DROP DATABASE notificationdb;                 secretKeyRef:

\q                   name: customer-service-secret

.\setup-databases.ps1                   key: db-password

```     ```



### Build Operations3. **Write Service YAMLs**

```powershell   - For each microservice, create a service file (e.g., `customer-service-service.yaml`).

# Clean build   - Example:

mvn clean compile -DskipTests     ```yaml

     apiVersion: v1

# Full build with tests     kind: Service

mvn clean install     metadata:

       name: customer-service

# Build specific service     spec:

cd customer-service       selector:

mvn clean install         app: customer-service

```       ports:

         - protocol: TCP

---           port: 80

           targetPort: 8080

## 🐛 Troubleshooting     ```



### PostgreSQL Not Running4. **Add Ingress (Optional)**

```powershell   - Create an `ingress.yaml` for API Gateway/routing if needed.

Start-Service postgresql-x64-15

```5. **Repeat for All Microservices**

   - Follow the same pattern for document-service, account-service, and notification-service.

### Port Already in Use

```powershell## AKS Pod Identity/Workload Identity for Passwordless PostgreSQL

# Find process using port 8081

netstat -ano | findstr :8081To enable passwordless access to Azure PostgreSQL from AKS pods:

- Use Azure AD authentication and assign a managed identity to your pods via AKS workload identity.

# Kill process (replace PID)- Update your manifests to reference the identity and configure the JDBC connection to use Azure AD tokens.

taskkill /PID [PID] /F- See [Azure docs](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) for setup steps.

```

**Manual Steps or IaC:**

### Cannot Connect to Database- Create a managed identity in Azure.

```powershell- Assign the identity to the AKS node pool or specific pods using annotations in your deployment YAMLs:

# Test connection  ```yaml

psql -U postgres -c "SELECT version();"  spec:

    template:

# If fails, check password in application.yml files      metadata:

# Default password: postgres        annotations:

```          azure.workload.identity/client-id: <MANAGED_IDENTITY_CLIENT_ID>

  ```

### Frontend Errors- Grant the identity access to PostgreSQL (via Azure portal or Terraform).

```powershell- Configure your Spring Boot app to use Azure AD authentication for JDBC.

# Clear and reinstall dependencies

cd frontend\account-opening-ui## Secrets and ConfigMaps for DB Connection

rm -r -force node_modules

rm -r -force build- **ConfigMaps**: Store non-sensitive configuration (e.g., DB URL).

npm install- **Secrets**: Store sensitive data (e.g., DB username, password, Azure AD token if needed).

npm start- Reference these in your deployment manifests as shown above.

```- Create them using kubectl or YAML files:

  ```bash

**For more troubleshooting:** See [CRITICAL_FIX_GUIDE.md](CRITICAL_FIX_GUIDE.md)  kubectl create configmap customer-service-config --from-literal=db-url=<JDBC_URL>

  kubectl create secret generic customer-service-secret --from-literal=db-username=<USERNAME> --from-literal=db-password=<PASSWORD>

---  ```

- Or define them in YAML and apply with `kubectl apply -f`.

## 📊 Testing the Setup



### Health Check## Automating Kubernetes Secret Creation

```powershell

.\check-services.ps1To automate secret creation for each microservice, use the following PowerShell script. This script prompts for DB username and password, encodes them in base64, and creates the Kubernetes secret using `kubectl`.

```

### PowerShell Script Example

**Expected output:**```powershell

```# Set variables for each microservice

✅ Customer Service: Running (http://localhost:8081)$services = @('customer-service', 'document-service', 'account-service', 'notification-service')

✅ Document Service: Running (http://localhost:8082)foreach ($service in $services) {

✅ Account Service: Running (http://localhost:8083)    Write-Host "Creating secret for $service..."

✅ Notification Service: Running (http://localhost:8084)    $username = Read-Host "Enter DB username for $service"

✅ Frontend: Running (http://localhost:3000)    $password = Read-Host "Enter DB password for $service"

✅ PostgreSQL: Running    kubectl create secret generic "$service-secret" `

```        --from-literal=db-username=$username `

        --from-literal=db-password=$password

### Test Endpoints}

```powershell```

curl http://localhost:8081/api/customers

curl http://localhost:8082/api/documents### Usage

curl http://localhost:8083/api/accounts1. Ensure you are connected to your AKS cluster:

curl http://localhost:8084/api/notifications   ```powershell

```   az aks get-credentials --resource-group <resource-group> --name <aks-cluster>

   ```

---2. Run the script above in PowerShell. Enter the DB username and password for each microservice when prompted.

3. The secrets will be created in Kubernetes and referenced by your deployment manifests.

## 🌐 API Endpoints

**Note:**

### Customer Service (8081)- You can customize the script to read credentials from environment variables or a secure vault for CI/CD automation.

- `GET /api/customers` - Get all customers- For production, consider using Azure Key Vault with CSI driver for secret injection.

- `GET /api/customers/{id}` - Get customer by ID

- `POST /api/customers` - Create customerThis approach ensures secrets are created securely and consistently for all microservices during deployment.



### Document Service (8082)## Automating Secret Creation in CI/CD Pipeline

- `GET /api/documents` - Get all documents

- `GET /api/documents/{id}` - Get document by IDYou can automate Kubernetes secret creation in your CI/CD pipeline (e.g., GitHub Actions) using environment variables or secret managers. This ensures secrets are created securely and consistently during deployment, without manual input.

- `POST /api/documents` - Upload document

### Example: GitHub Actions Step

### Account Service (8083)Add the following step to your workflow (e.g., `.github/workflows/aks-deploy.yml`):

- `GET /api/accounts` - Get all accounts

- `GET /api/accounts/{id}` - Get account by ID```yaml

- `POST /api/accounts` - Create account- name: Create Kubernetes Secrets for Microservices

  run: |

### Notification Service (8084)    for service in customer-service document-service account-service notification-service; do

- `GET /api/notifications` - Get all notifications      kubectl create secret generic "$service-secret" \

- `GET /api/notifications/{id}` - Get notification by ID        --from-literal=db-username="$DB_USERNAME" \

- `POST /api/notifications` - Create notification        --from-literal=db-password="$DB_PASSWORD" \

        --dry-run=client -o yaml | kubectl apply -f -

---    done

  env:

## 🗂️ Project Structure    DB_USERNAME: ${{ secrets.DB_USERNAME }}

    DB_PASSWORD: ${{ secrets.DB_PASSWORD }}

``````

accountopening/

├── 📄 README.md                        # This file - start here!### Best Practices

├── 📄 QUICK_START.md                   # Fast setup guide- Store DB credentials as encrypted secrets in your CI/CD platform (e.g., GitHub Secrets).

├── 📄 SETUP_CHECKLIST.md               # 159-point checklist- Use `--dry-run=client -o yaml | kubectl apply -f -` to make secret creation idempotent.

├── 📄 POSTGRESQL_WINDOWS_SETUP.md      # Database setup- For production, consider using Azure Key Vault with CSI driver for direct secret injection into pods.

├── 📄 COMPLETE_SETUP_SUMMARY.md        # Complete overview

│This approach enables fully automated, secure secret management as part of your deployment pipeline.

├── 🔧 setup-databases.ps1              # Database creation script

├── 🔧 start-all-services.ps1           # Start all backend services## Full Deployment Workflow

├── 🔧 check-services.ps1               # Health check script

│1. **Provision Infrastructure**

├── 🎯 customer-service/                # Service 1: Customers   - Run `terraform init` and `terraform apply -var-file="dev.tfvars"` (or `prod.tfvars`).

├── 🎯 document-service/                # Service 2: Documents2. **Build & Push Images**

├── 🎯 account-service/                 # Service 3: Accounts   - Use Docker/Maven or GitHub Actions pipeline.

├── 🎯 notification-service/            # Service 4: Notifications3. **Create Kubernetes Manifests**

│   - Place all YAML files in `k8s/`.

├── 🎨 frontend/                        # React application   - Configure pod identity, secrets, and configmaps as described.

│   └── account-opening-ui/4. **Deploy to AKS**

│       ├── src/   - Use `kubectl apply -f k8s/` to deploy all manifests.

│       │   ├── components/            # React components5. **Monitor & Troubleshoot**

│       │   ├── pages/                 # Page components   - Use Azure Portal, Log Analytics, and `kubectl`.

│       │   ├── services/              # API clients

│       │   └── App.js                 # Main appFor more details, see [aksissues.md](./aksissues.md) and Azure documentation.

│       └── package.json
│
├── 🐳 docker/                          # Docker setup (alternative)
│   └── init-scripts/
│
├── ☸️ k8s/                             # Kubernetes manifests
│
└── 🏗️ infrastructure/                  # Terraform (Azure deployment)
```

---

## 🎓 Tech Stack

### Backend
- Java 17
- Spring Boot 3.1.5
- Spring Data JPA
- PostgreSQL Driver
- Maven 3.9.11

### Frontend
- React 18.2.0
- Material-UI 5.14.0
- Axios 1.4.0
- React Router 6.14.0

### Database
- PostgreSQL 15
- pgAdmin 4

### DevOps
- Docker (optional)
- Kubernetes
- Terraform
- GitHub Actions

---

## 📈 Test Coverage

- **Backend:** 123 tests, 82-87% coverage
- **Frontend:** 78 checks, 100% passing
- **Integration:** End-to-end workflow tested

---

## 🚀 Next Steps

### After Local Testing
1. ☁️ Deploy to Azure
2. 🔒 Add authentication
3. 📊 Add monitoring
4. 🔄 Set up CI/CD
5. 📝 Add audit logging

### Infrastructure Ready
- Terraform code in `infrastructure/`
- Kubernetes manifests in `k8s/`
- GitHub Actions in `.github/workflows/`

---

## 📞 Need Help?

### Quick Troubleshooting
1. **Check services:** `.\check-services.ps1`
2. **Check PostgreSQL:** `Get-Service postgresql*`
3. **Check logs:** Each service window shows detailed logs
4. **Check browser console:** Press F12 for frontend errors

### Documentation
- [QUICK_START.md](QUICK_START.md) - Setup and common issues
- [CRITICAL_FIX_GUIDE.md](CRITICAL_FIX_GUIDE.md) - Troubleshooting
- [POSTGRESQL_WINDOWS_SETUP.md](POSTGRESQL_WINDOWS_SETUP.md) - Database help

---

## 📄 License

This project is for educational and demonstration purposes.

---

## 🎯 Status

✅ **Code:** Complete and tested  
✅ **Documentation:** Comprehensive guides available  
✅ **Backend:** 123/123 tests passing  
✅ **Frontend:** 78/78 checks passing  
⏳ **Setup:** Requires PostgreSQL installation

**Ready for local testing and cloud deployment!**

---

**Quick Links:**
- 🚀 [Get Started](QUICK_START.md)
- ✅ [Setup Checklist](SETUP_CHECKLIST.md)
- 🗄️ [Database Setup](POSTGRESQL_WINDOWS_SETUP.md)
- 🐛 [Troubleshooting](CRITICAL_FIX_GUIDE.md)

---

**Version:** 1.0.0-SNAPSHOT  
**Last Updated:** December 2024
