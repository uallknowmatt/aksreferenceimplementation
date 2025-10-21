# ============================================
# Log Analytics Workspace
# ============================================
# Depends on: Resource Group
# Used by: AKS for diagnostics and monitoring

resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = local.log_analytics_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}
