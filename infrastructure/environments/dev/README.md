# Development Environment Configuration

This directory contains Terraform variable values for the **development** environment.

## Files

- `terraform.tfvars` - Development environment configuration

## Configuration Details

### Resource Sizing
- **AKS Nodes**: 2 nodes, auto-scaling 1-3
- **VM Size**: Standard_DS2_v2 (2 vCPU, 7 GB RAM)
- **PostgreSQL**: Burstable tier B_Standard_B1ms, 32 GB storage

### Security
- **Cluster Access**: Public (for easier development)
- **API Server**: Open access (no IP restrictions)
- **Network Isolation**: Basic (10.0.0.0/16 VNet)

### Cost
Estimated: ~$150-200/month

### Usage

Deploy to dev:
```bash
cd infrastructure
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

Or via GitHub Actions (automatic):
- Push to `main` branch triggers dev deployment
