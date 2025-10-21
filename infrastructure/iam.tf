# ============================================
# GitHub Actions Identity (OIDC)
# ============================================
# NOTE: These require Azure AD Application.ReadWrite.All permissions
# Since the service principal doesn't have these permissions, these are commented out
# The GitHub Actions identity should be created manually via Azure Portal or by an admin

# data "azuread_client_config" "current" {}

# resource "azuread_application" "github_actions" {
#   display_name = local.github_identity_name
#   owners       = [data.azuread_client_config.current.object_id]
# }

# resource "azuread_service_principal" "github_actions" {
#   client_id                    = azuread_application.github_actions.client_id
#   app_role_assignment_required = false
#   owners                       = [data.azuread_client_config.current.object_id]
#
#   depends_on = [azuread_application.github_actions]
# }

# ============================================
# OPTION 1: Service Principal Password (Traditional)
# ============================================
# Uncomment this if you want to use the traditional service principal secret approach
# Requires storing AZURE_CREDENTIALS (with clientSecret) in GitHub

# resource "azuread_service_principal_password" "github_actions" {
#   service_principal_id = azuread_service_principal.github_actions.object_id
#   end_date_relative    = "8760h" # 1 year
#   
#   # Enable zero-downtime rotation
#   # When rotated, new password is created before old one is deleted
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# ============================================
# Federated Identity Credential (OIDC) ✅
# ============================================
# Depends on: GitHub Actions Application
# Allows GitHub Actions to authenticate using OIDC tokens
# NO SECRETS NEEDED! Zero rotation, zero maintenance, maximum security!

# resource "azuread_application_federated_identity_credential" "github_actions" {
#   application_id = azuread_application.github_actions.id
#   display_name   = "${var.project}-github-oidc-${var.environment}"
#   description    = "Federated identity credential for GitHub Actions OIDC"
#   
#   # Trust GitHub's OIDC provider
#   audiences = ["api://AzureADTokenExchange"]
#   issuer    = "https://token.actions.githubusercontent.com"
#   
#   # Allow authentication from main branch of your repository
#   subject = "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main"
#   
#   depends_on = [azuread_application.github_actions]
#   
#   # Alternative subjects for different scenarios:
#   # - All branches: "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/*"
#   # - Pull requests: "repo:uallknowmatt/aksreferenceimplementation:pull_request"
#   # - Specific environment: "repo:uallknowmatt/aksreferenceimplementation:environment:production"
# }

# ============================================
# GitHub Actions Role Assignments
# ============================================
# COMMENTED OUT: Requires the GitHub Actions service principal to be created first
# These will be managed manually or via a separate admin-level Terraform run

# # Grant Contributor access to resource group
# resource "azurerm_role_assignment" "github_actions_contributor" {
#   scope                = azurerm_resource_group.rg.id
#   role_definition_name = "Contributor"
#   principal_id         = azuread_service_principal.github_actions.object_id
#
#   depends_on = [
#     azuread_service_principal.github_actions,
#     azurerm_resource_group.rg
#   ]
# }

# # Grant ACR push access
# resource "azurerm_role_assignment" "github_actions_acr_push" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPush"
#   principal_id         = azuread_service_principal.github_actions.object_id
#
#   depends_on = [
#     azuread_service_principal.github_actions,
#     azurerm_container_registry.acr
#   ]
# }

# # Grant AKS admin access
# resource "azurerm_role_assignment" "github_actions_aks_admin" {
#   scope                = azurerm_kubernetes_cluster.aks.id
#   role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
#   principal_id         = azuread_service_principal.github_actions.object_id
#
#   depends_on = [
#     azuread_service_principal.github_actions,
#     azurerm_kubernetes_cluster.aks
#   ]
# }

# ============================================
# AKS Kubelet Identity - ACR Pull
# ============================================
# Depends on: AKS, ACR
# Allows AKS to pull Docker images from ACR

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_container_registry.acr
  ]
}

# ============================================
# Workload Identity for Application Pods
# ============================================
# Depends on: Resource Group
# Used by: Pods for passwordless authentication to Azure services

resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = local.workload_identity_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}

# ============================================
# Federated Identity Credentials for K8s Service Accounts
# ============================================
# Depends on: Workload Identity, AKS (for OIDC issuer URL)
# Links Kubernetes service accounts to Azure managed identity

resource "azurerm_federated_identity_credential" "workload_identity" {
  for_each = toset(local.service_names)
  
  name                = "${each.key}-federated-identity"
  resource_group_name = azurerm_resource_group.rg.name
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${each.key}"

  depends_on = [
    azurerm_user_assigned_identity.workload_identity,
    azurerm_kubernetes_cluster.aks
  ]
}

# ============================================
# Workload Identity - PostgreSQL Access
# ============================================
# COMMENTED OUT: Requires User Access Administrator role
# This role assignment should be created manually or by an admin

# resource "azurerm_role_assignment" "workload_identity_postgres" {
#   scope                = azurerm_postgresql_flexible_server.db.id
#   role_definition_name = "Reader"  # Minimal permissions for connection
#   principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
#
#   depends_on = [
#     azurerm_user_assigned_identity.workload_identity,
#     azurerm_postgresql_flexible_server.db
#   ]
# }
