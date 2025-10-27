# Infrastructure as Code: Complete Line-by-Line Explanation

This document provides a comprehensive, line-by-line explanation of all Terraform files in the `infrastructure/` directory and all Kubernetes YAML files in the `k8s/` directory. It is intended to help engineers, reviewers, and auditors understand the purpose and function of each resource, variable, and configuration.

---

# Part 1: Terraform Infrastructure Files

## main.tf - Line-by-Line

```terraform
terraform {
```
- **Line 1**: Start of the terraform configuration block, which defines backend and provider requirements.

```terraform
  backend "azurerm" {
```
- **Line 2**: Configure remote state backend using Azure Storage.

```terraform
    resource_group_name  = "terraform-state-rg"
```
- **Line 3**: Name of the resource group that contains the state storage account.

```terraform
    storage_account_name = "tfstateaccountopening"
```
- **Line 4**: Name of the Azure Storage Account where Terraform state files are stored.

```terraform
    container_name       = "tfstate"
```
- **Line 5**: Name of the blob container within the storage account that holds state files.

```terraform
    # key is passed via -backend-config in terraform init
```
- **Line 6**: Comment explaining that the state file name (key) is specified during `terraform init` via command-line argument.

```terraform
    # Authentication via ARM_* environment variables (same as provider)
```
- **Line 7**: Comment explaining authentication method (uses ARM_CLIENT_ID, ARM_TENANT_ID, etc.).

```terraform
  }
```
- **Line 8**: End of backend block.

```terraform
  required_providers {
```
- **Line 9**: Start of required providers block, specifying which provider plugins Terraform must use.

```terraform
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
```
- **Lines 10-13**: Require the Azure Resource Manager provider from HashiCorp, version 4.x (allows minor/patch updates).

```terraform
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
```
- **Lines 14-17**: Require the Azure Active Directory provider, version 3.x.

```terraform
  }
```
- **Line 18**: End of required_providers block.

```terraform
  required_version = ">= 1.6.0"
```
- **Line 19**: Enforce minimum Terraform CLI version of 1.6.0.

```terraform
}
```
- **Line 20**: End of terraform block.

```terraform
provider "azurerm" {
  features {}
}
```
- **Lines 21-23**: Configure the AzureRM provider with default feature settings.

```terraform
provider "azuread" {}
```
- **Line 24**: Configure the Azure AD provider with default settings.

```terraform
data "azurerm_client_config" "current" {}
```
- **Line 25**: Fetch information about the current Azure client (tenant ID, subscription ID, client ID) for use in other resources.

---

## resource_group.tf - Line-by-Line

```terraform
resource "azurerm_resource_group" "rg" {
```
- **Line 1**: Define an Azure Resource Group named "rg" (Terraform resource name, not Azure name).

```terraform
  name     = local.resource_group_name
```
- **Line 2**: Set the Azure name using a computed local variable from `locals.tf`.

```terraform
  location = var.location
```
- **Line 3**: Set the Azure region using a variable (allows environment-specific regions).

```terraform
  tags     = local.common_tags
```
- **Line 4**: Apply common tags (environment, project, owner, managed_by) from `locals.tf`.

```terraform
  lifecycle {
    prevent_destroy = false
  }
```
- **Lines 5-7**: Allow this resource to be destroyed (set to `true` in production for safety).

```terraform
}
```
- **Line 8**: End of resource block.

---

## locals.tf - Line-by-Line (Key Sections)

```terraform
locals {
```
- **Line 1**: Start of locals block for computed values.

```terraform
  common_tags = {
    environment = var.environment
    project     = var.project
    owner       = var.owner
    managed_by  = "terraform"
    repository  = "aksreferenceimplementation"
  }
```
- **Lines 2-8**: Define common tags applied to all resources for cost tracking and organization.

```terraform
  location_short = {
    "eastus"      = "eus"
    "eastus2"     = "eus2"
    ...
  }
```
- **Lines 9-16**: Map full Azure region names to short codes for resource naming.

```terraform
  location_code = lookup(local.location_short, var.location, "eus")
```
- **Line 17**: Look up the short code for the current location, default to "eus" if not found.

```terraform
  resource_group_name = "rg-${var.project}-${var.environment}-${local.location_code}"
```
- **Line 18**: Construct resource group name following Azure naming conventions: `rg-account-opening-dev-eus2`.

```terraform
  vnet_name = "vnet-${var.project}-${var.environment}-${local.location_code}"
```
- **Line 19**: Construct VNet name: `vnet-account-opening-dev-eus2`.

```terraform
  aks_name = "aks-${var.project}-${var.environment}-${local.location_code}"
```
- **Line 20**: Construct AKS cluster name: `aks-account-opening-dev-eus2`.

```terraform
  acr_name = "acr${replace(var.project, "-", "")}${var.environment}${local.location_code}"
```
- **Line 21**: Construct ACR name (no hyphens allowed): `acraccountopeningdeveus2`.

(Continue with other resource names following the same pattern...)

---

## network.tf - Line-by-Line

```terraform
resource "azurerm_virtual_network" "vnet" {
```
- **Line 1**: Define the main Virtual Network resource.

```terraform
  name                = local.vnet_name
```
- **Line 2**: Use the computed VNet name from locals.

```terraform
  address_space       = var.vnet_address_space
```
- **Line 3**: Set the IP address range for the VNet (e.g., `["10.0.0.0/16"]`).

```terraform
  location            = azurerm_resource_group.rg.location
```
- **Line 4**: Use the same location as the resource group (ensures consistency).

