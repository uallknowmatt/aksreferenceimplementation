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

# ============================================
# GitHub Actions Service Principal Outputs
# ============================================
output "github_actions_client_id" {
  value       = azuread_application.github_actions.client_id
  description = "Client ID for GitHub Actions service principal (AZURE_CLIENT_ID for OIDC)"
}

# OPTION 1: Service Principal Secret (Traditional - Commented Out)
# Uncomment if using service principal password instead of OIDC
# output "github_actions_client_secret" {
#   value       = azuread_service_principal_password.github_actions.value
#   sensitive   = true
#   description = "Client secret for GitHub Actions service principal (for AZURE_CREDENTIALS)"
# }

output "github_actions_object_id" {
  value       = azuread_service_principal.github_actions.object_id
  description = "Object ID of GitHub Actions service principal"
}

# ============================================
# OIDC Outputs (RECOMMENDED APPROACH) ✅
# ============================================
output "github_oidc_client_id" {
  value       = azuread_application.github_actions.client_id
  description = "Client ID for GitHub OIDC authentication (AZURE_CLIENT_ID secret)"
}

output "azure_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Azure tenant ID (AZURE_TENANT_ID secret)"
}

output "azure_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "Azure subscription ID (AZURE_SUBSCRIPTION_ID secret)"
}

# ============================================
# Workload Identity Outputs
# ============================================
output "workload_identity_client_id" {
  value       = azurerm_user_assigned_identity.workload_identity.client_id
  description = "Client ID of workload identity for pod authentication to Azure resources"
}

output "workload_identity_principal_id" {
  value       = azurerm_user_assigned_identity.workload_identity.principal_id
  description = "Principal ID of workload identity"
}

# OPTION 1: Service Principal Secret JSON (Traditional - Commented Out)
# Uncomment if using service principal password instead of OIDC
# output "azure_credentials_json" {
#   value = jsonencode({
#     clientId       = azuread_application.github_actions.client_id
#     clientSecret   = azuread_service_principal_password.github_actions.value
#     subscriptionId = data.azurerm_client_config.current.subscription_id
#     tenantId       = data.azurerm_client_config.current.tenant_id
#   })
#   sensitive   = true
#   description = "Complete JSON for AZURE_CREDENTIALS GitHub secret (auto-generated!)"
# }

# OPTION 2: OIDC Summary (RECOMMENDED) ✅
output "github_secrets_oidc_summary" {
  value = <<-EOT
  
  ╔══════════════════════════════════════════════════════════════════╗
  ║     🎯 OIDC SETUP - ZERO SECRETS! MAXIMUM SECURITY! 🎯          ║
  ╚══════════════════════════════════════════════════════════════════╝
  
  ✅ NO clientSecret needed - GitHub generates OIDC tokens automatically!
  ✅ Tokens expire in MINUTES (not years!)
  ✅ NO rotation needed - zero maintenance!
  ✅ Microsoft recommended approach!
  
  ┌──────────────────────────────────────────────────────────────────┐
  │ ADD THESE 3 IDs TO GITHUB SECRETS (NOT ACTUALLY SECRETS!)        │
  ├──────────────────────────────────────────────────────────────────┤
  │                                                                   │
  │ Name: AZURE_CLIENT_ID                                            │
  │ Value: ${azuread_application.github_actions.client_id}
  │                                                                   │
  │ Name: AZURE_TENANT_ID                                            │
  │ Value: ${data.azurerm_client_config.current.tenant_id}
  │                                                                   │
  │ Name: AZURE_SUBSCRIPTION_ID                                      │
  │ Value: ${data.azurerm_client_config.current.subscription_id}
  │                                                                   │
  │ Add them here:                                                   │
  │ https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions
  │                                                                   │
  └──────────────────────────────────────────────────────────────────┘
  
  ┌──────────────────────────────────────────────────────────────────┐
  │ HOW OIDC WORKS (No Secrets Stored!)                              │
  ├──────────────────────────────────────────────────────────────────┤
  │                                                                   │
  │ 1. Workflow starts                                               │
  │ 2. GitHub generates OIDC token (JWT, expires in minutes)         │
  │ 3. azure/login action exchanges OIDC token for Azure AD token    │
  │ 4. Azure validates:                                              │
  │    - Token signature (from GitHub)                               │
  │    - Repository match                                            │
  │    - Branch match (main)                                         │
  │ 5. Azure issues short-lived access token                         │
  │ 6. Workflow uses access token (expires after run)                │
  │                                                                   │
  └──────────────────────────────────────────────────────────────────┘
  
  ┌──────────────────────────────────────────────────────────────────┐
  │ SECURITY BENEFITS                                                 │
  ├──────────────────────────────────────────────────────────────────┤
  │ ✅ No long-lived secrets (tokens expire in minutes)              │
  │ ✅ Can't replay tokens (single-use)                              │
  │ ✅ Can't use from anywhere (tied to GitHub repo/branch)          │
  │ ✅ Complete audit trail (every token logged)                     │
  │ ✅ Zero rotation overhead (GitHub handles it)                    │
  └──────────────────────────────────────────────────────────────────┘
  
  ═══════════════════════════════════════════════════════════════════
  
  📖 Full guide: See OIDC_SETUP_GUIDE.md
  
  ═══════════════════════════════════════════════════════════════════
  EOT
  description = "GitHub OIDC setup instructions (RECOMMENDED APPROACH)"
}

