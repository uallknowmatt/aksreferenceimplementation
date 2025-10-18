# Azure Provider configuration
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.resource_group_name}"
  location = var.location

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

# Log Analytics Workspace for AKS diagnostics
resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "${var.environment}-${var.cluster_name}-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

# Resource lock for AKS cluster
resource "azurerm_management_lock" "aks_lock" {
  name       = "${var.environment}-aks-cluster-lock"
  scope      = azurerm_kubernetes_cluster.aks.id
  lock_level = "CanNotDelete"
  notes      = "Protect AKS cluster from accidental deletion."
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.environment}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet for ACR
resource "azurerm_subnet" "acr_subnet" {
  name                 = "${var.environment}-acr-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group for AKS
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.environment}-aks-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

# AKS Cluster (with subnet and private endpoint)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.environment}-${var.cluster_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.environment}-${var.cluster_name}"
  private_cluster_enabled = var.private_cluster_enabled
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.vm_size
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.min_count
    max_count           = var.max_count
    node_labels = {
      environment = var.environment
      owner       = var.owner
      project     = var.project
    }
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  addon_profile {
    http_application_routing {
      enabled = true
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs.id
    }
  }

  enable_rbac = true

  azure_active_directory_role_based_access_control {
    managed = true
  }

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

# Container Registry (secure admin settings)
resource "azurerm_container_registry" "acr" {
  name                = "${var.environment}${var.acr_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false # Avoid admin user, use managed identity
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

# Resource lock for ACR
resource "azurerm_management_lock" "acr_lock" {
  name       = "${var.environment}-acr-lock"
  scope      = azurerm_container_registry.acr.id
  lock_level = "CanNotDelete"
  notes      = "Protect ACR from accidental deletion."
}

# Role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "acrpull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Private endpoint for ACR
resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.environment}-acr-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.acr_subnet.id

  private_service_connection {
    name                           = "${var.environment}-acr-psc"
    private_connection_resource_id  = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

# Azure Database for PostgreSQL
resource "azurerm_postgresql_server" "db" {
  name                = "${var.environment}-postgresql-server"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  sku_name            = var.db_sku_name
  storage_mb          = var.db_storage_mb
  version             = "11"
  ssl_enforcement_enabled = true
  public_network_access_enabled = false
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_postgresql_database" "customerdb" {
  name                = "customerdb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_database" "documentdb" {
  name                = "documentdb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_database" "accountdb" {
  name                = "accountdb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_database" "notificationdb" {
  name                = "notificationdb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Use Terraform workspaces or separate tfvars files for dev/prod
# Example: terraform workspace select dev
# Example: terraform apply -var-file="dev.tfvars"