```terraform
  resource_group_name = azurerm_resource_group.rg.name
```
- **Line 5**: Place the VNet in the resource group created earlier.

```terraform
  tags                = local.common_tags
```
- **Line 6**: Apply common tags.

```terraform
  depends_on = [azurerm_resource_group.rg]
```
- **Line 7**: Explicit dependency to ensure resource group is created first.

```terraform
}
```
- **Line 8**: End of VNet resource.

```terraform
resource "azurerm_subnet" "aks_subnet" {
```
- **Line 9**: Define the subnet for AKS nodes.

```terraform
  name                 = local.aks_subnet_name
```
- **Line 10**: Use computed subnet name from locals.

```terraform
  resource_group_name  = azurerm_resource_group.rg.name
```
- **Line 11**: Reference the resource group.

```terraform
  virtual_network_name = azurerm_virtual_network.vnet.name
```
- **Line 12**: Reference the VNet this subnet belongs to.

```terraform
  address_prefixes     = var.aks_subnet_address_prefix
```
- **Line 13**: Set the IP range for this subnet (e.g., `["10.0.1.0/24"]`).

```terraform
  depends_on = [azurerm_virtual_network.vnet]
```
- **Line 14**: Ensure VNet exists before creating subnet.

(Continue with ACR subnet and PostgreSQL subnet in the same pattern...)

```terraform
resource "azurerm_subnet" "postgres_subnet" {
  ...
  delegation {
    name = "postgres-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
```
- **Delegation block**: Delegates the subnet to PostgreSQL Flexible Server, allowing Azure to manage network integration for the database.

```terraform
  private_endpoint_network_policies = "Disabled"
```
- **Line**: Disable private endpoint policies (required for PostgreSQL VNet integration).

---

## aks.tf - Line-by-Line

```terraform
resource "azurerm_kubernetes_cluster" "aks" {
```
- **Line 1**: Define the AKS cluster resource.

```terraform
  name                              = local.aks_name
```
- **Line 2**: Use computed cluster name from locals.

```terraform
  location                          = azurerm_resource_group.rg.location
```
- **Line 3**: Use the same location as the resource group.

```terraform
  resource_group_name               = azurerm_resource_group.rg.name
```
- **Line 4**: Place AKS in the resource group.

```terraform
  dns_prefix                        = "${var.environment}-${var.project}"
```
- **Line 5**: Set the DNS prefix for the AKS API server (e.g., `dev-account-opening`).

```terraform
  private_cluster_enabled           = var.private_cluster_enabled
```
- **Line 6**: Enable/disable private cluster mode (API server only accessible from VNet).

```terraform
  role_based_access_control_enabled = true
```
- **Line 7**: Enable Kubernetes RBAC for access control.

```terraform
  tags                              = local.common_tags
```
- **Line 8**: Apply common tags.

```terraform
  default_node_pool {
```
- **Line 9**: Start of default (system) node pool configuration.

```terraform
    name                 = "system"
```
- **Line 10**: Name the default node pool "system".

```terraform
    node_count           = var.enable_auto_scaling ? null : var.node_count
```
- **Line 11**: If autoscaling is enabled, set node_count to null (required); otherwise use fixed count.

```terraform
    vm_size              = var.vm_size
```
- **Line 12**: Set VM size for nodes (e.g., `Standard_DS2_v2`).

```terraform
    auto_scaling_enabled = var.enable_auto_scaling
```
- **Line 13**: Enable/disable autoscaling based on variable.

```terraform
    min_count            = var.enable_auto_scaling ? var.min_count : null
```
- **Line 14**: Set minimum node count for autoscaling (or null if disabled).

```terraform
    max_count            = var.enable_auto_scaling ? var.max_count : null
```
- **Line 15**: Set maximum node count for autoscaling (or null if disabled).

```terraform
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
```
- **Line 16**: Place AKS nodes in the AKS subnet.

```terraform
    node_labels = merge(
      local.common_tags,
      { "nodepool" = "system" }
    )
```
- **Lines 17-20**: Apply node labels (common tags + nodepool identifier).

```terraform
  }
```
- **Line 21**: End of default_node_pool block.

```terraform
  identity {
    type = "SystemAssigned"
  }
```
- **Lines 22-24**: Use a system-assigned managed identity for the AKS cluster.

```terraform
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
```
- **Lines 25-26**: Enable OIDC issuer and workload identity for secure, passwordless pod authentication to Azure resources.

```terraform
  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    service_cidr      = var.aks_service_cidr
    dns_service_ip    = var.aks_dns_service_ip
  }
```
- **Lines 27-32**: Configure networking: use Azure CNI, Calico network policy, and dedicated service CIDR for Kubernetes services.

```terraform
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs.id
  }
```
- **Lines 33-35**: Connect AKS to Log Analytics for monitoring and diagnostics.

```terraform
  depends_on = [
    azurerm_subnet.aks_subnet,
    azurerm_log_analytics_workspace.aks_logs
  ]
```
- **Lines 36-39**: Ensure subnet and log analytics are created before AKS.

---

## postgres.tf - Line-by-Line

```terraform
resource "azurerm_postgresql_flexible_server" "db" {
```
- **Line 1**: Define a PostgreSQL Flexible Server resource.

```terraform
  name                   = local.postgres_name
```
- **Line 2**: Use computed name from locals.

```terraform
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
```
- **Lines 3-4**: Place in resource group and use the same location.

```terraform
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
```
- **Lines 5-6**: Set admin credentials from variables (sensitive data).

