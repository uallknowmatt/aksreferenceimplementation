# ============================================
# Production Environment Configuration
# ============================================

environment = "prod"
owner       = "devops-team"
project     = "account-opening"
location    = "eastus"

# ============================================
# AKS Configuration (Production-Grade)
# ============================================
node_count                      = 3
vm_size                         = "Standard_D4s_v3"  # Larger VMs for production
enable_auto_scaling             = true
min_count                       = 3
max_count                       = 10                  # Higher ceiling for production
private_cluster_enabled         = true                # Private cluster for security
api_server_authorized_ip_ranges = []                  # Add your authorized IPs

# ============================================
# PostgreSQL Configuration (Production-Grade)
# ============================================
db_admin_username = "psqladmin"
db_admin_password = "CHANGE_ME_PRODUCTION_PASSWORD_123!"  # ⚠️ Use Azure Key Vault!
db_sku_name       = "GP_Standard_D4s_v3"                  # General Purpose tier
db_storage_mb     = 131072                                # 128 GB for production

# ============================================
# Networking Configuration (Isolated from Dev)
# ============================================
vnet_address_space        = ["10.10.0.0/16"]  # Different from dev
aks_subnet_address_prefix = ["10.10.1.0/24"]
acr_subnet_address_prefix = ["10.10.2.0/24"]
aks_service_cidr          = "10.11.0.0/16"    # Must not overlap with VNet
aks_dns_service_ip        = "10.11.0.10"      # Must be within service_cidr
