# Infrastructure as Code: Terraform File Explanations

This document provides a line-by-line and block-by-block explanation of all Terraform files in the `infrastructure/` directory. It is intended to help engineers, reviewers, and auditors understand the purpose and function of each resource, variable, and configuration in the Azure infrastructure for this project.

---

## main.tf

- `terraform { ... }` — Configures the backend (remote state in Azure Storage) and required providers (azurerm, azuread). Specifies the minimum Terraform version.
  - `backend "azurerm" { ... }` — Stores state in an Azure Storage Account for team collaboration and automation.
  - `required_providers` — Ensures the correct provider plugins are used.
  - `required_version` — Enforces a minimum Terraform version.
- `provider "azurerm" { features {} }` — Configures the AzureRM provider for resource management.
- `provider "azuread" {}` — Configures the Azure Active Directory provider for identity resources.
- `data "azurerm_client_config" "current" {}` — Fetches information about the current Azure client (useful for referencing tenant/subscription IDs).
- Comments explain that all resources are split into separate files for clarity.

---

## resource_group.tf

- `resource "azurerm_resource_group" "rg" { ... }` — Creates the main Azure Resource Group for all resources.
  - `name` — Uses a local variable for consistent naming.
  - `location` — Uses a variable for region.
  - `tags` — Applies common tags for cost management and tracking.
  - `lifecycle { prevent_destroy = false }` — Allows the resource group to be destroyed (set to true in production for safety).

---

## logging.tf

- `resource "azurerm_log_analytics_workspace" "aks_logs" { ... }` — Creates a Log Analytics workspace for AKS monitoring and diagnostics.
  - `name`, `location`, `resource_group_name` — Standard resource properties.
  - `sku` — Pricing tier for log analytics.
  - `retention_in_days` — How long logs are kept.
  - `tags` — Common tags.
  - `depends_on` — Ensures the resource group is created first.

---

## network.tf

- `resource "azurerm_virtual_network" "vnet" { ... }` — Creates the main VNet for all resources.
  - `address_space` — The IP range for the VNet.
- `resource "azurerm_subnet" "aks_subnet" { ... }` — Subnet for AKS nodes.
- `resource "azurerm_subnet" "acr_subnet" { ... }` — Subnet for ACR private endpoint.
- `resource "azurerm_subnet" "postgres_subnet" { ... }` — Subnet for PostgreSQL, with delegation for flexible server and private endpoint policies.

---

## security.tf

- `resource "azurerm_network_security_group" "aks_nsg" { ... }` — NSG for AKS subnet, with tags.
- `resource "azurerm_network_security_rule" "allow_http_inbound" { ... }` — Allows inbound HTTP traffic to AKS LoadBalancer.
- `resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" { ... }` — Associates the NSG with the AKS subnet.

---

## aks.tf

- `resource "azurerm_kubernetes_cluster" "aks" { ... }` — Main AKS cluster resource.
  - `name`, `location`, `resource_group_name`, `dns_prefix`, `private_cluster_enabled`, `role_based_access_control_enabled`, `tags` — Standard AKS settings.
  - `default_node_pool` — Configures the system node pool, with autoscaling and VM size.
  - `identity { type = "SystemAssigned" }` — Uses a managed identity for the cluster.
  - `oidc_issuer_enabled`, `workload_identity_enabled` — Enables OIDC and workload identity for secure pod access.
  - `network_profile` — Configures CNI, network policy, service CIDR, and DNS IP.
  - `oms_agent` — Connects AKS to Log Analytics.
  - `depends_on` — Ensures subnets and log analytics are ready.

---

## acr.tf

- `resource "azurerm_container_registry" "acr" { ... }` — Creates the Azure Container Registry (ACR) for Docker images.
  - `sku` — Premium for private endpoint support.
  - `admin_enabled` — Disabled for security; use managed identity.
- `resource "azurerm_private_endpoint" "acr_pe" { ... }` — Private endpoint for ACR, allowing private VNet access.

---

## iam.tf

- `resource "azurerm_role_assignment" "aks_acr_pull" { ... }` — Grants AKS permission to pull images from ACR.
- `resource "azurerm_user_assigned_identity" "workload_identity" { ... }` — Managed identity for workload pods.
- `resource "azurerm_federated_identity_credential" "workload_identity" { ... }` — Federated credentials for K8s service accounts to use Azure identity.

---

## postgres.tf

