environment = "dev"
owner = "devops-team"
project = "account-opening"
location = "eastus"

# AKS Configuration
node_count = 2
vm_size = "Standard_DS2_v2"
enable_auto_scaling = true
min_count = 1
max_count = 3
private_cluster_enabled = false
api_server_authorized_ip_ranges = []

# PostgreSQL Configuration
db_admin_username = "psqladmin"
db_admin_password = "ChangeMe123!MinLength8"
db_sku_name = "B_Standard_B1ms"
db_storage_mb = 32768

# Networking Configuration
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_address_prefix = ["10.0.1.0/24"]
acr_subnet_address_prefix = ["10.0.2.0/24"]
aks_service_cidr = "10.1.0.0/16"
aks_dns_service_ip = "10.1.0.10"

# Terraform State Backend
terraform_state_resource_group = "terraform-state-rg"
terraform_state_storage_account = "tfstateaccountopening"
terraform_state_container = "tfstate"
terraform_state_key = "dev.terraform.tfstate"
