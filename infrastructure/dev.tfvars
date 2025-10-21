environment = "dev"
owner = "devops-team"
project = "account-opening"
location = "eastus"

node_count = 2
vm_size = "Standard_DS2_v2"
enable_auto_scaling = true
min_count = 1
max_count = 3
private_cluster_enabled = false
api_server_authorized_ip_ranges = []

db_admin_username = "psqladmin"
db_admin_password = "ChangeMe123!MinLength8"
db_sku_name = "B_Standard_B1ms"
db_storage_mb = 32768
