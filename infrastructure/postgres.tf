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
  tags                   = local.common_tags
  
  depends_on = [azurerm_resource_group.rg]
  
  # Simplified for dev - remove high availability and AD auth
  # Uncomment for production:
  # high_availability {
  #   mode = "ZoneRedundant"
  # }
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
