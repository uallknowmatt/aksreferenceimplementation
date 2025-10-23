# ============================================
# Development Environment Configuration
# ============================================

environment = "dev"
owner       = "devops-team"
project     = "account-opening"
location    = "eastus2"  # Changed from eastus due to PostgreSQL service issues

# ============================================
# AKS Configuration (Development - Cost Optimized)
# ============================================
# OPTION 1 (Ultra Low Cost - $3.80/month): B1s = 1 vCPU, 1GB RAM
# OPTION 2 (Recommended for AKS - $7.59/month): B2ts v2 = 2 vCPU, 1GB RAM
# OPTION 3 (Better for testing - $30.37/month): B2ls v2 = 2 vCPU, 4GB RAM
node_count                      = 1        # Single node for dev  
vm_size                         = "Standard_B2s"  # 2 vCPU, 4GB RAM @ ~$30/month
enable_auto_scaling             = false    # Disable autoscaling to control costs
min_count                       = 1
max_count                       = 1
private_cluster_enabled         = false  # Public for easier dev access
api_server_authorized_ip_ranges = []     # Open for development

# ============================================
# PostgreSQL Configuration (Development - Cost Optimized)
# ============================================
db_admin_username = "psqladmin"
db_admin_password = "ChangeMe123!MinLength8"  # Change in production!
db_sku_name       = "B_Standard_B1ms"         # Burstable tier for dev (~$12/month)
db_storage_mb     = 32768                     # 32 GB minimum for dev

# COST BREAKDOWN:
# - AKS Control Plane (Free tier): $0/month
# - Single B2s node: ~$30/month  
# - PostgreSQL B1ms: ~$12/month
# - ACR Basic: ~$5/month
# - Networking: ~$2/month
# ----------------------------------------
# TOTAL: ~$49/month (vs $320/month = 85% savings!)
#
# TO GET UNDER $2/MONTH: 
# Stop/Deallocate when not in use! Use the workflow approvals.

# ============================================
# Networking Configuration
# ============================================
vnet_address_space        = ["10.0.0.0/16"]
aks_subnet_address_prefix = ["10.0.1.0/24"]
acr_subnet_address_prefix = ["10.0.2.0/24"]
aks_service_cidr          = "10.1.0.0/16"  # Must not overlap with VNet
aks_dns_service_ip        = "10.1.0.10"    # Must be within service_cidr
