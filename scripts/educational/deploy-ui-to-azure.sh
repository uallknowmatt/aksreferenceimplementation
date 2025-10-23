#!/usr/bin/env bash

# ============================================
# Deploy the React UI to Azure AKS
# ============================================
# This script builds the frontend Docker image, pushes to ACR, and deploys to AKS

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Default values
RESOURCE_GROUP="${1:-rg-account-opening-dev-eus2}"
ACR_NAME="${2:-acraccountopeningdeveus2}"
AKS_NAME="${3:-aks-account-opening-dev-eus2}"

echo -e "${CYAN}==================================${NC}"
echo -e "${GREEN}Deploying React UI to Azure AKS${NC}"
echo -e "${CYAN}==================================${NC}"
echo ""

# Step 1: Get ACR login server
echo -e "${YELLOW}📦 Getting ACR information...${NC}"
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query loginServer -o tsv)
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to get ACR information${NC}"
    exit 1
fi
echo -e "${GREEN}✅ ACR Login Server: $ACR_LOGIN_SERVER${NC}"
echo ""

# Step 2: Build and push the Docker image
echo -e "${YELLOW}🔨 Building frontend Docker image...${NC}"
IMAGE_TAG=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
IMAGE_NAME="$ACR_LOGIN_SERVER/frontend-ui:$IMAGE_TAG"

cd frontend/account-opening-ui
docker build -t "$IMAGE_NAME" .
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to build Docker image${NC}"
    cd ../..
    exit 1
fi
echo -e "${GREEN}✅ Docker image built successfully${NC}"
echo ""

# Step 3: Login to ACR and push image
echo -e "${YELLOW}📤 Pushing image to ACR...${NC}"
az acr login --name "$ACR_NAME"
docker push "$IMAGE_NAME"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to push image to ACR${NC}"
    cd ../..
    exit 1
fi
echo -e "${GREEN}✅ Image pushed to ACR successfully${NC}"
cd ../..
echo ""

# Step 4: Get AKS credentials
echo -e "${YELLOW}🔐 Getting AKS credentials...${NC}"
az aks get-credentials --name "$AKS_NAME" --resource-group "$RESOURCE_GROUP" --overwrite-existing
echo -e "${GREEN}✅ AKS credentials updated${NC}"
echo ""

# Step 5: Update Kubernetes manifests with image details
echo -e "${YELLOW}📝 Updating Kubernetes manifests...${NC}"
sed "s|<ACR_LOGIN_SERVER>|$ACR_LOGIN_SERVER|g; s|<TAG>|$IMAGE_TAG|g" k8s/frontend-ui-deployment.yaml > k8s/frontend-ui-deployment-temp.yaml

# Step 6: Deploy to AKS
echo -e "${YELLOW}🚀 Deploying to AKS...${NC}"
kubectl apply -f k8s/frontend-ui-deployment-temp.yaml
kubectl apply -f k8s/frontend-ui-service.yaml

# Clean up temp file
rm k8s/frontend-ui-deployment-temp.yaml

echo -e "${GREEN}✅ Deployment completed${NC}"
echo ""

# Step 7: Wait for LoadBalancer IP
echo -e "${YELLOW}⏳ Waiting for LoadBalancer External IP...${NC}"
echo -e "${GRAY}This may take 2-3 minutes...${NC}"
echo ""

max_attempts=60
attempt=0
external_ip=""

while [ $attempt -lt $max_attempts ] && [ -z "$external_ip" ]; do
    attempt=$((attempt + 1))
    external_ip=$(kubectl get svc frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [ -z "$external_ip" ]; then
        echo -e "  ${GRAY}Attempt $attempt/$max_attempts - Still pending...${NC}"
        sleep 5
    fi
done

echo ""
if [ -n "$external_ip" ]; then
    echo -e "${CYAN}==================================${NC}"
    echo -e "${GREEN}✅ DEPLOYMENT SUCCESSFUL!${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo ""
    echo -e "${YELLOW}🌐 Access your application at:${NC}"
    echo -e "   ${WHITE}http://$external_ip${NC}"
    echo ""
    echo -e "${CYAN}📊 Cost Information:${NC}"
    echo -e "   ${YELLOW}LoadBalancer: ~\$20/month${NC}"
    echo -e "   ${YELLOW}Total (with infrastructure): ~\$69/month running${NC}"
    echo -e "   ${YELLOW}With start/stop: ~\$2-3/month average${NC}"
    echo ""
    echo -e "${CYAN}💡 API endpoints are proxied through the UI:${NC}"
    echo -e "   ${WHITE}http://$external_ip/api/customer${NC}"
    echo -e "   ${WHITE}http://$external_ip/api/document${NC}"
    echo -e "   ${WHITE}http://$external_ip/api/account${NC}"
    echo -e "   ${WHITE}http://$external_ip/api/notification${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  LoadBalancer IP not assigned yet${NC}"
    echo -e "${GRAY}Run this command to check status:${NC}"
    echo -e "   ${WHITE}kubectl get svc frontend-ui${NC}"
    echo ""
fi

echo -e "${CYAN}To stop infrastructure and save costs:${NC}"
echo -e "   ${WHITE}./stop-infra.sh${NC}"
echo ""
