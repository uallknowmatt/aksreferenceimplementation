# ============================================
# AKS Cluster
# ============================================
# Depends on: Resource Group, AKS Subnet, Log Analytics
# Used by: Applications for hosting containers

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = local.aks_name
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  dns_prefix                        = "${var.environment}-${var.project}"
  private_cluster_enabled           = var.private_cluster_enabled
  role_based_access_control_enabled = true
  tags                              = local.common_tags

  default_node_pool {
    name                 = "system"
    node_count           = var.enable_auto_scaling ? null : var.node_count
    vm_size              = var.vm_size
    auto_scaling_enabled = var.enable_auto_scaling
    min_count            = var.enable_auto_scaling ? var.min_count : null
    max_count            = var.enable_auto_scaling ? var.max_count : null
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    
    node_labels = merge(
      local.common_tags,
      {
        "nodepool" = "system"
      }
    )
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable Workload Identity for passwordless authentication
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    service_cidr      = var.aks_service_cidr
    dns_service_ip    = var.aks_dns_service_ip
  }

  # Monitoring with Log Analytics
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs.id
  }

  depends_on = [
    azurerm_subnet.aks_subnet,
    azurerm_log_analytics_workspace.aks_logs
  ]

  # Simplified for dev - no Azure AD integration
  # For production, uncomment and configure:
  # azure_active_directory_role_based_access_control {
  #   azure_rbac_enabled     = true
  #   tenant_id              = data.azurerm_client_config.current.tenant_id
  #   admin_group_object_ids = ["<YOUR_ADMIN_GROUP_OBJECT_ID>"]
  # }
}
