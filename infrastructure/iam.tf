# ============================================
# GitHub Actions Service Principal
# ============================================
# This service principal is used by GitHub Actions for deployments
# It's created automatically by Terraform - no manual setup needed!

data "azuread_client_config" "current" {}

resource "azuread_application" "github_actions" {
  display_name = "${var.project_name}-github-actions-${var.environment}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "github_actions" {
  client_id                    = azuread_application.github_actions.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

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
# OPTION 2: Federated Identity Credential (OIDC) - RECOMMENDED! ✅
# ============================================
# This allows GitHub Actions to authenticate using OIDC tokens
# NO SECRETS NEEDED! Zero rotation, zero maintenance, maximum security!

resource "azuread_application_federated_identity_credential" "github_actions" {
  application_id = azuread_application.github_actions.id
  display_name   = "${var.project_name}-github-oidc-${var.environment}"
  description    = "Federated identity credential for GitHub Actions OIDC"
  
  # Trust GitHub's OIDC provider
  audiences = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"
  
  # Allow authentication from main branch of your repository
  # Update this if you want to allow other branches
  subject = "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main"
  
  # Alternative subjects for different scenarios:
  # - All branches: "repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/*"
  # - Pull requests: "repo:uallknowmatt/aksreferenceimplementation:pull_request"
  # - Specific environment: "repo:uallknowmatt/aksreferenceimplementation:environment:production"
}

# Grant GitHub Actions SP contributor access to the resource group
resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Grant GitHub Actions SP access to push to ACR
resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Grant GitHub Actions SP access to manage AKS
resource "azurerm_role_assignment" "github_actions_aks_admin" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# ============================================
# AKS Managed Identity
# ============================================
# Role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "acrpull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# ============================================
# Workload Identity for Application Pods
# ============================================
# This is used by pods to authenticate to PostgreSQL via Azure AD (passwordless!)

resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = "${var.project_name}-workload-identity-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Federated identity credential for Kubernetes service accounts
resource "azurerm_federated_identity_credential" "workload_identity" {
  for_each = toset(["customer-service", "document-service", "account-service", "notification-service"])
  
  name                = "${each.key}-federated-identity"
  resource_group_name = azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject             = "system:serviceaccount:default:${each.key}"
}

# Grant workload identity access to PostgreSQL
resource "azurerm_role_assignment" "workload_identity_postgres" {
  scope                = azurerm_postgresql_flexible_server.db.id
  role_definition_name = "Reader"  # Minimal permissions for connection
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
}
