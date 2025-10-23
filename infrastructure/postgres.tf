# ============================================
# Azure Database for PostgreSQL Flexible Server
# ============================================
# Depends on: Resource Group
# Used by: All microservices for data storage

resource "azurerm_postgresql_flexible_server" "db" {
  name                   = local.postgres_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  sku_name               = var.db_sku_name
  storage_mb             = var.db_storage_mb
  version                = "14"
  zone                   = "2"  # Explicitly set to match existing server in East US 2
  tags                   = local.common_tags
  
  depends_on = [azurerm_resource_group.rg]
  
  # Ignore changes to zone to prevent errors when updating existing servers
  lifecycle {
    ignore_changes = [
      zone,
      high_availability
    ]
  }
  
  # Simplified for dev - remove high availability and AD auth
  # Uncomment for production:
  # high_availability {
  #   mode = "ZoneRedundant"
  # }
}

# ============================================
# PostgreSQL Firewall Rules
# ============================================
# Depends on: PostgreSQL Server
# Allows AKS subnet to access PostgreSQL

resource "azurerm_postgresql_flexible_server_firewall_rule" "aks_subnet" {
  name             = "allow-aks-subnet"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = cidrhost(var.aks_subnet_address_prefix[0], 0)  # First IP in subnet (10.0.1.0)
  end_ip_address   = cidrhost(var.aks_subnet_address_prefix[0], 255) # Last usable IP (10.0.1.255)

  depends_on = [azurerm_postgresql_flexible_server.db]
}

# ============================================
# PostgreSQL Databases
# ============================================
# Depends on: PostgreSQL Server
# One database per microservice

resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each = toset(local.database_names)
  
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  depends_on = [azurerm_postgresql_flexible_server.db]
}