```terraform
  sku_name               = var.db_sku_name
```
- **Line 7**: Set the pricing tier (e.g., `B_Gen5_1` for burstable).

```terraform
  storage_mb             = var.db_storage_mb
```
- **Line 8**: Set storage size in megabytes.

```terraform
  version                = "15"
```
- **Line 9**: Use PostgreSQL version 15.

```terraform
  zone                   = "2"
```
- **Line 10**: Explicitly set availability zone (prevents conflicts when updating existing servers).

```terraform
  tags                   = local.common_tags
```
- **Line 11**: Apply common tags.

```terraform
  delegated_subnet_id           = azurerm_subnet.postgres_subnet.id
```
- **Line 12**: Integrate the database with the dedicated PostgreSQL subnet (VNet integration).

```terraform
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
```
- **Line 13**: Use the private DNS zone for name resolution.

```terraform
  public_network_access_enabled = false
```
- **Line 14**: Disable public access (database is only accessible from within the VNet).

```terraform
  depends_on = [
    azurerm_resource_group.rg,
    azurerm_subnet.postgres_subnet,
    azurerm_private_dns_zone_virtual_network_link.postgres_vnet_link
  ]
```
- **Lines 15-19**: Ensure dependencies are created first (RG, subnet, DNS zone link).

```terraform
  lifecycle {
    ignore_changes = [zone, high_availability]
  }
```
- **Lines 20-22**: Ignore changes to zone and HA settings (prevents errors when updating existing servers).

```terraform
}
```
- **Line 23**: End of PostgreSQL server resource.

```terraform
resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each = toset(local.database_names)
```
- **Lines 24-25**: Create one database per microservice using a for_each loop over the list of database names.

```terraform
  name      = each.value
```
- **Line 26**: Set the database name to the current item in the loop.

```terraform
  server_id = azurerm_postgresql_flexible_server.db.id
```
- **Line 27**: Reference the PostgreSQL server created above.

```terraform
  charset   = "UTF8"
  collation = "en_US.utf8"
```
- **Lines 28-29**: Set character set and collation for the database.

```terraform
  ```terraform
  depends_on = [azurerm_postgresql_flexible_server.db]
```
- **Line 30**: Ensure the server is created before the databases.

---

# Part 2: Kubernetes YAML Files - Line-by-Line Explanations

## How Kubernetes Deployments Work

When you apply Kubernetes YAML files, the following happens:

1. **ConfigMaps and Secrets** are created first, storing configuration data and sensitive information.
2. **Services** are created to provide stable network endpoints.
3. **Deployments** are created, which:
   - Create **ReplicaSets** that manage the desired number of pod replicas.
   - **Pods** are created from the pod template in the deployment.
   - Pods pull the container image from ACR and inject environment variables from ConfigMaps/Secrets.
   - Health probes (liveness/readiness) ensure pods are healthy before receiving traffic.
4. **Services** route traffic to healthy pods based on label selectors.

---

## Example: frontend-ui-deployment.yaml - Line-by-Line

```yaml
apiVersion: apps/v1
```
- **Line 1**: Use the `apps/v1` API version for Deployment resources.

```yaml
kind: Deployment
```
- **Line 2**: Declare this as a Deployment resource (manages pods and their lifecycle).

```yaml
metadata:
```
- **Line 3**: Start of metadata section (name, labels, annotations).

```yaml
  name: frontend-ui
```
- **Line 4**: Name the deployment "frontend-ui" (used to reference it in kubectl commands).

```yaml
spec:
```
- **Line 5**: Start of the specification section (desired state of the deployment).

```yaml
  replicas: 1
```
- **Line 6**: Run 1 replica (pod) of this deployment. Increase for high availability.

```yaml
  selector:
```
- **Line 7**: Start of label selector (tells deployment which pods it manages).

```yaml
    matchLabels:
```
- **Line 8**: Match pods with these labels.

```yaml
      app: frontend-ui
```
- **Line 9**: Select pods with label `app: frontend-ui`.

```yaml
  template:
```
- **Line 10**: Start of pod template (blueprint for creating pods).

```yaml
    metadata:
```
- **Line 11**: Metadata for the pod.

```yaml
      labels:
```
- **Line 12**: Labels to apply to each pod.

```yaml
        app: frontend-ui
```
- **Line 13**: Apply label `app: frontend-ui` to each pod (must match selector above).

```yaml
    spec:
```
- **Line 14**: Start of pod specification (containers, volumes, etc.).

```yaml
      containers:
```
- **Line 15**: List of containers in the pod.

```yaml
      - name: frontend-ui
```
- **Line 16**: Name the container "frontend-ui".

```yaml
        image: <ACR_LOGIN_SERVER>/frontend-ui:<TAG>
```
- **Line 17**: Container image to run. Placeholder is replaced during deployment by the workflow.

```yaml
        ports:
```
- **Line 18**: List of ports exposed by the container.

```yaml
        - containerPort: 80
```
- **Line 19**: Expose port 80 (Nginx listens on this port inside the container).

```yaml
        envFrom:
```
- **Line 20**: Inject environment variables from external sources.

```yaml
        - configMapRef:
```
- **Line 21**: Reference a ConfigMap.

```yaml
            name: frontend-ui-config
```
- **Line 22**: Use the ConfigMap named "frontend-ui-config" (injects all its key-value pairs as env vars).

```yaml
        resources:
```
- **Line 23**: Resource requests and limits for the container.

```yaml
          requests:
```
- **Line 24**: Minimum resources guaranteed to the container.

```yaml
            memory: "128Mi"
