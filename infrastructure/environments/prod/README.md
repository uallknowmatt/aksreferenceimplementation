# Production Environment Configuration

This directory contains Terraform variable values for the **production** environment.

## Files

- `terraform.tfvars` - Production environment configuration

## Configuration Details

### Resource Sizing
- **AKS Nodes**: 3 nodes, auto-scaling 3-10
- **VM Size**: Standard_D4s_v3 (4 vCPU, 16 GB RAM)
- **PostgreSQL**: General Purpose tier GP_Standard_D4s_v3, 128 GB storage

### Security
- **Cluster Access**: Private (secure internal access only)
- **API Server**: Restricted (configure authorized IPs)
- **Network Isolation**: Complete (10.10.0.0/16 VNet, separate from dev)

### Cost
Estimated: ~$500-800/month (depending on usage)

### Usage

⚠️ **WARNING**: Production deployment requires careful review!

Deploy to prod:
```bash
cd infrastructure
terraform init
terraform plan -var-file=environments/prod/terraform.tfvars
# Review the plan carefully!
terraform apply -var-file=environments/prod/terraform.tfvars
```

Or via GitHub Actions:
- Create a separate production workflow
- Require manual approval
- Use prod.tfvars

## Security Checklist

Before deploying to production:

- [ ] Change `db_admin_password` to a secure value (use Azure Key Vault)
- [ ] Configure `api_server_authorized_ip_ranges` with your IP ranges
- [ ] Review all resource sizes and costs
- [ ] Enable Azure Monitor and alerts
- [ ] Configure backup policies
- [ ] Set up disaster recovery plan
- [ ] Review network security rules
- [ ] Enable Azure Policy for compliance
- [ ] Configure RBAC and access controls
- [ ] Set up Azure Key Vault for secrets
