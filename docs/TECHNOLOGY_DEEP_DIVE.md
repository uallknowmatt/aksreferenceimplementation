# Technology Deep Dive

This document provides detailed technical information about the application architecture, infrastructure components, and technology stack.

## Table of Contents
- [Azure Architecture Diagrams](#azure-architecture-diagrams)
- [Application Layer](#application-layer)
- [Infrastructure Layer](#infrastructure-layer)
- [Network Architecture](#network-architecture)
- [Database Layer](#database-layer)
- [Load Balancer](#load-balancer)

---

## Azure Architecture Diagrams

### High-Level Azure Architecture

```mermaid
graph TB
    subgraph Internet
        User[👤 End User<br/>Web Browser]
    end
    
    subgraph Azure["☁️ Azure Cloud"]
        subgraph RG["Resource Group: rg-account-opening-dev-eastus2"]
            
            subgraph LB_Section["Azure Load Balancer"]
                LB[🔀 Load Balancer<br/>Standard SKU<br/>Public IP: Dynamic]
            end
            
            subgraph VNet["Virtual Network: vnet-account-opening-dev-eastus2<br/>Address Space: 10.0.0.0/16"]
                
                subgraph AKS_Subnet["AKS Subnet: 10.0.1.0/24"]
                    subgraph AKS["AKS Cluster: aks-account-opening-dev-eastus2"]
                        subgraph Pods["Kubernetes Pods"]
                            FE[🖥️ Frontend UI<br/>Port: 80<br/>Nginx + React]
                            CS[⚙️ Customer Service<br/>Port: 8081<br/>Spring Boot]
                            DS[📄 Document Service<br/>Port: 8082<br/>Spring Boot]
                            AS[💳 Account Service<br/>Port: 8083<br/>Spring Boot]
                            NS[📧 Notification Service<br/>Port: 8084<br/>Spring Boot]
                        end
                    end
                end
                
                subgraph ACR_Subnet["ACR Subnet: 10.0.2.0/24"]
                    ACR_PE[🔒 ACR Private Endpoint<br/>10.0.2.x]
                end
                
                subgraph PG_Subnet["PostgreSQL Subnet: 10.0.3.0/24<br/>Delegated to PostgreSQL"]
                    PG[🗄️ PostgreSQL Flexible Server<br/>Private IP: 10.0.3.x<br/>NO PUBLIC ACCESS]
                end
            end
            
            ACR[📦 Azure Container Registry<br/>Premium SKU<br/>Docker Images]
            
            LA[📊 Log Analytics<br/>Workspace<br/>Monitoring & Logs]
        end
    end
    
    User -->|HTTP Request| LB
    LB -->|Health Probe /health| FE
    LB -->|Traffic Distribution| FE
    
    FE -->|REST API| CS
    FE -->|REST API| DS
    FE -->|REST API| AS
    FE -->|REST API| NS
    
    CS -->|JDBC<br/>Port 5432| PG
    DS -->|JDBC<br/>Port 5432| PG
    AS -->|JDBC<br/>Port 5432| PG
    NS -->|JDBC<br/>Port 5432| PG
    
    AKS -->|Pull Images| ACR_PE
    ACR_PE -.->|Private Link| ACR
    
    AKS -->|Send Logs| LA
    PG -->|Send Logs| LA
    
    style User fill:#e1f5ff
    style LB fill:#ffeb99
    style AKS fill:#d4edda
    style FE fill:#cce5ff
    style CS fill:#fff3cd
    style DS fill:#fff3cd
    style AS fill:#fff3cd
    style NS fill:#fff3cd
    style PG fill:#f8d7da
    style ACR fill:#e7e7e7
    style LA fill:#d1ecf1
```

### Network Flow Diagram

```mermaid
flowchart LR
    subgraph Public["🌐 Public Internet"]
        Browser[Web Browser]
    end
    
    subgraph Azure["☁️ Azure Cloud - East US 2"]
        
        subgraph Edge["Edge Network"]
            ALB[Azure Load Balancer<br/>Public IP<br/>Standard SKU]
        end
        
        subgraph VNet["VNet: 10.0.0.0/16"]
            
            subgraph AKS_Net["AKS Subnet: 10.0.1.0/24"]
                K8S_SVC[Kubernetes Service<br/>frontend-ui<br/>Type: LoadBalancer]
                
                subgraph Pods["Pod Network"]
                    FE_Pod1[Frontend Pod 1<br/>10.0.1.10]
                    FE_Pod2[Frontend Pod 2<br/>10.0.1.11]
                end
                
                Backend_SVC[Backend Services<br/>ClusterIP<br/>Internal Only]
                
                subgraph Backend_Pods["Backend Pods"]
                    CS_Pod[Customer Service<br/>10.0.1.20]
                    DS_Pod[Document Service<br/>10.0.1.21]
                    AS_Pod[Account Service<br/>10.0.1.22]
                    NS_Pod[Notification Service<br/>10.0.1.23]
                end
            end
            
            subgraph PG_Net["PostgreSQL Subnet: 10.0.3.0/24"]
                PG_Server[(PostgreSQL<br/>10.0.3.5<br/>🔒 Private Only)]
            end
            
            subgraph ACR_Net["ACR Subnet: 10.0.2.0/24"]
                ACR_PE[ACR Endpoint<br/>10.0.2.5]
            end
        end
        
        ACR_Public[Azure Container Registry<br/>Private Access Only]
    end
    
    Browser -->|"① HTTP/80"| ALB
    ALB -->|"② Health Probe<br/>/health"| K8S_SVC
    ALB -->|"③ Forward Traffic"| K8S_SVC
    K8S_SVC -->|"④ Load Balance"| FE_Pod1
    K8S_SVC -->|"④ Load Balance"| FE_Pod2
    
    FE_Pod1 -->|"⑤ API Calls"| Backend_SVC
    FE_Pod2 -->|"⑤ API Calls"| Backend_SVC
    
    Backend_SVC --> CS_Pod
    Backend_SVC --> DS_Pod
    Backend_SVC --> AS_Pod
    Backend_SVC --> NS_Pod
    
    CS_Pod -->|"⑥ JDBC<br/>SSL/TLS"| PG_Server
    DS_Pod -->|"⑥ JDBC<br/>SSL/TLS"| PG_Server
    AS_Pod -->|"⑥ JDBC<br/>SSL/TLS"| PG_Server
    NS_Pod -->|"⑥ JDBC<br/>SSL/TLS"| PG_Server
    
    Pods -.->|"⑦ Pull Images<br/>via Private Link"| ACR_PE
    ACR_PE -.->|Private Connection| ACR_Public
    
    style Browser fill:#e1f5ff
    style ALB fill:#ffeb99
    style K8S_SVC fill:#d4edda
    style FE_Pod1 fill:#cce5ff
    style FE_Pod2 fill:#cce5ff
    style Backend_SVC fill:#fff3cd
    style PG_Server fill:#f8d7da
    style ACR_PE fill:#e7e7e7
```

### Kubernetes Service Mesh

```mermaid
graph TD
    subgraph External["External Traffic"]
        Internet[🌐 Internet Users]
    end
    
    subgraph K8s["Kubernetes Cluster"]
        
        subgraph Services["Kubernetes Services"]
            LB_SVC[frontend-ui Service<br/>Type: LoadBalancer<br/>Port: 80]
            
            CS_SVC[customer-service<br/>Type: ClusterIP<br/>Port: 80 → 8081]
            DS_SVC[document-service<br/>Type: ClusterIP<br/>Port: 80 → 8082]
            AS_SVC[account-service<br/>Type: ClusterIP<br/>Port: 80 → 8083]
            NS_SVC[notification-service<br/>Type: ClusterIP<br/>Port: 80 → 8084]
        end
        
        subgraph Frontend["Frontend Deployment"]
            FE1[frontend-ui Pod<br/>Replica 1<br/>nginx:80]
        end
        
        subgraph Backend["Backend Deployments"]
            CS1[customer-service Pod<br/>Replica 1<br/>8081]
            DS1[document-service Pod<br/>Replica 1<br/>8082]
            AS1[account-service Pod<br/>Replica 1<br/>8083]
            NS1[notification-service Pod<br/>Replica 1<br/>8084]
        end
        
        subgraph Config["Configuration"]
            CM_FE[ConfigMap<br/>frontend-ui-config<br/>Backend URLs]
            CM_CS[ConfigMap<br/>customer-service-config<br/>DB Host]
            
            SEC_CS[Secret<br/>customer-service-secret<br/>DB Credentials]
        end
    end
    
    subgraph Database["Database Layer"]
        PG[(PostgreSQL<br/>Flexible Server<br/>Private VNet)]
    end
    
    Internet -->|HTTP Request| LB_SVC
    LB_SVC --> FE1
    
    FE1 -->|/api/customers| CS_SVC
    FE1 -->|/api/documents| DS_SVC
    FE1 -->|/api/accounts| AS_SVC
    FE1 -->|/api/notifications| NS_SVC
    
    CS_SVC --> CS1
    DS_SVC --> DS1
    AS_SVC --> AS1
    NS_SVC --> NS1
    
    CS1 --> PG
    DS1 --> PG
    AS1 --> PG
    NS1 --> PG
    
    CM_FE -.->|Environment Variables| FE1
    CM_CS -.->|Environment Variables| CS1
    SEC_CS -.->|Secrets| CS1
    
    style Internet fill:#e1f5ff
    style LB_SVC fill:#ffeb99
    style FE1 fill:#cce5ff
    style CS_SVC fill:#d4edda
    style DS_SVC fill:#d4edda
    style AS_SVC fill:#d4edda
    style NS_SVC fill:#d4edda
    style CS1 fill:#fff3cd
    style DS1 fill:#fff3cd
    style AS1 fill:#fff3cd
    style NS1 fill:#fff3cd
    style PG fill:#f8d7da
    style CM_FE fill:#e7e7e7
    style CM_CS fill:#e7e7e7
    style SEC_CS fill:#ffe6e6
```

### Security Architecture

```mermaid
graph TB
    subgraph GitHub["GitHub Actions CI/CD"]
        GHA[GitHub Actions Workflow]
        OIDC[OIDC Authentication<br/>Federated Credentials]
    end
    
    subgraph Azure["Azure Cloud"]
        subgraph Identity["Identity & Access"]
            AAD[Azure Active Directory]
            MI_AKS[AKS Kubelet Identity<br/>Managed Identity]
            MI_WL[Workload Identity<br/>for Pods]
            RBAC[Azure RBAC<br/>AcrPull Role]
        end
        
        subgraph Network["Network Security"]
            NSG_AKS[NSG - AKS Subnet<br/>Allow: 80, 443<br/>Allow: Pod traffic]
            NSG_PG[NSG - PostgreSQL<br/>Allow: 5432 from AKS only<br/>Deny: Public Internet]
            PG_FW[PostgreSQL Firewall<br/>Public Access: DISABLED]
        end
        
        subgraph Resources["Azure Resources"]
            ACR_Secure[🔒 ACR - Premium<br/>Admin: Disabled<br/>Private Endpoint Only]
            AKS_Secure[🔒 AKS Cluster<br/>Private Cluster Mode<br/>OIDC Enabled]
            PG_Secure[🔒 PostgreSQL<br/>VNet Integration<br/>SSL Required]
        end
        
        subgraph Data["Data Security"]
            Secrets[Kubernetes Secrets<br/>Base64 Encoded<br/>DB Credentials]
            TLS[TLS/SSL Encryption<br/>In-Transit]
            Encryption[Azure Disk Encryption<br/>At-Rest]
        end
    end
    
    GHA -->|Authenticate| OIDC
    OIDC -->|Federated Token| AAD
    AAD -->|Grant Access| AKS_Secure
    AAD -->|Grant Access| ACR_Secure
    
    MI_AKS -->|Pull Images| ACR_Secure
    RBAC -->|Authorize| MI_AKS
    
    AKS_Secure -->|Pods Use| MI_WL
    MI_WL -->|Access Azure Resources| AAD
    
    NSG_AKS -->|Protect| AKS_Secure
    NSG_PG -->|Protect| PG_Secure
    PG_FW -->|Block Public| PG_Secure
    
    AKS_Secure -->|Load Secrets| Secrets
    AKS_Secure -->|Connect with SSL| PG_Secure
    PG_Secure -->|Encrypted Storage| Encryption
    
    style GHA fill:#e1f5ff
    style OIDC fill:#fff3cd
    style AAD fill:#ffeb99
    style MI_AKS fill:#d4edda
    style MI_WL fill:#d4edda
    style RBAC fill:#d4edda
    style NSG_AKS fill:#ffe6e6
    style NSG_PG fill:#ffe6e6
    style PG_FW fill:#ffe6e6
    style ACR_Secure fill:#e7e7e7
    style AKS_Secure fill:#cce5ff
    style PG_Secure fill:#f8d7da
    style Secrets fill:#ffe6e6
    style TLS fill:#d4edda
    style Encryption fill:#d4edda
```

### CI/CD Pipeline Flow

```mermaid
flowchart TD
    Start([Developer Pushes Code]) --> GHA_Trigger[GitHub Actions Triggered]
    
    GHA_Trigger --> Auth[🔐 OIDC Authentication<br/>Federated Credentials]
    Auth --> Azure_Login[Azure Login via Workload Identity]
    
    Azure_Login --> Build_Stage[📦 Build Stage]
    
    Build_Stage --> Build_FE[Build Frontend<br/>npm build]
    Build_Stage --> Build_BE[Build Backend Services<br/>Maven clean install]
    
    Build_FE --> Docker_FE[Docker Build Frontend<br/>Multi-stage build]
    Build_BE --> Docker_BE[Docker Build Backend<br/>4 Services]
    
    Docker_FE --> Tag_FE[Tag: frontend-ui:latest<br/>frontend-ui:SHA]
    Docker_BE --> Tag_BE[Tag Services<br/>latest + SHA]
    
    Tag_FE --> Push_ACR[📤 Push to ACR]
    Tag_BE --> Push_ACR
    
    Push_ACR --> Get_Creds[Get AKS Credentials<br/>az aks get-credentials]
    
    Get_Creds --> Replace_Vars[Replace Variables in K8s YAML<br/>ACR URL, Image Tags, DB Host]
    
    Replace_Vars --> Deploy_Config[Deploy ConfigMaps & Secrets]
    Deploy_Config --> Deploy_Services[Deploy Services]
    Deploy_Services --> Deploy_Apps[Deploy Applications<br/>kubectl apply]
    
    Deploy_Apps --> Wait[⏳ Wait for Rollout<br/>kubectl rollout status]
    
    Wait --> Health_Check[🏥 Health Checks<br/>6 Services]
    
    Health_Check -->|All Pass| Success([✅ Deployment Complete])
    Health_Check -->|Any Fail| Rollback[⚠️ Deployment Failed<br/>Manual Intervention]
    
    Success --> Notify_Success[💬 Notify Team<br/>Slack/Email]
    Rollback --> Notify_Fail[🚨 Alert Team<br/>Investigation Needed]
    
    style Start fill:#e1f5ff
    style Auth fill:#fff3cd
    style Build_Stage fill:#d4edda
    style Push_ACR fill:#cce5ff
    style Deploy_Apps fill:#ffeb99
    style Health_Check fill:#ffe6e6
    style Success fill:#d4edda
    style Rollback fill:#f8d7da
```

---

## Application Layer

### Frontend - React 19.x

- **Framework:** React with functional components and hooks
- **State Management:** React Context API
- **Routing:** React Router v7
- **HTTP Client:** Axios with interceptors
- **UI Components:** Custom components with responsive design
- **Build Tool:** Create React App / Vite
- **Web Server:** Nginx (production)
- **Container:** Docker multi-stage build (node:18 → nginx:alpine)

**Key Files:**
- `frontend/account-opening-ui/src/App.js` - Main application component
- `frontend/account-opening-ui/nginx.conf` - Nginx configuration with API proxy
- `frontend/account-opening-ui/Dockerfile` - Multi-stage Docker build

### Backend - Spring Boot 3.x

- **Framework:** Spring Boot 3.x with Java 17
- **Architecture Pattern:** Microservices (one database per service)
- **API Style:** RESTful JSON APIs
- **Database Access:** Spring Data JPA with Hibernate
- **Schema Management:** Liquibase for database migrations
- **Health Checks:** Spring Boot Actuator (/actuator/health)
- **Configuration:** External configuration via ConfigMaps and Secrets
- **Container Base:** eclipse-temurin:17-jre-alpine

**Dependencies:**
```xml
• spring-boot-starter-web       - REST API
• spring-boot-starter-data-jpa  - Database access
• spring-boot-starter-actuator  - Health checks
• liquibase-core                - Schema migrations
• postgresql                    - PostgreSQL driver
```

---

## Infrastructure Layer

### Azure Kubernetes Service (AKS)

**Cluster Configuration:**
- **Kubernetes Version:** 1.28+
- **Network Plugin:** Azure CNI
- **Network Policy:** Azure Network Policy
- **Load Balancer:** Standard SKU (Layer 4)
- **Node Pool:** System node pool (Standard_B2s, 1 node)
- **Scaling:** Manual scale (can be changed to auto-scale)
- **Availability:** Single zone (dev), multi-zone (prod recommended)

**Why AKS?**
- ✅ Managed Kubernetes (control plane managed by Azure)
- ✅ Built-in monitoring (Container Insights)
- ✅ Azure Active Directory integration
- ✅ Automatic security updates
- ✅ Horizontal Pod Autoscaler support
- ✅ Integration with ACR, Key Vault, Private Link

**Resource Definitions:**
- **Deployments:** Define desired pod state, rolling updates
- **Services:** ClusterIP for backend, LoadBalancer for frontend
- **ConfigMaps:** Non-sensitive configuration (DB names, URLs)
- **Secrets:** Sensitive data (DB passwords) - base64 encoded
- **Ingress:** Not used (LoadBalancer direct access)

### Azure Container Registry (ACR)

- **SKU:** Basic (sufficient for dev, upgrade to Standard for prod)
- **Purpose:** Store Docker images for all microservices
- **Integration:** AKS pulls images via managed identity (no secrets)
- **Image Tagging:** Git SHA + latest tag
- **Security:** Private registry, role-based access

**Images Stored:**
```
acr<uniqueid>.azurecr.io/customer-service:latest
acr<uniqueid>.azurecr.io/document-service:latest
acr<uniqueid>.azurecr.io/account-service:latest
acr<uniqueid>.azurecr.io/notification-service:latest
acr<uniqueid>.azurecr.io/frontend-ui:latest
```

---

## Network Architecture

### Virtual Network (VNet) Design

```
VNet: 10.0.0.0/16 (65,536 IP addresses)

├── AKS Subnet: 10.0.1.0/24 (256 IPs)
│   └── Purpose: AKS nodes and pods
│       • Node IPs: 10.0.1.4, 10.0.1.5, etc.
│       • Pod IPs: Dynamically assigned from range
│       • Network Policy: Enabled for pod-to-pod security
│
├── ACR Subnet: 10.0.2.0/24 (256 IPs)
│   └── Purpose: Azure Container Registry private endpoint
│       • Private IP: 10.0.2.x
│       • No public access to ACR
│
└── PostgreSQL Subnet: 10.0.3.0/24 (256 IPs)
    └── Purpose: PostgreSQL Flexible Server
        • Delegated to: Microsoft.DBforPostgreSQL/flexibleServers
        • Private IP: 10.0.3.x
        • NO PUBLIC ACCESS ✅
```

### Network Security Groups (NSG)

**AKS Subnet NSG:**
- Allow: Inbound 443 (HTTPS) from Internet to LoadBalancer
- Allow: Inbound 80 (HTTP) from Internet to LoadBalancer
- Allow: Pod-to-Pod communication within AKS
- Allow: AKS → PostgreSQL on port 5432
- Deny: All other inbound traffic

**PostgreSQL Subnet NSG:**
- Allow: Inbound 5432 from AKS Subnet only
- Deny: All other inbound traffic (including Internet)

### Private DNS Integration

**Private DNS Zone:** `privatelink.postgres.database.azure.com`

- **Purpose:** Resolve PostgreSQL FQDN to private IP
- **Linked to:** VNet (automatic registration disabled)
- **How it works:**
  1. App tries to connect to `psql-account-opening-dev-eus2.postgres.database.azure.com`
  2. Private DNS resolves to `10.0.3.x` (private IP)
  3. Traffic stays within VNet (never goes to Internet)
  4. Connection uses PostgreSQL native SSL/TLS

---

## Database Layer

### PostgreSQL Flexible Server

**Configuration:**
- **Version:** PostgreSQL 15
- **SKU:** Burstable B1ms (1 vCore, 2 GB RAM)
- **Storage:** 32 GB with auto-grow
- **Backup:** 7-day retention, geo-redundant
- **High Availability:** Zone-redundant (optional, not enabled in dev)
- **SSL/TLS:** Required (enforced)

**VNet Integration:**
- **Subnet Delegation:** Required for PostgreSQL Flexible Server
- **Private IP:** Static IP from PostgreSQL subnet
- **Public Access:** DISABLED (enforce_ssl = true anyway)
- **Firewall:** No firewall rules needed (private-only)

**Connection String (from AKS pods):**
```
jdbc:postgresql://psql-account-opening-dev-eus2.postgres.database.azure.com:5432/customerdb
User: psqladmin
Password: <from Kubernetes Secret>
SSL Mode: require
```

**Why PostgreSQL Flexible Server?**
- ✅ Better price/performance than Single Server
- ✅ Zone-redundant HA available
- ✅ Maintenance windows (you control when updates happen)
- ✅ Stop/Start capability (saves money)
- ✅ Read replicas support
- ✅ VNet integration built-in

### Liquibase Database Migrations

Each service manages its own database schema:

**Migration Files Location:**
```
customer-service/src/main/resources/db/changelog/
├── db.changelog-master.xml
└── changes/
    ├── 001-create-customer-table.sql
    ├── 002-add-customer-indexes.sql
    └── 003-add-audit-columns.sql
```

**How it works:**
1. Service starts up
2. Liquibase checks `databasechangelog` table
3. Runs any new migrations not yet applied
4. Marks migrations as complete
5. Service starts accepting traffic

---

## Load Balancer

### Azure Load Balancer (Standard SKU)

**How Load Balancer Works:**

```
Internet Traffic
      │
      ▼
┌─────────────────────────────────────┐
│  Azure Load Balancer (Standard)     │
│  Public IP: 68.220.25.83 (example)  │
│  Type: Layer 4 (TCP/UDP)            │
└─────────────────┬───────────────────┘
                  │
                  │ Health Probe: /health every 5s
                  ▼
┌─────────────────────────────────────┐
│  Kubernetes Service: frontend-ui    │
│  Type: LoadBalancer                 │
│  Port: 80                           │
└─────────────────┬───────────────────┘
                  │
          ┌───────┴────────┐
          ▼                ▼
┌──────────────┐   ┌──────────────┐
│ Frontend Pod │   │ Frontend Pod │
│ IP: 10.0.1.x │   │ IP: 10.0.1.y │
└──────────────┘   └──────────────┘
```

**Key Characteristics:**
- **Type:** Standard SKU (regional, zone-redundant)
- **Protocol:** TCP (HTTP/HTTPS)
- **Ports:** 80 (HTTP)
- **Health Probe:** HTTP GET /health every 5 seconds
- **Distribution:** 5-tuple hash (source IP, source port, dest IP, dest port, protocol)
- **Session Persistence:** None (stateless apps)
- **Cost:** ~$20/month (regardless of traffic)

**Traffic Flow:**
1. **User Request:** Browser → `http://68.220.25.83`
2. **Load Balancer:** Receives request, health check passes → forward to pod
3. **Pod Selection:** Kubernetes service selects healthy pod (round-robin)
4. **Response:** Pod → Load Balancer → User

**Why Standard Load Balancer?**
- ✅ Zone redundancy (high availability)
- ✅ More health probe options
- ✅ Support for more backend instances
- ✅ Outbound rules (NAT)
- ✅ Better metrics and diagnostics

**IP Assignment:**
- **Static vs Dynamic:** Default is dynamic, but IP rarely changes
- **How to get IP:** `kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
- **DNS:** Can create Azure DNS A record pointing to Load Balancer IP

---

## Component Services

### Service Details

| Service | Port | Health Check | Database |
|---------|------|--------------|----------|
| Customer Service | 8081 | /actuator/health | customerdb |
| Document Service | 8082 | /actuator/health | documentdb |
| Account Service | 8083 | /actuator/health | accountdb |
| Notification Service | 8084 | /actuator/health | notificationdb |
| Frontend UI | 80 | /health | N/A |
| PostgreSQL | 5432 | TCP check | Private only |

---

**See Also:**
- [Deployment Guide](DEPLOYMENT_GUIDE.md)
- [Testing Guide](TESTING_GUIDE.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
