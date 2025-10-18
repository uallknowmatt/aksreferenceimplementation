# AKS Cluster and related resources
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
