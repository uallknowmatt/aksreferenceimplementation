# ============================================environment = "dev"

# Development Environment Configurationowner = "bank-devops"

# ============================================project = "account-opening"

resource_group_name = "bank-account-opening-rg"

environment = "dev"location = "eastus"

owner       = "devops-team"cluster_name = "bank-aks-cluster"

project     = "account-opening"node_count = 2

location    = "eastus"vm_size = "Standard_DS2_v2"

enable_auto_scaling = true

# ============================================min_count = 1

# AKS Configurationmax_count = 3

# ============================================private_cluster_enabled = false

node_count           = 2api_server_authorized_ip_ranges = ["<YOUR_DEV_IP>"]

vm_size              = "Standard_DS2_v2"acr_name = "bankaccountregistrydev"

enable_auto_scaling  = true
min_count            = 1
max_count            = 3
private_cluster_enabled = false  # Public for dev, private for prod

# Allow public access in dev (empty list = allow all)
# For production, specify your office/VPN IP ranges
api_server_authorized_ip_ranges = []

# ============================================
# PostgreSQL Configuration
# ============================================
db_admin_username = "psqladmin"
# Password should be overridden via environment variable or Azure Key Vault
db_admin_password = "ChangeMe123!MinLength8"
db_sku_name       = "B_Standard_B1ms"  # Burstable tier for dev
db_storage_mb     = 32768  # 32 GB for dev

# ============================================
# Notes:
# ============================================
# - Resource names are generated automatically using locals.tf
# - All resources follow Azure naming conventions: <type>-<project>-<env>-<region>
# - For production, use prod.tfvars with:
#   - private_cluster_enabled = true
#   - Larger VM sizes and node counts
#   - Higher SKU for PostgreSQL with HA enabled
#   - Specific authorized IP ranges
