#!/usr/bin/env bash

# ============================================
# Bootstrap Script - Quick Setup
# ============================================
# Run this ONCE to create the initial AZURE_CREDENTIALS for GitHub

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Starting Bootstrap Process...${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

# Check Azure CLI
if command -v az &> /dev/null; then
    echo -e "${GREEN}✅ Azure CLI installed${NC}"
else
    echo -e "${RED}❌ Azure CLI not found. Install from: https://aka.ms/InstallAzureCLIDirect${NC}"
    exit 1
fi

# Check Terraform
if command -v terraform &> /dev/null; then
    echo -e "${GREEN}✅ Terraform installed${NC}"
else
    echo -e "${RED}❌ Terraform not found. Install from: https://www.terraform.io/downloads${NC}"
    exit 1
fi

echo ""

# Azure Login
echo -e "${YELLOW}🔐 Checking Azure login...${NC}"
account_info=$(az account show 2>/dev/null || echo "")

if [ -z "$account_info" ]; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure. Running 'az login'...${NC}"
    az login
    account_info=$(az account show)
fi

subscription_name=$(echo "$account_info" | jq -r '.name')
subscription_id=$(echo "$account_info" | jq -r '.id')
tenant_id=$(echo "$account_info" | jq -r '.tenantId')

echo -e "${GREEN}✅ Logged in to Azure${NC}"
echo -e "   ${CYAN}Subscription: $subscription_name${NC}"
echo -e "   ${CYAN}Subscription ID: $subscription_id${NC}"
echo ""

# Confirm subscription
read -p "Is this the correct subscription? (y/n) " confirmation
if [ "$confirmation" != "y" ]; then
    echo -e "${RED}❌ Please set the correct subscription with: az account set --subscription <subscription-id>${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}📝 OPTION 1: Use Your Azure Login (Recommended)${NC}"
echo -e "${GRAY}   - Simplest approach${NC}"
echo -e "${GRAY}   - Uses your current Azure CLI login${NC}"
echo -e "${GRAY}   - No service principal creation needed${NC}"
echo ""
echo -e "${CYAN}📝 OPTION 2: Create Bootstrap Service Principal${NC}"
echo -e "${GRAY}   - Creates temporary service principal${NC}"
echo -e "${GRAY}   - Can be deleted after bootstrap${NC}"
echo -e "${GRAY}   - More isolated permissions${NC}"
echo ""

read -p "Choose option (1 or 2) " option

if [ "$option" = "2" ]; then
    # Create bootstrap service principal
    echo ""
    echo -e "${YELLOW}🔧 Creating bootstrap service principal...${NC}"

    sp_name="terraform-bootstrap-sp-$(date +%Y%m%d-%H%M%S)"

    sp_json=$(az ad sp create-for-rbac \
        --name "$sp_name" \
        --role "Contributor" \
        --scopes "/subscriptions/$subscription_id" \
        2>&1)

    if [ $? -eq 0 ]; then
        app_id=$(echo "$sp_json" | jq -r '.appId')
        password=$(echo "$sp_json" | jq -r '.password')

        echo -e "${GREEN}✅ Bootstrap service principal created${NC}"
        echo -e "   ${CYAN}App ID: $app_id${NC}"
        echo ""

        # Set environment variables
        echo -e "${YELLOW}🔐 Setting environment variables for Terraform...${NC}"
        export ARM_CLIENT_ID="$app_id"
        export ARM_CLIENT_SECRET="$password"
        export ARM_SUBSCRIPTION_ID="$subscription_id"
        export ARM_TENANT_ID="$tenant_id"

        echo -e "${GREEN}✅ Environment variables set${NC}"
        echo ""

        # Grant User Access Administrator
        echo -e "${YELLOW}🔧 Granting User Access Administrator role...${NC}"
        az role assignment create \
            --assignee "$app_id" \
            --role "User Access Administrator" \
            --scope "/subscriptions/$subscription_id" \
            --output none 2>/dev/null

        echo -e "${GREEN}✅ Additional permissions granted${NC}"
        echo ""

        # Wait for propagation
        echo -e "${YELLOW}⏳ Waiting 30 seconds for role assignments to propagate...${NC}"
        sleep 30
    else
        echo -e "${RED}❌ Failed to create service principal${NC}"
        echo -e "${YELLOW}   Try Option 1 instead (use your Azure login)${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${GREEN}✅ Using your Azure CLI login for Terraform${NC}"
    echo -e "${GRAY}   (No bootstrap service principal needed)${NC}"
    echo ""
fi

# Run Terraform
echo -e "${YELLOW}🏗️  Running Terraform to create infrastructure...${NC}"
echo -e "${GRAY}   This will take 10-15 minutes. Get some coffee! ☕${NC}"
echo ""

cd infrastructure

# Initialize Terraform
echo -e "${GRAY}   → terraform init${NC}"
terraform init
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform init failed${NC}"
    exit 1
fi

# Apply Terraform
echo ""
echo -e "${GRAY}   → terraform apply -var-file=dev.tfvars${NC}"
echo ""
terraform apply -var-file=dev.tfvars -auto-approve

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform apply failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Infrastructure created successfully!${NC}"
echo ""

# Get the GitHub Actions credentials
echo -e "${YELLOW}🔑 Getting GitHub Actions credentials...${NC}"
echo ""

azure_credentials=$(terraform output -raw azure_credentials_json)

echo -e "${GREEN}✅ Service principal credentials retrieved!${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📋 COPY THIS JSON TO GITHUB SECRETS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}$azure_credentials${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Save to file for convenience
credentials_file="azure_credentials.json"
echo "$azure_credentials" > "$credentials_file"
echo -e "${CYAN}💾 Credentials also saved to: $credentials_file${NC}"
echo ""

# Instructions
echo -e "${YELLOW}📖 NEXT STEPS:${NC}"
echo ""
echo -e "${WHITE}1. Go to: https://github.com/uallknowmatt/aksreferenceimplementation/settings/secrets/actions${NC}"
echo -e "${WHITE}2. Click 'New repository secret'${NC}"
echo -e "${WHITE}3. Name: AZURE_CREDENTIALS${NC}"
echo -e "${WHITE}4. Value: Paste the JSON above${NC}"
echo -e "${WHITE}5. Click 'Add secret'${NC}"
echo ""
echo -e "${GREEN}✨ That's it! Only 1 secret to configure!${NC}"
echo ""

# Show summary
echo -e "${YELLOW}📊 Infrastructure Summary:${NC}"
terraform output github_secrets_summary

echo ""

# Cleanup option
if [ "$option" = "2" ]; then
    echo -e "${YELLOW}🧹 CLEANUP (Optional):${NC}"
    echo -e "${GRAY}   The bootstrap service principal is no longer needed.${NC}"
    echo -e "${GRAY}   To delete it, run:${NC}"
    echo -e "${WHITE}   az ad sp delete --id $app_id${NC}"
    echo ""
fi
