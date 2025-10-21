# Infrastructure as Code

This directory contains Terraform configurations for deploying the Account Opening application infrastructure to Azure.

## Structure

```
infrastructure/
├── environments/              # Environment-specific configurations
│   ├── dev/                  # Development environment
│   │   ├── terraform.tfvars  # Dev variables
│   │   └── README.md
│   ├── prod/                 # Production environment
│   │   ├── terraform.tfvars  # Prod variables
│   │   └── README.md
│   └── README.md             # Environment documentation
│
├── aks.tf                    # Azure Kubernetes Service
├── acr.tf                    # Azure Container Registry
├── iam.tf                    # Identity and Access Management
├── locals.tf                 # Local values and computed names
├── logging.tf                # Log Analytics workspace
├── main.tf                   # Provider and backend configuration
├── network.tf                # Virtual Network and Subnets
├── outputs.tf                # Output values
├── postgres.tf               # PostgreSQL Flexible Server
├── resource_group.tf         # Resource Group
├── security.tf               # Network Security Groups
├── variables.tf              # Variable declarations
└── README.md                 # This file
```

## Quick Start

### Prerequisites

1. **Azure CLI** - [Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform** - Version >= 1.6.0 [Install](https://www.terraform.io/downloads)
3. **Azure Subscription** - With appropriate permissions
4. **Service Principal** - For GitHub Actions (with OIDC configured)

### Local Deployment

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Initialize Terraform**:
   ```bash
   cd infrastructure
   terraform init
   ```

3. **Plan deployment** (Development):
   ```bash
   terraform plan -var-file=environments/dev/terraform.tfvars
   ```

4. **Apply changes**:
   ```bash
   terraform apply -var-file=environments/dev/terraform.tfvars
   ```

### GitHub Actions Deployment

The workflow automatically deploys on push to `main`:

1. Creates/validates Terraform state backend
2. Runs `terraform plan` with environment-specific variables
3. Applies changes automatically for dev
4. Requires approval for prod (configure separately)

Configuration:
- Environment: Set via `ENVIRONMENT` variable in workflow (default: `dev`)
- Variables: Loaded from `environments/$ENVIRONMENT/terraform.tfvars`

## Resources Created

### Networking
- **Virtual Network**: Isolated network for all resources
- **Subnets**: Separate subnets for AKS and ACR
- **NSG**: Network security rules for AKS subnet

### Compute
- **AKS Cluster**: Kubernetes cluster for hosting applications
  - System-assigned identity
  - OIDC issuer enabled
  - Workload identity enabled
  - Auto-scaling node pools
- **Container Registry**: Docker image storage (Premium SKU)
  - Private endpoint enabled
  - Admin access disabled (use RBAC)

### Data
- **PostgreSQL Flexible Server**: Managed PostgreSQL
  - 4 databases: customerdb, documentdb, accountdb, notificationdb
  - Azure AD authentication enabled
  - High availability (prod only)

### Monitoring
- **Log Analytics Workspace**: Centralized logging
  - AKS diagnostics enabled
  - 30-day retention

### Identity
- **Workload Identity**: For pod-to-Azure authentication
  - Federated credentials for each service
  - No secrets required!

## Environments

### Development
- **Cost**: ~$150-200/month
- **Resources**: Smaller, cost-optimized
- **Security**: Public cluster for easier access
- **Auto-deploy**: Yes

See [environments/dev/README.md](environments/dev/README.md) for details.

### Production
- **Cost**: ~$500-800/month
- **Resources**: Production-grade sizing
- **Security**: Private cluster, restricted access
- **Auto-deploy**: No (manual approval required)

See [environments/prod/README.md](environments/prod/README.md) for details.

## Configuration

### Variables
All configurable values are declared in `variables.tf` and set in environment-specific tfvars files.

Key variables:
- `environment` - Environment name (dev/prod)
- `location` - Azure region
- `node_count` - Number of AKS nodes
- `vm_size` - VM size for AKS nodes
- `vnet_address_space` - Virtual network CIDR
- `db_admin_password` - PostgreSQL password (use Key Vault in prod!)

### Naming Conventions
Resources follow Azure naming conventions:
- Resource Group: `rg-{project}-{environment}-{region}`
- AKS: `aks-{project}-{environment}-{region}`
- ACR: `acr{project}{environment}{region}` (no hyphens)
- VNet: `vnet-{project}-{environment}-{region}`

Defined in `locals.tf`.

### State Management
Terraform state is stored in Azure Storage:
- **Resource Group**: `terraform-state-rg`
- **Storage Account**: `tfstateaccountopening`
- **Container**: `tfstate`
- **State Files**: 
  - Dev: `dev.terraform.tfstate`
  - Prod: `prod.terraform.tfstate`

See [TERRAFORM_STATE_BACKEND.md](../TERRAFORM_STATE_BACKEND.md) for details.

## Common Tasks

### View current infrastructure
```bash
terraform state list
```

### Show specific resource
```bash
terraform state show azurerm_kubernetes_cluster.aks
```

### Update specific resource
```bash
terraform apply -target=azurerm_kubernetes_cluster.aks -var-file=environments/dev/terraform.tfvars
```

### Destroy environment
```bash
# ⚠️ WARNING: This destroys all resources!
terraform destroy -var-file=environments/dev/terraform.tfvars
```

### Switch environments
```bash
# Just use different tfvars file
terraform plan -var-file=environments/prod/terraform.tfvars
```

## Outputs

After successful deployment, Terraform outputs:
- `aks_cluster_name` - AKS cluster name
- `acr_login_server` - ACR server URL
- `postgres_fqdn` - PostgreSQL server FQDN
- `workload_identity_client_id` - Client ID for pod authentication

View outputs:
```bash
terraform output
terraform output -json > outputs.json
```

## Security

### Secrets Management
- **Development**: Passwords in tfvars (for simplicity)
- **Production**: Use Azure Key Vault
  - Store db_admin_password in Key Vault
  - Reference via data source
  - Never commit secrets to git

### Access Control
- **AKS**: RBAC enabled
- **ACR**: Admin disabled, use managed identities
- **PostgreSQL**: Azure AD authentication preferred
- **Storage**: Private endpoints enabled

### Network Security
- **Production**: Private AKS cluster
- **NSG**: Restricted ingress/egress
- **Service Endpoints**: Enabled where applicable

## Troubleshooting

### "Resource already exists"
Solution: Use remote state backend (already configured)

### "State lock"
If Terraform is stuck:
```bash
# Break the lease (use carefully!)
az storage blob lease break \
  --blob-name dev.terraform.tfstate \
  --container-name tfstate \
  --account-name tfstateaccountopening
```

### "Backend initialization required"
```bash
terraform init -reconfigure
```

### Permission errors
Ensure service principal has:
- `Contributor` role on subscription/resource group
- `Storage Blob Data Contributor` on state storage account

## Best Practices

1. ✅ **Always run `terraform plan` before `apply`**
2. ✅ **Use separate tfvars for each environment**
3. ✅ **Never commit secrets or passwords**
4. ✅ **Use consistent naming conventions**
5. ✅ **Tag all resources appropriately**
6. ✅ **Enable monitoring and logging**
7. ✅ **Use private endpoints in production**
8. ✅ **Implement least-privilege access**
9. ✅ **Review and approve production changes**
10. ✅ **Keep Terraform version consistent**

## References

- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Azure Naming Conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
