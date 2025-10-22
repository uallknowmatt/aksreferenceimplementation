#!/bin/bash

# Azure OIDC Setup Script (CLI-only method)
# This script creates a service principal with GitHub OIDC federation
# Run this once, then add the three IDs to GitHub secrets

set -e

echo "=================================================="
echo "Azure OIDC Setup for GitHub Actions"
echo "=================================================="
echo ""

# Configuration
APP_NAME="github-actions-oidc"
GITHUB_ORG="uallknowmatt"
GITHUB_REPO="aksreferenceimplementation"
GITHUB_BRANCH="main"

# 1. Login check
echo "Step 1: Checking Azure login..."
if ! az account show > /dev/null 2>&1; then
  echo "Not logged in. Running 'az login'..."
  az login
else
  echo "✅ Already logged in to Azure"
fi
echo ""

# 2. Get Subscription and Tenant IDs
echo "Step 2: Getting Azure account details..."
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "✅ Subscription ID: $SUBSCRIPTION_ID"
echo "✅ Tenant ID: $TENANT_ID"
echo ""

# 3. Check if app already exists
echo "Step 3: Checking if app registration exists..."
EXISTING_APP_ID=$(az ad app list --display-name "$APP_NAME" --query [0].appId -o tsv)

if [ -z "$EXISTING_APP_ID" ]; then
  echo "Creating new app registration '$APP_NAME'..."
  az ad app create --display-name "$APP_NAME" > /dev/null
  CLIENT_ID=$(az ad app list --display-name "$APP_NAME" --query [0].appId -o tsv)
  echo "✅ Created app registration"
  
  echo "Creating service principal..."
  az ad sp create --id $CLIENT_ID > /dev/null
  echo "✅ Created service principal"
else
  CLIENT_ID=$EXISTING_APP_ID
  echo "✅ App registration already exists (reusing)"
fi
echo "✅ Client ID: $CLIENT_ID"
echo ""

# 4. Create or update federated credential
echo "Step 4: Setting up GitHub OIDC federation..."
CRED_NAME="github-actions-main"
EXISTING_CRED=$(az ad app federated-credential list --id $CLIENT_ID --query "[?name=='$CRED_NAME'].name" -o tsv)

if [ -z "$EXISTING_CRED" ]; then
  echo "Creating federated credential..."
  
  # Create temporary JSON file to avoid shell escaping issues
  TEMP_JSON=$(mktemp)
  cat > $TEMP_JSON <<EOF
{
  "name": "$CRED_NAME",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/$GITHUB_BRANCH",
  "description": "GitHub Actions OIDC for main branch",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF
  
  az ad app federated-credential create --id $CLIENT_ID --parameters "@$TEMP_JSON" > /dev/null
  rm -f $TEMP_JSON
  
  echo "✅ Created federated credential"
else
  echo "✅ Federated credential already exists (reusing)"
fi
echo ""

# 5. Assign Contributor role
echo "Step 5: Assigning Contributor role..."
EXISTING_ROLE=$(az role assignment list --assignee $CLIENT_ID --scope "/subscriptions/$SUBSCRIPTION_ID" --query "[?roleDefinitionName=='Contributor'].roleDefinitionName" -o tsv)

if [ -z "$EXISTING_ROLE" ]; then
  echo "Creating Contributor role assignment..."
  az role assignment create \
    --assignee $CLIENT_ID \
    --role Contributor \
    --scope "/subscriptions/$SUBSCRIPTION_ID" > /dev/null
  echo "✅ Assigned Contributor role"
else
  echo "✅ Contributor role already assigned"
fi

# 5b. Assign User Access Administrator role (needed for Terraform role assignments)
echo "Assigning User Access Administrator role..."
echo "   (This allows Terraform to create role assignments like AKS->ACR pull)"
EXISTING_UAA_ROLE=$(az role assignment list --assignee $CLIENT_ID --scope "/subscriptions/$SUBSCRIPTION_ID" --query "[?roleDefinitionName=='User Access Administrator'].roleDefinitionName" -o tsv)

if [ -z "$EXISTING_UAA_ROLE" ]; then
  echo "Creating User Access Administrator role assignment..."
  az role assignment create \
    --assignee $CLIENT_ID \
    --role "User Access Administrator" \
    --scope "/subscriptions/$SUBSCRIPTION_ID" > /dev/null
  echo "✅ Assigned User Access Administrator role"
else
  echo "✅ User Access Administrator role already assigned"
fi
echo ""

# 6. Display results
echo "=================================================="
echo "✅ OIDC SETUP COMPLETE!"
echo "=================================================="
echo ""

# 7. Add secrets to GitHub automatically (if gh CLI is available)
echo "Step 6: Adding secrets to GitHub..."
if command -v gh > /dev/null 2>&1; then
  echo "GitHub CLI detected! Attempting to add secrets automatically..."
  
  # Check if authenticated
  if gh auth status > /dev/null 2>&1; then
    echo "✅ Authenticated to GitHub"
    
    # Add secrets
    echo "Adding AZURE_CLIENT_ID..."
    echo "$CLIENT_ID" | gh secret set AZURE_CLIENT_ID -R "$GITHUB_ORG/$GITHUB_REPO"
    
    echo "Adding AZURE_TENANT_ID..."
    echo "$TENANT_ID" | gh secret set AZURE_TENANT_ID -R "$GITHUB_ORG/$GITHUB_REPO"
    
    echo "Adding AZURE_SUBSCRIPTION_ID..."
    echo "$SUBSCRIPTION_ID" | gh secret set AZURE_SUBSCRIPTION_ID -R "$GITHUB_ORG/$GITHUB_REPO"
    
    echo ""
    echo "=================================================="
    echo "✅ SECRETS ADDED TO GITHUB AUTOMATICALLY!"
    echo "=================================================="
    echo ""
    echo "Verify at: https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions"
  else
    echo "⚠️  Not authenticated to GitHub CLI"
    echo "Run 'gh auth login' first, then re-run this script"
    echo ""
    echo "OR add these THREE values to GitHub Secrets manually:"
    echo "https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions"
    echo ""
    echo "Secret Name: AZURE_CLIENT_ID"
    echo "Value: $CLIENT_ID"
    echo ""
    echo "Secret Name: AZURE_TENANT_ID"
    echo "Value: $TENANT_ID"
    echo ""
    echo "Secret Name: AZURE_SUBSCRIPTION_ID"
    echo "Value: $SUBSCRIPTION_ID"
    echo ""
  fi
else
  echo "⚠️  GitHub CLI (gh) not installed"
  echo "Install from: https://cli.github.com/"
  echo ""
  echo "OR add these THREE values to GitHub Secrets manually:"
  echo "https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets/actions"
  echo ""
  echo "Secret Name: AZURE_CLIENT_ID"
  echo "Value: $CLIENT_ID"
  echo ""
  echo "Secret Name: AZURE_TENANT_ID"
  echo "Value: $TENANT_ID"
  echo ""
  echo "Secret Name: AZURE_SUBSCRIPTION_ID"
  echo "Value: $SUBSCRIPTION_ID"
  echo ""
fi

echo "=================================================="
echo "Next Steps:"
echo "=================================================="
echo "1. ✅ Azure OIDC configured"
echo "2. ✅ GitHub secrets configured (or add manually above)"
echo "3. Run: cd infrastructure && terraform init"
echo "4. Run: terraform apply -var-file=dev.tfvars"
echo "5. Push code: git push origin main"
echo "6. GitHub Actions will use OIDC (no secrets!) ✅"
echo ""
echo "No rotation needed - tokens auto-expire! 🎉"
echo "=================================================="
