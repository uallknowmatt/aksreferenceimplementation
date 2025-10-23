# ============================================
# Private DNS Zone for PostgreSQL
# ============================================
# Depends on: Resource Group, Virtual Network
# Required for PostgreSQL VNet integration

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_vnet_link" {
  name                  = "postgres-dns-vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

  depends_on = [
    azurerm_private_dns_zone.postgres,
    azurerm_virtual_network.vnet
  ]
}
