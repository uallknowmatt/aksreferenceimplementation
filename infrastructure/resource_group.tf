# ============================================
# Resource Group
# ============================================
# This is the first resource created - all others depend on it

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}
