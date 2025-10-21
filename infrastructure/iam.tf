# ============================================
# AKS Kubelet Identity - ACR Pull
# ============================================

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
