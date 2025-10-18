# Azure Container Registry and private endpoint
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
