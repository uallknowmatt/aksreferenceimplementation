variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "bank-account-opening-rg"
}

variable "location" {
  description = "Azure region location"
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
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

variable "acr_name" {
  description = "Name of Azure Container Registry"
  type        = string
  default     = "bankaccountregistry"
}
