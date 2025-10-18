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
  description = "Project name"
  type        = string
  default     = "account-opening"
}

variable "resource_group_name" {
  description = "Base name of the resource group"
  type        = string
  default     = "bank-account-opening-rg"
}

variable "location" {
  description = "Azure region location"
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "Base name of the AKS cluster"
  type        = string
  default     = "bank-aks-cluster"
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
  description = "List of authorized IP ranges for AKS API server"
  type        = list(string)
  default     = ["<YOUR_IP>"]
}

variable "acr_name" {
  description = "Base name of Azure Container Registry"
  type        = string
  default     = "bankaccountregistry"
}

variable "db_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "pgadmin"
}

variable "db_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  default     = "ChangeMe123!"
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
