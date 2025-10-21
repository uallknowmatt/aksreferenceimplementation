output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the resource group"
}

output "aks_resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the AKS resource group (for GitHub secrets)"
}

output "kubernetes_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster (for GitHub secrets)"
}

output "host" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The login server URL for ACR (for GitHub secrets)"
}

output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "The name of the ACR (for GitHub secrets)"
}

output "acr_admin_username" {
  value       = azurerm_container_registry.acr.admin_username
  description = "ACR admin username (if admin is enabled)"
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

output "postgres_fqdn" {
  value       = azurerm_postgresql_flexible_server.db.fqdn
  description = "The FQDN of PostgreSQL server (for GitHub secrets: POSTGRES_HOST)"
}

output "postgres_admin_username" {
  value       = var.db_admin_username
  sensitive   = true
  description = "PostgreSQL admin username (for GitHub secrets: POSTGRES_USERNAME)"
}

output "postgres_admin_password" {
  value       = var.db_admin_password
  sensitive   = true
  description = "PostgreSQL admin password (for GitHub secrets: POSTGRES_PASSWORD)"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the virtual network"
}

output "aks_subnet_id" {
  value       = azurerm_subnet.aks_subnet.id
  description = "The ID of the AKS subnet"
}

output "azure_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Azure tenant ID (AZURE_TENANT_ID secret)"
}

output "azure_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "Azure subscription ID (AZURE_SUBSCRIPTION_ID secret)"
}

output "workload_identity_client_id" {
  value       = azurerm_user_assigned_identity.workload_identity.client_id
  description = "Client ID of workload identity for pod authentication to Azure resources"
}

output "workload_identity_principal_id" {
  value       = azurerm_user_assigned_identity.workload_identity.principal_id
  description = "Principal ID of workload identity"
}