output "github_secrets_summary" {
  value = <<-EOT
  
  ╔══════════════════════════════════════════════════════════════════╗
  ║   🔄 CHOOSE YOUR AUTHENTICATION METHOD FOR GITHUB ACTIONS         ║
  ╚══════════════════════════════════════════════════════════════════╝
  
  ┌──────────────────────────────────────────────────────────────────┐
  │ OPTION 1: OIDC (RECOMMENDED) ✅                                   │
  ├──────────────────────────────────────────────────────────────────┤
  │ • Zero secrets stored                                            │
  │ • Zero rotation needed                                           │
  │ • Maximum security                                               │
  │                                                                   │
  │ See: terraform output github_secrets_oidc_summary                │
  │ Guide: OIDC_SETUP_GUIDE.md                                       │
  └──────────────────────────────────────────────────────────────────┘
  
  ┌──────────────────────────────────────────────────────────────────┐
  │ OPTION 2: Service Principal Secret (Legacy)                      │
  ├──────────────────────────────────────────────────────────────────┤
  │ • 1 long-lived secret                                            │
  │ • Requires annual rotation                                       │
  │ • Not recommended by Microsoft                                   │
  │                                                                   │
  │ To enable: Uncomment azuread_service_principal_password          │
  │            in infrastructure/iam.tf                              │
  │ Guide: BOOTSTRAP_GUIDE.md                                        │
  └──────────────────────────────────────────────────────────────────┘
  
  ⚡ QUICK COMPARISON:
  
  | Aspect            | OIDC ✅        | Service Principal Secret |
  |-------------------|---------------|--------------------------|
  | Secrets stored    | 0             | 1 (clientSecret)         |
  | Token lifetime    | Minutes       | 1 year                   |
  | Rotation needed   | NO            | YES (automated)          |
  | Security risk     | Very low      | Medium                   |
  | Setup complexity  | Same          | Same                     |
  | Microsoft recomm. | YES           | NO                       |
  
  ═══════════════════════════════════════════════════════════════════
  
  💡 We HIGHLY recommend using OIDC for maximum security and zero
     maintenance!
  
  ═══════════════════════════════════════════════════════════════════
  EOT
  description = "Summary of authentication options for GitHub Actions"
}

# Keep the old output name for backward compatibility
output "azure_credentials_json" {
  value = <<-EOT
  NOTICE: OIDC is now the recommended approach!
  
  To use OIDC (zero secrets!):
  1. Run: terraform output github_secrets_oidc_summary
  2. Follow OIDC_SETUP_GUIDE.md
  
  To use service principal secret (legacy):
  1. Uncomment azuread_service_principal_password in infrastructure/iam.tf
  2. Run: terraform apply
  3. Run: terraform output -raw azure_credentials_json
  EOT
  description = "Deprecated - Use OIDC instead (see github_secrets_oidc_summary)"
}