```
- **Line 25**: Request 128 MiB of memory.

```yaml
            cpu: "100m"
```
- **Line 26**: Request 100 millicores (0.1 CPU).

```yaml
          limits:
```
- **Line 27**: Maximum resources the container can use.

```yaml
            memory: "256Mi"
```
- **Line 28**: Limit to 256 MiB of memory (container is killed if it exceeds this).

```yaml
            cpu: "200m"
```
- **Line 29**: Limit to 200 millicores (0.2 CPU).

```yaml
        livenessProbe:
```
- **Line 30**: Health check to determine if the container is alive (restart if it fails).

```yaml
          httpGet:
```
- **Line 31**: Use HTTP GET for the liveness check.

```yaml
            path: /health
```
- **Line 32**: Check the `/health` endpoint.

```yaml
            port: 80
```
- **Line 33**: Check on port 80.

```yaml
          initialDelaySeconds: 10
```
- **Line 34**: Wait 10 seconds after container starts before first check.

```yaml
          periodSeconds: 30
```
- **Line 35**: Check every 30 seconds.

```yaml
        readinessProbe:
```
- **Line 36**: Health check to determine if the container is ready to receive traffic.

```yaml
          httpGet:
```
- **Line 37**: Use HTTP GET for the readiness check.

```yaml
            path: /health
```
- **Line 38**: Check the `/health` endpoint.

```yaml
            port: 80
```
- **Line 39**: Check on port 80.

```yaml
          initialDelaySeconds: 5
```
- **Line 40**: Wait 5 seconds after container starts before first check.

```yaml
          periodSeconds: 10
```
- **Line 41**: Check every 10 seconds.

```yaml
        terminationGracePeriodSeconds: 30
```
- **Line 42**: Wait 30 seconds for the pod to shut down gracefully before force-killing it.

```yaml
    strategy:
```
- **Line 43**: Deployment update strategy.

```yaml
      type: RollingUpdate
```
- **Line 44**: Use rolling update (gradually replace old pods with new ones).

```yaml
      rollingUpdate:
```
- **Line 45**: Rolling update configuration.

```yaml
        maxSurge: 1
```
- **Line 46**: Allow 1 extra pod above desired count during update (for zero-downtime).

```yaml
        maxUnavailable: 0
```
- **Line 47**: Do not allow any pods to be unavailable during update (ensures high availability).

```yaml
    progressDeadlineSeconds: 600
```
- **Line 48**: Fail the deployment if it takes longer than 600 seconds (10 minutes).

---

## Example: frontend-ui-service.yaml - Line-by-Line

```yaml
apiVersion: v1
```
- **Line 1**: Use the `v1` API version for Service resources.

```yaml
kind: Service
```
- **Line 2**: Declare this as a Service resource (provides network access to pods).

```yaml
metadata:
```
- **Line 3**: Start of metadata section.

```yaml
  name: frontend-ui
```
- **Line 4**: Name the service "frontend-ui" (used as DNS name within the cluster).

```yaml
  annotations:
```
- **Line 5**: Start of annotations (provider-specific metadata).

```yaml
    service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /health
```
- **Line 6**: Tell Azure Load Balancer to use `/health` for health checks.

```yaml
spec:
```
- **Line 7**: Start of service specification.

```yaml
  type: LoadBalancer
```
- **Line 8**: Create an external Azure Load Balancer (public IP for external access).

```yaml
  ports:
```
- **Line 9**: List of ports exposed by the service.

```yaml
  - port: 80
```
- **Line 10**: Expose port 80 on the load balancer.

```yaml
    targetPort: 80
```
- **Line 11**: Forward traffic to port 80 on the pods.

```yaml
    protocol: TCP
```
- **Line 12**: Use TCP protocol.

```yaml
    name: http
```
- **Line 13**: Name the port "http".

```yaml
  selector:
```
- **Line 14**: Select pods to route traffic to.

```yaml
    app: frontend-ui
```
- **Line 15**: Route traffic to pods with label `app: frontend-ui`.

---

## Example: frontend-ui-configmap.yaml - Line-by-Line

```yaml
apiVersion: v1
```
- **Line 1**: Use the `v1` API version for ConfigMap resources.

```yaml
kind: ConfigMap
```
- **Line 2**: Declare this as a ConfigMap resource (stores non-sensitive configuration).

```yaml
metadata:
```
- **Line 3**: Start of metadata section.

```yaml
  name: frontend-ui-config
```
- **Line 4**: Name the ConfigMap "frontend-ui-config" (referenced by the deployment).

```yaml
  labels:
```
- **Line 5**: Labels for the ConfigMap.

```yaml
    app: frontend-ui
```
- **Line 6**: Label to associate with the frontend-ui app.

```yaml
  namespace: default
```
- **Line 7**: Place in the "default" Kubernetes namespace.

```yaml
data:
```
- **Line 8**: Start of key-value data section.

```yaml
  REACT_APP_CUSTOMER_SERVICE_URL: "http://customer-service"
```
- **Line 9**: Set environment variable for Customer Service URL (uses Kubernetes service name).

```yaml
  REACT_APP_DOCUMENT_SERVICE_URL: "http://document-service"
```
- **Line 10**: Set environment variable for Document Service URL.

```yaml
  REACT_APP_ACCOUNT_SERVICE_URL: "http://account-service"
```
- **Line 11**: Set environment variable for Account Service URL.

```yaml
  REACT_APP_NOTIFICATION_SERVICE_URL: "http://notification-service"
