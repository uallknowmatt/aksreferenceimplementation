# Environment Configurations

This directory contains environment-specific Terraform variable files organized by environment.

## Structure

```
environments/
├── dev/
│   ├── terraform.tfvars    # Development environment variables
│   └── README.md           # Dev environment documentation
├── prod/
│   ├── terraform.tfvars    # Production environment variables
│   └── README.md           # Prod environment documentation
└── README.md               # This file
```

## Environments

### Development (`dev/`)
- **Purpose**: Development and testing
- **Cost**: ~$150-200/month
- **Security**: Lower (public cluster, open access)
- **Resources**: Smaller (2 nodes, 32GB DB)
- **Auto-deployed**: Yes (on push to main)

### Production (`prod/`)
- **Purpose**: Live production workloads
- **Cost**: ~$500-800/month
- **Security**: High (private cluster, restricted access)
- **Resources**: Larger (3-10 nodes, 128GB DB)
- **Auto-deployed**: No (manual approval required)

## Usage

### Local Development

Deploy to dev:
```bash
cd infrastructure
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

Deploy to prod:
```bash
cd infrastructure
terraform init
terraform plan -var-file=environments/prod/terraform.tfvars
# Review carefully!
terraform apply -var-file=environments/prod/terraform.tfvars
```

### GitHub Actions

The workflow automatically uses the correct environment file based on the `ENVIRONMENT` variable:

```yaml
env:
  ENVIRONMENT: dev  # or prod
```

The workflow then references:
```
terraform plan -var-file=environments/${{ env.ENVIRONMENT }}/terraform.tfvars
```

## Adding a New Environment

To add a new environment (e.g., `staging`):

1. Create directory structure:
   ```bash
   mkdir -p environments/staging
   ```

2. Copy an existing tfvars file:
   ```bash
   cp environments/dev/terraform.tfvars environments/staging/terraform.tfvars
   ```

3. Update values in `environments/staging/terraform.tfvars`:
   - Change `environment = "staging"`
   - Adjust resource sizes
   - Use different network CIDRs
   - Update state file key

4. Create a README:
   ```bash
   cp environments/dev/README.md environments/staging/README.md
   ```

5. Update the workflow to support staging environment

## Configuration Guidelines

### Naming Conventions
- Environment names should be lowercase: `dev`, `prod`, `staging`
- Use consistent naming across all environments

### Network CIDRs
Each environment should have isolated network ranges:
- **Dev**: `10.0.0.0/16`
- **Prod**: `10.10.0.0/16`
- **Staging**: `10.20.0.0/16` (if added)

### State Files
Each environment has its own state file:
- **Dev**: `dev.terraform.tfstate`
- **Prod**: `prod.terraform.tfstate`
- Stored in same backend storage account but separate keys

## Security Best Practices

1. **Secrets Management**
   - Never commit passwords or secrets
   - Use Azure Key Vault for production secrets
   - Rotate credentials regularly

2. **Access Control**
   - Limit production access to authorized personnel
   - Use separate service principals for each environment
   - Enable audit logging

3. **Network Security**
   - Use private clusters for production
   - Restrict API server access with authorized IP ranges
   - Implement network segmentation

4. **Change Management**
   - Always review terraform plan before apply
   - Require code review for production changes
   - Use manual approval gates for production deployments

## Troubleshooting

### Wrong environment deployed
If you deployed the wrong environment:
1. Check the `ENVIRONMENT` variable in the workflow
2. Verify the correct tfvars file is being used
3. Use terraform workspace or state file to identify current environment

### Variable not found
If you get "variable not declared" errors:
1. Ensure variable is declared in `variables.tf`
2. Verify tfvars file has correct variable name
3. Check for typos in variable names

### State file conflicts
If state files get mixed up:
1. Check the backend configuration in `main.tf`
2. Verify correct state file key is used
3. Use `terraform state list` to see what's in current state

## References

- [Terraform Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces)
- [Variable Files](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
- [Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
