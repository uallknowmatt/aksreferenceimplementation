# ============================================environment = "prod"

# Production Environment Configurationowner = "bank-devops"

# ============================================project = "account-opening"

resource_group_name = "bank-account-opening-rg"

environment = "prod"location = "eastus"

owner       = "devops-team"cluster_name = "bank-aks-cluster"

project     = "account-opening"node_count = 3

location    = "eastus"vm_size = "Standard_DS3_v2"

enable_auto_scaling = true

# ============================================min_count = 2

# Networking Configurationmax_count = 5

# ============================================private_cluster_enabled = true

vnet_address_space        = ["10.1.0.0/16"]  # Different from devapi_server_authorized_ip_ranges = ["<YOUR_PROD_IP>"]

aks_subnet_address_prefix = ["10.1.1.0/24"]acr_name = "bankaccountregistryprod"

acr_subnet_address_prefix = ["10.1.2.0/24"]

# Service CIDR for AKS internal services
aks_service_cidr   = "10.2.0.0/16"  # Must not overlap with VNet
aks_dns_service_ip = "10.2.0.10"    # Must be within service_cidr

# ============================================
# AKS Configuration (Production-Grade)
# ============================================
node_count                          = 3  # Higher for production
vm_size                             = "Standard_D4s_v3"  # Larger VMs for production
enable_auto_scaling                 = true
min_count                           = 3
max_count                           = 10  # Higher ceiling for production
private_cluster_enabled             = true  # Private cluster for security
api_server_authorized_ip_ranges     = []  # Add your authorized IPs in production

# ============================================
# PostgreSQL Configuration (Production-Grade)
# ============================================
db_admin_username = "psqladmin"
db_admin_password = "CHANGE_ME_PRODUCTION_PASSWORD_123!"  # ⚠️ Use Azure Key Vault in production!
db_sku_name       = "GP_Standard_D4s_v3"  # General Purpose tier for production
db_storage_mb     = 131072  # 128 GB for production

# ============================================
# Backend Configuration
# ============================================
# State file will be: prod.terraform.tfstate
# Update main.tf backend "key" to: "prod.terraform.tfstate"