```
- **Line 12**: Set environment variable for Notification Service URL.

---

## Example: customer-service-deployment.yaml - Line-by-Line

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: customer-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: customer-service
  template:
    metadata:
      labels:
        app: customer-service
```
- **Lines 1-13**: Standard deployment structure (same as frontend-ui).

```yaml
      annotations:
        azure.workload.identity/client-id: <MANAGED_IDENTITY_CLIENT_ID>
```
- **Lines 14-15**: Annotation to enable Azure Workload Identity (passwordless auth to Azure resources).

```yaml
    spec:
      containers:
      - name: customer-service
        image: <ACR_LOGIN_SERVER>/customer-service:<TAG>
        ports:
        - containerPort: 8081
```
- **Lines 16-21**: Container spec (image from ACR, expose port 8081).

```yaml
        env:
```
- **Line 22**: Start of environment variables section.

```yaml
        - name: SPRING_PROFILES_ACTIVE
          value: "dev"
```
- **Lines 23-24**: Set Spring profile to "dev" (activates dev-specific configuration).

```yaml
        - name: POSTGRES_HOST
          valueFrom:
            configMapKeyRef:
              name: customer-service-config
              key: postgres-host
```
- **Lines 25-29**: Inject POSTGRES_HOST from the ConfigMap "customer-service-config".

```yaml
        - name: POSTGRES_USERNAME
          valueFrom:
            secretKeyRef:
              name: customer-service-secret
              key: postgres-username
```
- **Lines 30-34**: Inject POSTGRES_USERNAME from the Secret "customer-service-secret".

```yaml
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: customer-service-secret
              key: postgres-password
```
- **Lines 35-39**: Inject POSTGRES_PASSWORD from the Secret.

---

## Example: customer-service-service.yaml - Line-by-Line

```yaml
apiVersion: v1
kind: Service
metadata:
  name: customer-service
spec:
  selector:
    app: customer-service
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```
- **Lines 1-12**: Standard ClusterIP service (internal-only, no external IP).
  - **port: 80**: External port (what other services call).
  - **targetPort: 8080**: Internal port (what the container listens on).
  - **type: ClusterIP**: Internal service (not exposed outside the cluster).

---

## Example: customer-service-configmap.yaml - Line-by-Line

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: customer-service-config
  labels:
    app: customer-service
  namespace: default
data:
  postgres-host: "<POSTGRES_HOST>"
```
- **Lines 1-9**: ConfigMap storing the PostgreSQL host (replaced by workflow during deployment).

---

## Example: customer-service-secret.yaml - Line-by-Line

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: customer-service-secret
  labels:
    app: customer-service
  namespace: default
type: Opaque
stringData:
  postgres-username: "customerdbadmin"
  postgres-password: "P@ssw0rd123!"
```
- **Lines 1-11**: Secret storing sensitive database credentials (replaced by workflow during deployment).
  - **type: Opaque**: Generic secret type (arbitrary key-value pairs).
  - **stringData**: Plain-text values (Kubernetes encodes them to base64 automatically).

---

## How a Full Deployment Works (Step-by-Step)

1. **GitHub Actions workflow** runs and:
   - Builds Docker images for all services.
   - Pushes images to ACR.
   - Replaces placeholders in YAML files (e.g., `<ACR_LOGIN_SERVER>`, `<TAG>`, `<POSTGRES_HOST>`).

2. **kubectl apply** is run for each file in order:
   - **ConfigMaps**: Created first (customer-service-config, frontend-ui-config, etc.).
   - **Secrets**: Created next (customer-service-secret, etc.).
   - **Services**: Created to provide stable endpoints (customer-service, frontend-ui, etc.).
   - **Deployments**: Created last (customer-service-deployment, frontend-ui-deployment, etc.).

3. **For each Deployment**:
   - Kubernetes creates a **ReplicaSet** (manages the desired number of pod replicas).
   - The ReplicaSet creates **Pods** based on the template in the deployment.
   - Each pod pulls the container image from ACR.
   - Environment variables are injected from ConfigMaps and Secrets.
   - The container starts and runs the application.

4. **Health checks** (liveness and readiness probes):
   - Kubernetes checks `/health` endpoint on each pod.
   - If readiness probe passes, the pod is added to the service's endpoint list (receives traffic).
   - If liveness probe fails, Kubernetes restarts the pod.

5. **Services route traffic**:
   - ClusterIP services (backend services) provide internal DNS names (e.g., `customer-service`).
   - LoadBalancer service (frontend-ui) provisions an Azure Load Balancer with a public IP.
   - Traffic is distributed to healthy pods based on label selectors.

6. **Rolling updates**:
   - When a new deployment is applied, Kubernetes creates new pods with the new image.
   - Old pods are terminated gracefully after new pods are ready (zero-downtime).
   - `maxSurge` and `maxUnavailable` control the rollout speed and availability.

---
- **Line 30**: Ensure the server is created before the databases.

---

## 7. infrastructure/acr.tf - Line-by-Line

This file creates the Azure Container Registry (ACR) for storing Docker images, with a private endpoint for secure access.

```terraform
resource "azurerm_container_registry" "acr" {
```
- **Line 1**: Create an Azure Container Registry resource.

```terraform
  name                = local.acr_name
```
- **Line 2**: Use the ACR name from `locals.tf` (e.g., `devaccount002acr`).

```terraform
  resource_group_name = azurerm_resource_group.rg.name
```
- **Line 3**: Place in the resource group.

```terraform
  location            = azurerm_resource_group.rg.location
```
- **Line 4**: Deploy to the same location as the resource group.

