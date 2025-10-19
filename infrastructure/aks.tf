# AKS Cluster and related resources
resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "${var.environment}-${var.cluster_name}"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  dns_prefix                = "${var.environment}-${var.cluster_name}"
  private_cluster_enabled   = var.private_cluster_enabled
  role_based_access_control_enabled = true

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    auto_scaling_enabled = var.enable_auto_scaling
    min_count       = var.enable_auto_scaling ? var.min_count : null
    max_count       = var.enable_auto_scaling ? var.max_count : null
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

  # Enable Workload Identity for passwordless authentication
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  # Updated syntax for monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs.id
  }

  # Simplified for dev - no Azure AD integration
  # For production, uncomment and configure:
  # azure_active_directory_role_based_access_control {
  #   azure_rbac_enabled     = true
  #   tenant_id              = data.azurerm_client_config.current.tenant_id
  #   admin_group_object_ids = ["<YOUR_ADMIN_GROUP_OBJECT_ID>"]
  # }

  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}
