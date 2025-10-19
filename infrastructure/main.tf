# Azure Provider configuration
provider "azurerm" {
  features {}
}

# Azure AD Provider for Service Principal creation
provider "azuread" {}

# Data sources for current Azure context
data "azurerm_client_config" "current" {}

# Note: All resources are defined in separate .tf files:
# - resource_group.tf: Resource group
# - logging.tf: Log Analytics workspace
# - network.tf: VNet, Subnets
# - security.tf: NSG, Management locks
# - aks.tf: AKS cluster
# - acr.tf: Container registry and private endpoint
# - iam.tf: Role assignments
# - postgres.tf: PostgreSQL server and databases
# - outputs.tf: Output values

# Use Terraform workspaces or separate tfvars files for dev/prod
# Example: terraform workspace select dev
# Example: terraform apply -var-file="dev.tfvars"
