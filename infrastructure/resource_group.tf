# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.resource_group_name}"
  location = var.location
  tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}
