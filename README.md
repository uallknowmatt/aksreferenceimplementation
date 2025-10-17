# Bank Account Opening System

This is a microservices-based system for bank account opening, built with Spring Boot and deployed on Azure Kubernetes Service (AKS).

## Architecture

The system consists of the following microservices:

- **Customer Service**: Handles customer information and KYC processes
- **Document Service**: Manages document upload and verification
- **Account Service**: Handles account creation and management
- **Notification Service**: Manages all notifications and communications

## Technology Stack

- Java 17
- Spring Boot 3.x
- Maven
- Azure Kubernetes Service (AKS)
- Terraform for infrastructure

## Project Structure

```
account-opening-system/
├── customer-service/     # Customer management and KYC
├── document-service/     # Document handling
├── account-service/      # Account management
├── notification-service/ # Notifications
└── infrastructure/      # Terraform IaC for AKS
```

## Prerequisites

- Java 17 or higher
- Maven 3.8+
- Docker
- Azure CLI
- Terraform
- Kubernetes CLI (kubectl)

## Building the Project

To build all services:

```bash
mvn clean install
```

## Running Locally

Each service can be run locally using:

```bash
cd <service-name>
mvn spring-boot:run
```

## Deployment

The services are deployed to AKS using Terraform and Kubernetes manifests. See the infrastructure directory for details.

## Azure Architecture Diagram

```mermaid
flowchart TD
    %% Resource Group
    RG["Resource Group"]
    %% Virtual Network
    VNet["Virtual Network"]
    RG --> VNet
    %% AKS Cluster
    AKS["AKS Cluster"]
    VNet --> AKS
    %% Node Pool
    NodePool["Node Pool (VMSS)"]
    AKS --> NodePool
    %% Pods and Containers
    Pod1["Pod: customer-service"]
    Pod2["Pod: document-service"]
    Pod3["Pod: account-service"]
    Pod4["Pod: notification-service"]
    NodePool --> Pod1
    NodePool --> Pod2
    NodePool --> Pod3
    NodePool --> Pod4
    C1["Container: customer-service"]
    C2["Container: document-service"]
    C3["Container: account-service"]
    C4["Container: notification-service"]
    Pod1 --> C1
    Pod2 --> C2
    Pod3 --> C3
    Pod4 --> C4
    %% Ingress Controller
    Ingress["Ingress Controller / API Gateway"]
    AKS --> Ingress
    Internet((Internet)) --> Ingress
    Ingress --> C1
    Ingress --> C2
    Ingress --> C3
    Ingress --> C4
    %% Azure Container Registry
    ACR["Azure Container Registry"]
    RG --> ACR
    AKS -.-> ACR
    %% Azure PostgreSQL Databases
    DB1["Azure PostgreSQL: customerdb"]
    DB2["Azure PostgreSQL: documentdb"]
    DB3["Azure PostgreSQL: accountdb"]
    DB4["Azure PostgreSQL: notificationdb"]
    RG --> DB1
    RG --> DB2
    RG --> DB3
    RG --> DB4
    C1 -- "JDBC" --> DB1
    C2 -- "JDBC" --> DB2
    C3 -- "JDBC" --> DB3
    C4 -- "JDBC" --> DB4
```

## AKS Troubleshooting & Solutions

See [aksissues.md](./aksissues.md) for common AKS issues and solutions.
