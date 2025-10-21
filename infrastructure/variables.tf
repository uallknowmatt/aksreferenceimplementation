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