```terraform
  sku                 = "Premium"
```
- **Line 5**: Use Premium SKU (required for private endpoints and geo-replication).

```terraform
  admin_enabled       = false
```
- **Line 6**: Disable admin account (use managed identities and RBAC instead for better security).

```terraform
  tags                = local.common_tags
```
- **Line 7**: Apply common tags for organization.

```terraform
  depends_on = [azurerm_resource_group.rg]
```
- **Line 8**: Ensure resource group is created first.

```terraform
resource "azurerm_private_endpoint" "acr_pe" {
```
- **Line 10**: Create a private endpoint for the ACR.

```terraform
  name                = local.acr_pe_name
```
- **Line 11**: Use the private endpoint name from `locals.tf`.

```terraform
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
```
- **Lines 12-13**: Deploy to the same location and resource group.

```terraform
  subnet_id           = azurerm_subnet.acr_subnet.id
```
- **Line 14**: Place the private endpoint in the ACR subnet.

```terraform
  tags                = local.common_tags
```
- **Line 15**: Apply common tags.

```terraform
  private_service_connection {
```
- **Line 17**: Configure the connection to the ACR.

```terraform
    name                           = "${local.acr_pe_name}-connection"
```
- **Line 18**: Name the connection.

```terraform
    private_connection_resource_id = azurerm_container_registry.acr.id
```
- **Line 19**: Connect to the ACR resource.

```terraform
    is_manual_connection           = false
```
- **Line 20**: Automatically approve the connection (no manual approval needed).