- `resource "azurerm_postgresql_flexible_server" "db" { ... }` — Creates a PostgreSQL Flexible Server, VNet-integrated, with private DNS and no public access.
  - `administrator_login`, `administrator_password`, `sku_name`, `storage_mb`, `version`, `zone`, `tags` — Standard DB settings.
  - `delegated_subnet_id`, `private_dns_zone_id`, `public_network_access_enabled` — For private networking.
  - `lifecycle { ignore_changes = [zone, high_availability] }` — Prevents errors on zone/HA changes.
- `resource "azurerm_postgresql_flexible_server_database" "databases" { ... }` — Creates one database per microservice.

---

## postgres_dns.tf

- `resource "azurerm_private_dns_zone" "postgres" { ... }` — Private DNS zone for PostgreSQL.
- `resource "azurerm_private_dns_zone_virtual_network_link" "postgres_vnet_link" { ... }` — Links DNS zone to VNet for private name resolution.

---

## locals.tf

- `locals { ... }` — Defines computed names and tags for all resources, ensuring consistent Azure naming conventions and easy reuse.

---

## variables.tf

- `variable` blocks — Define all input variables for the infrastructure, including environment, owner, project, location, node counts, VM sizes, networking, database credentials, and backend state config.
- Includes validation for region and password length.

---

## outputs.tf

- `output` blocks — Expose key resource properties (names, IDs, connection info) for use in CI/CD, automation, and documentation. Sensitive values are marked as such.

---

# Kubernetes YAML Files: File-by-File Breakdown

This section explains the purpose of each type of YAML file in the `k8s/` folder, with a file-by-file summary.

## 1. Deployment Files (`*-deployment.yaml`)
- Define how to run and manage application containers (pods) in Kubernetes.
- Specify container images, environment variables, resource limits, health checks, and replica count.
- Example files:
  - `account-service-deployment.yaml`: Deploys the Account Service backend.
  - `customer-service-deployment.yaml`: Deploys the Customer Service backend.
  - `document-service-deployment.yaml`: Deploys the Document Service backend.
  - `notification-service-deployment.yaml`: Deploys the Notification Service backend.
  - `frontend-ui-deployment.yaml`: Deploys the frontend React UI with Nginx.

## 2. Service Files (`*-service.yaml`)
- Expose deployments to the network, internally or externally.
- Provide stable endpoints and load balancing for pods.
- Example files:
  - `account-service-service.yaml`: Exposes Account Service.
  - `customer-service-service.yaml`: Exposes Customer Service.
  - `document-service-service.yaml`: Exposes Document Service.
  - `notification-service-service.yaml`: Exposes Notification Service.
  - `frontend-ui-service.yaml`: Exposes the frontend UI, typically as a LoadBalancer.

## 3. ConfigMap and Secret Files (`*-configmap.yaml`, `*-secret.yaml`)
- Inject configuration and sensitive data into pods at runtime.
- `ConfigMap`: Non-sensitive config (env vars, config files).
- `Secret`: Sensitive data (passwords, API keys, encoded in base64).
- Example files:
  - `account-service-configmap.yaml`, `account-service-secret.yaml`: Config and secrets for Account Service.
  - ... (repeat for each service)
  - `frontend-ui-configmap.yaml`: Config for frontend UI.

## 4. Ingress File (`ingress.yaml`)
- (If present) Configures external HTTP(S) routing to services, often using a single public IP and domain name.

---

# GitHub Actions Dashboard Script: `gh-actions-dashboard.sh`

This Bash script provides a live, step-level dashboard for monitoring GitHub Actions workflow runs from the command line.

- **Location:** `scripts/educational/gh-actions-dashboard.sh`
- **Usage:**
  ```bash
  ./gh-actions-dashboard.sh <workflow_run_id>
  ```
- **What it does:**
  - Continuously fetches the status of all jobs and steps in a given workflow run using the GitHub CLI.
  - Displays a table of job and step statuses, refreshing every 5 seconds.
  - Useful for real-time monitoring of CI/CD pipelines without leaving the terminal.
- **Key logic:**
  - Checks for a run ID argument.
  - Uses `gh run view` with `--json jobs` and `jq` to extract job/step names and statuses.
  - Uses `column` for table formatting and `clear` for a live dashboard effect.

---

This documentation is auto-generated and should be updated if the Terraform files change. For further details, see the comments in each `.tf` file or reach out to the DevOps team.
