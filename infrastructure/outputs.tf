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

output "github_secrets_summary" {
  value = <<-EOT
  
  ===== GitHub Secrets Configuration =====
  
  Add these secrets to your GitHub repository:
  https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
  
  ACR_LOGIN_SERVER = ${azurerm_container_registry.acr.login_server}
  ACR_NAME = ${azurerm_container_registry.acr.name}
  AKS_CLUSTER_NAME = ${azurerm_kubernetes_cluster.aks.name}
  AKS_RESOURCE_GROUP = ${azurerm_resource_group.rg.name}
  POSTGRES_HOST = ${azurerm_postgresql_flexible_server.db.fqdn}
  POSTGRES_USERNAME = ${var.db_admin_username}
  POSTGRES_PASSWORD = <from your tfvars file>
  
  For ACR_USERNAME and ACR_PASSWORD:
  - Run: az acr update --name ${azurerm_container_registry.acr.name} --admin-enabled true
  - Run: az acr credential show --name ${azurerm_container_registry.acr.name}
  
  For AZURE_CREDENTIALS:
  - Create service principal with: az ad sp create-for-rbac --name "github-actions-account-opening" --role contributor --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/${azurerm_resource_group.rg.name} --sdk-auth
  
  =========================================
  EOT
  description = "Summary of values needed for GitHub secrets"
}