```terraform
    subresource_names              = ["registry"]
```
- **Line 21**: Connect to the "registry" subresource (ACR's main service).

```terraform
  depends_on = [
    azurerm_container_registry.acr,
    azurerm_subnet.acr_subnet
  ]
```
- **Lines 24-27**: Ensure ACR and subnet are created first.

---

## 8. infrastructure/iam.tf - Line-by-Line

This file configures identity and access management (IAM) for AKS and applications, including RBAC role assignments and workload identity.

```terraform
resource "azurerm_role_assignment" "aks_acr_pull" {
```
- **Line 1**: Create a role assignment for AKS to pull images from ACR.

```terraform
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
```
- **Line 2**: Grant the role to AKS's kubelet managed identity (the identity that runs the pods).

```terraform
  role_definition_name             = "AcrPull"
```
- **Line 3**: Assign the `AcrPull` role (allows pulling images from ACR).

```terraform
  scope                            = azurerm_container_registry.acr.id
```
- **Line 4**: Limit the role to the specific ACR resource.

```terraform
  skip_service_principal_aad_check = true
```
- **Line 5**: Skip AAD check (allows faster role assignment).

```terraform
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_container_registry.acr
  ]
```
- **Lines 7-10**: Ensure AKS and ACR are created first.

```terraform
resource "azurerm_user_assigned_identity" "workload_identity" {
```
- **Line 14**: Create a user-assigned managed identity for application workloads (enables passwordless Azure authentication).

```terraform
  name                = local.workload_identity_name
```
- **Line 15**: Use the identity name from `locals.tf`.

```terraform
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
```
- **Lines 16-17**: Deploy to the same location and resource group.

```terraform
  tags                = local.common_tags
```
- **Line 18**: Apply common tags.

```terraform
  depends_on = [azurerm_resource_group.rg]
```
- **Line 20**: Ensure resource group is created first.

```terraform
resource "azurerm_federated_identity_credential" "workload_identity" {
```
- **Line 26**: Create federated identity credentials to link Kubernetes service accounts to Azure managed identities (enables OIDC-based authentication).

```terraform
  for_each = toset(local.service_names)
```
- **Line 27**: Create one federated credential for each service (customer-service, account-service, etc.).

```terraform
  name                = "${each.key}-federated-identity"
```
- **Line 29**: Name each credential based on the service name.

```terraform
  resource_group_name = azurerm_resource_group.rg.name
```
- **Line 30**: Place in the resource group.

```terraform
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
```
- **Line 31**: Link to the managed identity created above.

```terraform
  audience            = ["api://AzureADTokenExchange"]
```
- **Line 32**: Use the standard OIDC audience for Azure AD token exchange.

```terraform
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
```
- **Line 33**: Use AKS's OIDC issuer URL (the identity provider).

```terraform
  subject             = "system:serviceaccount:default:${each.key}"
```
- **Line 34**: Link to the Kubernetes service account in the default namespace (e.g., `system:serviceaccount:default:customer-service`).

```terraform
  depends_on = [
    azurerm_user_assigned_identity.workload_identity,
    azurerm_kubernetes_cluster.aks
  ]
```
- **Lines 36-39**: Ensure the managed identity and AKS cluster are created first.

---

## 9. infrastructure/postgres_dns.tf - Line-by-Line

This file creates a private DNS zone for PostgreSQL, enabling private network access from the VNet.

```terraform
resource "azurerm_private_dns_zone" "postgres" {
```
- **Line 1**: Create a private DNS zone for PostgreSQL.

```terraform
  name                = "privatelink.postgres.database.azure.com"
```
- **Line 2**: Use the standard Azure private link DNS zone name for PostgreSQL.

```terraform
  resource_group_name = azurerm_resource_group.rg.name
```
- **Line 3**: Place in the resource group.

```terraform
  tags                = local.common_tags
```
- **Line 4**: Apply common tags.

```terraform
  depends_on = [azurerm_resource_group.rg]
```
- **Line 6**: Ensure resource group is created first.

```terraform
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_vnet_link" {
```
- **Line 10**: Link the private DNS zone to the VNet (enables name resolution for private PostgreSQL endpoints).

```terraform
  name                  = "postgres-dns-vnet-link"
```
- **Line 11**: Name the link.

```terraform
  resource_group_name   = azurerm_resource_group.rg.name
```
- **Line 12**: Place in the resource group.

```terraform
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
```
- **Line 13**: Link to the private DNS zone created above.

```terraform
  virtual_network_id    = azurerm_virtual_network.vnet.id
```
- **Line 14**: Link to the VNet.

```terraform
  registration_enabled  = false
```
- **Line 15**: Disable automatic DNS registration (manual registration only).

```terraform
  depends_on = [
    azurerm_private_dns_zone.postgres,
    azurerm_virtual_network.vnet
  ]
```
- **Lines 17-20**: Ensure DNS zone and VNet are created first.

---

## 10. infrastructure/security.tf - Line-by-Line

This file configures network security groups (NSGs) to control traffic to/from the AKS subnet.

```terraform
resource "azurerm_network_security_group" "aks_nsg" {
```
- **Line 1**: Create a network security group for the AKS subnet.

```terraform
  name                = "${var.environment}-aks-nsg"
```
- **Line 2**: Name the NSG based on environment (e.g., `dev-aks-nsg`).

```terraform
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
```
- **Lines 3-4**: Deploy to the same location and resource group.

```terraform
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
```
- **Lines 5-9**: Apply tags for organization.

```terraform
resource "azurerm_network_security_rule" "allow_http_inbound" {
```
- **Line 12**: Create a security rule to allow HTTP traffic.

```terraform
  name                        = "Allow-HTTP-Inbound"
```
- **Line 13**: Name the rule.

```terraform
  priority                    = 1000
```
- **Line 14**: Set priority (lower numbers are evaluated first).

```terraform
  direction                   = "Inbound"
```
- **Line 15**: Apply to inbound traffic.

```terraform
  access                      = "Allow"
```
- **Line 16**: Allow matching traffic.

```terraform
  protocol                    = "Tcp"
```
- **Line 17**: Apply to TCP protocol.

```terraform
  source_port_range           = "*"
```
- **Line 18**: Match any source port.

```terraform
  destination_port_range      = "80"
```
- **Line 19**: Match destination port 80 (HTTP).

```terraform
  source_address_prefix       = "*"
```
- **Line 20**: Match any source IP address.

```terraform
  destination_address_prefix  = "*"
```
- **Line 21**: Match any destination IP address.

```terraform
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
```
- **Line 22**: Attach the rule to the NSG.

```terraform
  resource_group_name         = azurerm_resource_group.rg.name
```
- **Line 23**: Place in the resource group.

```terraform
  description                 = "Allow inbound HTTP traffic to AKS LoadBalancer"
```
- **Line 24**: Describe the rule's purpose.

```terraform
resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
```
- **Line 27**: Associate the NSG with the AKS subnet.

```terraform
  subnet_id                 = azurerm_subnet.aks_subnet.id
```
- **Line 28**: Attach to the AKS subnet.

```terraform
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
```
- **Line 29**: Attach the NSG.

---

## 11. infrastructure/logging.tf - Line-by-Line

This file creates a Log Analytics workspace for collecting diagnostics and monitoring data from AKS.

```terraform
resource "azurerm_log_analytics_workspace" "aks_logs" {
```
- **Line 1**: Create a Log Analytics workspace.

```terraform
  name                = local.log_analytics_name
```
- **Line 2**: Use the workspace name from `locals.tf`.

```terraform
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
```
- **Lines 3-4**: Deploy to the same location and resource group.

```terraform
  sku                 = "PerGB2018"
```
- **Line 5**: Use the pay-per-GB pricing tier.

```terraform
  retention_in_days   = 30
```
- **Line 6**: Retain logs for 30 days.

```terraform
  tags                = local.common_tags
```
- **Line 7**: Apply common tags.

```terraform
  depends_on = [azurerm_resource_group.rg]
```
- **Line 9**: Ensure resource group is created first.

---

## 12. infrastructure/variables.tf - Line-by-Line

This file defines input variables that customize the infrastructure deployment.

```terraform
variable "environment" {
```
- **Line 1**: Define a variable for the deployment environment.

```terraform
  description = "Deployment environment (e.g., dev, prod)"
```
- **Line 2**: Describe the variable's purpose.

```terraform
  type        = string
```
- **Line 3**: Specify the variable type (string).

```terraform
  default     = "prod"
```
- **Line 4**: Default to "prod" if not specified.

```terraform
variable "location" {
```
- **Line 18**: Define a variable for the Azure region.

```terraform
  default     = "eastus"
```
- **Line 21**: Default to East US.

```terraform
  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westus2", "centralus", "northeurope", "westeurope"], var.location)
    error_message = "Location must be one of the supported Azure regions."
  }
```
- **Lines 23-26**: Validate that location is a supported Azure region (prevents deployment to unsupported regions).

```terraform
variable "node_count" {
  description = "Number of AKS worker nodes"
  type        = number
  default     = 3
}
```
- **Lines 30-34**: Define the number of AKS worker nodes (default 3).

```terraform
variable "enable_auto_scaling" {
  description = "Enable AKS node pool autoscaling"
  type        = bool
  default     = true
}
```
- **Lines 43-47**: Enable autoscaling by default.

```terraform
variable "min_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 2
}
```
- **Lines 49-53**: Minimum 2 nodes when autoscaling.

```terraform
variable "max_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 5
}
```
- **Lines 55-59**: Maximum 5 nodes when autoscaling.

```terraform
variable "private_cluster_enabled" {
  description = "Enable AKS private cluster"
  type        = bool
  default     = true
}
```
- **Lines 61-65**: Enable private cluster mode by default (API server not publicly accessible).

```terraform
variable "db_admin_password" {
  description = "PostgreSQL admin password (minimum 8 characters)"
  type        = string
  sensitive   = true
```
- **Lines 81-84**: Mark the password as sensitive (will be hidden in logs).

```terraform
  validation {
    condition     = length(var.db_admin_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
```
- **Lines 86-89**: Validate password is at least 8 characters.

```terraform
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
```
- **Lines 106-110**: Define VNet address space (65,536 IP addresses).

```terraform
variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
```
- **Lines 112-116**: Define AKS subnet (256 IP addresses).

```terraform
variable "aks_service_cidr" {
  description = "CIDR for Kubernetes services (must not overlap with VNet)"
  type        = string
  default     = "10.1.0.0/16"
}
```
- **Lines 133-137**: Define Kubernetes service CIDR (for ClusterIP services, must not overlap with VNet).

```terraform
variable "aks_dns_service_ip" {
  description = "IP address for Kubernetes DNS service (must be within service_cidr)"
  type        = string
  default     = "10.1.0.10"
}
```
- **Lines 139-143**: Define Kubernetes DNS service IP (must be within service CIDR).

---

## 13. infrastructure/outputs.tf - Line-by-Line

This file defines outputs that expose important values after deployment (used by GitHub Actions and for reference).

```terraform
output "resource_group_name" {
```
- **Line 1**: Output the resource group name.

```terraform
  value       = azurerm_resource_group.rg.name
```
- **Line 2**: Get the name from the resource group resource.

```terraform
  description = "The name of the resource group"
```
- **Line 3**: Describe the output.

```terraform
output "kubernetes_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster"
}
```
- **Lines 11-14**: Output the AKS cluster name (used in GitHub Actions to configure kubectl).

```terraform
output "host" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive = true
}
```
- **Lines 21-24**: Output the AKS API server host (marked sensitive to hide in logs).

```terraform
output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The login server URL for ACR (for GitHub secrets)"
}
```
- **Lines 41-44**: Output the ACR login server (e.g., `devaccount002acr.azurecr.io`, used to push/pull images).

```terraform
output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "The name of the ACR (for GitHub secrets)"
}
```
- **Lines 46-49**: Output the ACR name (used in GitHub Actions).

```terraform
output "postgres_fqdn" {
  value       = azurerm_postgresql_flexible_server.db.fqdn
  description = "The FQDN of PostgreSQL server (for GitHub secrets: POSTGRES_HOST)"
}
```
- **Lines 61-64**: Output the PostgreSQL FQDN (used in K8s ConfigMaps and Secrets).

```terraform
output "postgres_admin_username" {
  value       = var.db_admin_username
  sensitive   = true
  description = "PostgreSQL admin username (for GitHub secrets: POSTGRES_USERNAME)"
}
```
- **Lines 66-70**: Output the PostgreSQL admin username (marked sensitive).

```terraform
output "postgres_admin_password" {
  value       = var.db_admin_password
  sensitive   = true
  description = "PostgreSQL admin password (for GitHub secrets: POSTGRES_PASSWORD)"
}
```
- **Lines 72-76**: Output the PostgreSQL admin password (marked sensitive).

```terraform
output "azure_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Azure tenant ID (AZURE_TENANT_ID secret)"
}
```
- **Lines 86-89**: Output the Azure tenant ID (used for OIDC authentication in GitHub Actions).

```terraform
output "azure_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "Azure subscription ID (AZURE_SUBSCRIPTION_ID secret)"
}
```
- **Lines 91-94**: Output the Azure subscription ID (used in GitHub Actions).

```terraform
output "workload_identity_client_id" {
  value       = azurerm_user_assigned_identity.workload_identity.client_id
  description = "Client ID of workload identity for pod authentication to Azure resources"
}
```
- **Lines 96-99**: Output the workload identity client ID (used in K8s pod annotations for passwordless Azure authentication).

---

# Summary

This comprehensive guide provides line-by-line explanations of all Terraform infrastructure files and Kubernetes YAML deployment files for the Account Opening application.

## Part 1: Terraform Files
- **main.tf**: Provider configuration and Terraform backend
- **resource_group.tf**: Azure resource group creation
- **locals.tf**: Computed local values and naming conventions
- **network.tf**: Virtual network and subnet configuration
- **aks.tf**: Azure Kubernetes Service cluster setup
- **postgres.tf**: PostgreSQL database server and databases
- **acr.tf**: Container registry with private endpoint
- **iam.tf**: Identity and access management (RBAC, workload identity)
- **postgres_dns.tf**: Private DNS zone for PostgreSQL
- **security.tf**: Network security groups and rules
- **logging.tf**: Log Analytics workspace for monitoring
- **variables.tf**: Input variables for customization
- **outputs.tf**: Output values for GitHub Actions and reference

## Part 2: Kubernetes YAML Files
- **Deployments**: How pods are created, managed, and updated
- **Services**: How pods are exposed to the network
- **ConfigMaps**: Non-sensitive configuration injection
- **Secrets**: Sensitive data injection
- **Deployment Flow**: Step-by-step process of how resources are created and connected

This documentation should be updated whenever infrastructure files change. For additional details, refer to the comments in each file or consult the DevOps team.

---
