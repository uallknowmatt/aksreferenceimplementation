# Azure Database for PostgreSQL Flexible Server and databases
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "${var.environment}-postgresql-flex"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  sku_name               = var.db_sku_name
  storage_mb             = var.db_storage_mb
  version                = "14"
  
  # Simplified for dev - remove high availability and AD auth
  # Uncomment for production:
  # high_availability {
  #   mode = "ZoneRedundant"
  # }
  
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}

resource "azurerm_postgresql_flexible_server_database" "customerdb" {
  name      = "customerdb"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_database" "documentdb" {
  name      = "documentdb"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_database" "accountdb" {
  name      = "accountdb"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_database" "notificationdb" {
  name      = "notificationdb"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
