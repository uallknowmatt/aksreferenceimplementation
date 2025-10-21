# ============================================
# Azure Container Registry
# ============================================
# Depends on: Resource Group
# Used by: AKS for pulling Docker images, GitHub Actions for pushing images

resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"  # Premium required for private endpoint
  admin_enabled       = false  # Use managed identity and RBAC instead
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}

# ============================================
# ACR Private Endpoint
# ============================================
# Depends on: ACR, ACR Subnet
# Provides private connectivity to ACR from VNet

resource "azurerm_private_endpoint" "acr_pe" {
  name                = local.acr_pe_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.acr_subnet.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "${local.acr_pe_name}-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_subnet.acr_subnet
  ]
}
