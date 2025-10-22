# ============================================
# Development Environment Configuration
# ============================================

environment = "dev"
owner       = "devops-team"
project     = "account-opening"
location    = "eastus2"  # Changed from eastus due to PostgreSQL service issues

# ============================================
# AKS Configuration (Development)
# ============================================
node_count                      = 2
vm_size                         = "Standard_DS2_v2"
enable_auto_scaling             = true
min_count                       = 1
max_count                       = 3
private_cluster_enabled         = false  # Public for easier dev access
api_server_authorized_ip_ranges = []     # Open for development

# ============================================
# PostgreSQL Configuration (Development)
# ============================================
db_admin_username = "psqladmin"
db_admin_password = "ChangeMe123!MinLength8"  # Change in production!
db_sku_name       = "B_Standard_B1ms"         # Burstable tier for dev
db_storage_mb     = 32768                     # 32 GB for dev

# ============================================
# Networking Configuration
# ============================================
vnet_address_space        = ["10.0.0.0/16"]
aks_subnet_address_prefix = ["10.0.1.0/24"]
acr_subnet_address_prefix = ["10.0.2.0/24"]
aks_service_cidr          = "10.1.0.0/16"  # Must not overlap with VNet
aks_dns_service_ip        = "10.1.0.10"    # Must be within service_cidr
