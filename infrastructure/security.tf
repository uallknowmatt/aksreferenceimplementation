# Resource locks and NSG
# NOTE: Management locks commented out - requires elevated permissions
# Uncomment these after granting the service principal appropriate permissions

# resource "azurerm_management_lock" "aks_lock" {
#   name       = "${var.environment}-aks-cluster-lock"
#   scope      = azurerm_kubernetes_cluster.aks.id
#   lock_level = "CanNotDelete"
#   notes      = "Protect AKS cluster from accidental deletion."
# }

# resource "azurerm_management_lock" "acr_lock" {
#   name       = "${var.environment}-acr-lock"
#   scope      = azurerm_container_registry.acr.id
#   lock_level = "CanNotDelete"
#   notes      = "Protect ACR from accidental deletion."
# }

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
