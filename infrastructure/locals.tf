# ============================================
# Local Values - Computed Names
# ============================================
# Generate consistent resource names following Azure naming conventions
# Pattern: <environment>-<project>-<resource-type>-<region>

locals {
  # Common tags applied to all resources
  common_tags = {
    environment = var.environment
    project     = var.project
    owner       = var.owner
    managed_by  = "terraform"
    repository  = "aksreferenceimplementation"
  }

  # Location shortcode (for names that need shorter region codes)
  location_short = {
    "eastus"      = "eus"
    "eastus2"     = "eus2"
    "westus"      = "wus"
    "westus2"     = "wus2"
    "centralus"   = "cus"
    "northeurope" = "neu"
    "westeurope"  = "weu"
  }
  location_code = lookup(local.location_short, var.location, "eus")

  # Resource naming with Azure conventions
  # Resource Group: rg-<project>-<environment>-<region>
  resource_group_name = "rg-${var.project}-${var.environment}-${local.location_code}"

  # Virtual Network: vnet-<project>-<environment>-<region>
  vnet_name = "vnet-${var.project}-${var.environment}-${local.location_code}"

  # AKS Cluster: aks-<project>-<environment>-<region>
  aks_name = "aks-${var.project}-${var.environment}-${local.location_code}"

  # ACR: acr<project><environment><region> (no hyphens, lowercase only)
  acr_name = "acr${replace(var.project, "-", "")}${var.environment}${local.location_code}"

  # PostgreSQL: psql-<project>-<environment>-<region>
  postgres_name = "psql-${var.project}-${var.environment}-${local.location_code}"

  # Log Analytics: log-<project>-<environment>-<region>
  log_analytics_name = "log-${var.project}-${var.environment}-${local.location_code}"

  # Managed Identity: id-<project>-<environment>-<service>
  workload_identity_name = "id-${var.project}-${var.environment}-workload"

  # GitHub Actions Identity: id-<project>-<environment>-github
  github_identity_name = "id-${var.project}-${var.environment}-github"

  # Network Security Group: nsg-<subnet-name>
  aks_nsg_name = "nsg-${var.environment}-aks-subnet"
  acr_nsg_name = "nsg-${var.environment}-acr-subnet"

  # Subnets
  aks_subnet_name = "snet-${var.environment}-aks"
  acr_subnet_name = "snet-${var.environment}-acr"

  # Private Endpoints
  acr_pe_name = "pe-${var.environment}-acr"

  # Databases (will be created by Liquibase, but defined here for reference)
  database_names = [
    "customerdb",
    "documentdb",
    "accountdb",
    "notificationdb"
  ]

  # Service names for workload identity
  service_names = [
    "customer-service",
    "document-service",
    "account-service",
    "notification-service"
  ]
}
