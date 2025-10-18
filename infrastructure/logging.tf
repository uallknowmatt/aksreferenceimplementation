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
