variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "bank-devops"
}

variable "project" {
  description = "Project name (used in resource naming)"
  type        = string
  default     = "account-opening"
}

variable "location" {
  description = "Azure region location"
  type        = string
  default     = "eastus"
  
  validation {
    condition     = contains(["eastus", "eastus2", "westus", "westus2", "centralus", "northeurope", "westeurope"], var.location)
    error_message = "Location must be one of the supported Azure regions."
  }
}

variable "node_count" {
  description = "Number of AKS worker nodes"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "Size of AKS worker nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "enable_auto_scaling" {
  description = "Enable AKS node pool autoscaling"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 5
}

variable "private_cluster_enabled" {
  description = "Enable AKS private cluster"
  type        = bool
  default     = true
}

variable "api_server_authorized_ip_ranges" {
  description = "List of authorized IP ranges for AKS API server (empty for public access in dev)"
  type        = list(string)
  default     = []
}

variable "db_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "psqladmin"
  sensitive   = true
}

variable "db_admin_password" {
  description = "PostgreSQL admin password (minimum 8 characters)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_admin_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "db_sku_name" {
  description = "PostgreSQL SKU name (pricing tier)"
  type        = string
  default     = "B_Gen5_1"
}

variable "db_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 5120
}

# ============================================
# Networking Variables
# ============================================

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "acr_subnet_address_prefix" {
  description = "Address prefix for ACR subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "postgres_subnet_address_prefix" {
  description = "Address prefix for PostgreSQL subnet (VNet integrated)"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "aks_service_cidr" {
  description = "CIDR for Kubernetes services (must not overlap with VNet)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "IP address for Kubernetes DNS service (must be within service_cidr)"
  type        = string
  default     = "10.1.0.10"
}

# ============================================
# Terraform State Backend Variables
# ============================================

variable "terraform_state_resource_group" {
  description = "Resource group name for Terraform state storage"
  type        = string
  default     = "terraform-state-rg"
}

variable "terraform_state_storage_account" {
  description = "Storage account name for Terraform state"
  type        = string
  default     = "tfstateaccountopening"
}

variable "terraform_state_container" {
  description = "Container name for Terraform state"
  type        = string
  default     = "tfstate"
}

variable "terraform_state_key" {
  description = "State file name"
  type        = string
  default     = "dev.terraform.tfstate"
}
