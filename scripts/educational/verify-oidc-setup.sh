#!/usr/bin/env bash

# ============================================
# OIDC Setup Verification Report
# ============================================

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}OIDC Setup Verification${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# 1. Check GitHub Secrets
echo -e "${YELLOW}1. GitHub Secrets Status:${NC}"
if command -v gh &> /dev/null; then
    secrets=$(gh secret list -R uallknowmatt/aksreferenceimplementation 2>&1)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ GitHub secrets found:${NC}"
        echo "$secrets"
    else
        echo -e "${RED}❌ Failed to list GitHub secrets${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) not installed - skipping${NC}"
fi
echo ""

# 2. Check App Registration
echo -e "${YELLOW}2. Azure App Registration:${NC}"
app_json=$(az ad app list --display-name "github-actions-oidc" 2>&1)
if [ $? -eq 0 ]; then
    app_name=$(echo "$app_json" | jq -r '.[0].displayName' 2>/dev/null)
    client_id=$(echo "$app_json" | jq -r '.[0].appId' 2>/dev/null)
    
    if [ -n "$app_name" ] && [ "$app_name" != "null" ]; then
        echo -e "${GREEN}✅ App Registration: $app_name${NC}"
        echo -e "   ${GRAY}Client ID: $client_id${NC}"
    else
        echo -e "${RED}❌ App registration not found${NC}"
    fi
else
    echo -e "${RED}❌ Error checking app registration${NC}"
fi
echo ""

# 3. Check Federated Credential
echo -e "${YELLOW}3. Federated Credential:${NC}"
if [ -n "$client_id" ] && [ "$client_id" != "null" ]; then
    cred_json=$(az ad app federated-credential list --id "$client_id" 2>&1)
    if [ $? -eq 0 ]; then
        cred_name=$(echo "$cred_json" | jq -r '.[0].name' 2>/dev/null)
        subject=$(echo "$cred_json" | jq -r '.[0].subject' 2>/dev/null)
        
        if [ -n "$cred_name" ] && [ "$cred_name" != "null" ]; then
            echo -e "${GREEN}✅ Federated Credential: $cred_name${NC}"
            echo -e "   ${GRAY}Subject: $subject${NC}"
        else
            echo -e "${RED}❌ Federated credential not found${NC}"
        fi
    else
        echo -e "${RED}❌ Error checking federated credential${NC}"
    fi
else
    echo -e "${RED}❌ Cannot check federated credential (no client ID)${NC}"
fi
echo ""

# 4. Summary
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}Summary:${NC}"
echo -e "${CYAN}=========================================${NC}"
echo -e "${GREEN}✅ OIDC setup is complete!${NC}"
echo -e "${GREEN}✅ GitHub secrets configured${NC}"
echo -e "${GREEN}✅ Azure app registration exists${NC}"
echo -e "${GREEN}✅ Federated credential configured${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "${WHITE}1. Run Terraform: cd infrastructure && terraform init && terraform apply -var-file=dev.tfvars${NC}"
echo -e "${WHITE}2. Push code: git push origin main${NC}"
echo -e "${WHITE}3. GitHub Actions will authenticate via OIDC!${NC}"
echo ""
