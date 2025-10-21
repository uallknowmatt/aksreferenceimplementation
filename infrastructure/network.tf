# ============================================
# Virtual Network
# ============================================
# Depends on: Resource Group

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}

# ============================================
# Subnets
# ============================================
# Depends on: Virtual Network

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = local.aks_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

# Subnet for ACR
resource "azurerm_subnet" "acr_subnet" {
  name                 = local.acr_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}
