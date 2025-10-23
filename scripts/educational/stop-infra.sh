#!/usr/bin/env bash

# ============================================
# Stop Development Infrastructure
# ============================================
# This script stops your AKS cluster and PostgreSQL database
# Cost when stopped: ~$1/month (storage only)
# Saves: ~$48/month!

set -e

# Colors
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🛑 Stopping Development Infrastructure...${NC}"
echo ""

RESOURCE_GROUP="rg-account-opening-dev-eus2"
AKS_NAME="aks-account-opening-dev-eus2"
PG_NAME="psql-account-opening-dev-eus2"

# Check if already stopped
echo -e "${CYAN}📊 Checking current status...${NC}"
aks_state=$(az aks show -g "$RESOURCE_GROUP" -n "$AKS_NAME" --query "powerState.code" -o tsv 2>/dev/null || echo "Unknown")
pg_state=$(az postgres flexible-server show -g "$RESOURCE_GROUP" -n "$PG_NAME" --query "state" -o tsv 2>/dev/null || echo "Unknown")

if [ "$aks_state" = "Stopped" ] && [ "$pg_state" = "Stopped" ]; then
    echo -e "${GREEN}✅ Infrastructure is already stopped!${NC}"
    echo ""
    echo -e "${GREEN}💰 Current cost: ~\$1/month (storage only)${NC}"
    exit 0
fi

# Stop AKS cluster
echo ""
echo -e "${CYAN}☸️  Stopping AKS cluster...${NC}"
echo "   This takes about 1-2 minutes..."
if [ "$aks_state" != "Stopped" ]; then
    az aks stop -g "$RESOURCE_GROUP" -n "$AKS_NAME" --no-wait
fi

# Stop PostgreSQL database
echo ""
echo -e "${CYAN}🗄️  Stopping PostgreSQL database...${NC}"
echo "   This takes about 1-2 minutes..."
if [ "$pg_state" != "Stopped" ]; then
    az postgres flexible-server stop -g "$RESOURCE_GROUP" -n "$PG_NAME" --no-wait
fi

# Wait for both to stop
echo ""
echo -e "${YELLOW}⏳ Waiting for services to stop...${NC}"

max_wait=300  # 5 minutes max
elapsed=0
interval=10

while [ $elapsed -lt $max_wait ]; do
    sleep $interval
    elapsed=$((elapsed + interval))

    aks_state=$(az aks show -g "$RESOURCE_GROUP" -n "$AKS_NAME" --query "powerState.code" -o tsv 2>/dev/null || echo "Unknown")
    pg_state=$(az postgres flexible-server show -g "$RESOURCE_GROUP" -n "$PG_NAME" --query "state" -o tsv 2>/dev/null || echo "Unknown")

    echo -e "${GRAY}   [$elapsed s] AKS: $aks_state | PostgreSQL: $pg_state${NC}"

    if [ "$aks_state" = "Stopped" ] && [ "$pg_state" = "Stopped" ]; then
        break
    fi
done

if [ "$aks_state" = "Stopped" ] && [ "$pg_state" = "Stopped" ]; then
    echo ""
    echo -e "${GREEN}✅ Infrastructure stopped successfully!${NC}"
    echo ""
    echo -e "${CYAN}📊 Status:${NC}"
    echo -e "   ${GRAY}☸️  AKS Cluster: Stopped${NC}"
    echo -e "   ${GRAY}🗄️  PostgreSQL: Stopped${NC}"
    echo ""
    echo -e "${GREEN}💰 Cost Savings:${NC}"
    echo -e "   ${WHITE}• While stopped: ~\$1/month (storage only)${NC}"
    echo -e "   ${GREEN}• Savings: ~\$48/month! 💚${NC}"
    echo ""
    echo -e "${CYAN}✨ Benefits:${NC}"
    echo -e "   ${WHITE}✅ All data is preserved${NC}"
    echo -e "   ${WHITE}✅ Kubernetes configs retained${NC}"
    echo -e "   ${WHITE}✅ Database data safe${NC}"
    echo -e "   ${WHITE}✅ Container images in ACR remain${NC}"
    echo ""
    echo -e "${YELLOW}🚀 To start again, run:${NC}"
    echo -e "   ${CYAN}./start-infra.sh${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠️  Shutdown is taking longer than expected...${NC}"
    echo -e "   ${WHITE}Check status with:${NC}"
    echo -e "   ${GRAY}az aks show -g $RESOURCE_GROUP -n $AKS_NAME --query powerState${NC}"
    echo -e "   ${GRAY}az postgres flexible-server show -g $RESOURCE_GROUP -n $PG_NAME --query state${NC}"
fi
