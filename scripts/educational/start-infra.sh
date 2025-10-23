#!/usr/bin/env bash

# ============================================
# Start Development Infrastructure
# ============================================
# This script starts your AKS cluster and PostgreSQL database
# Estimated startup time: ~5 minutes
# Cost while running: ~$0.068/hour

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Development Infrastructure...${NC}"
echo ""

RESOURCE_GROUP="rg-account-opening-dev-eus2"
AKS_NAME="aks-account-opening-dev-eus2"
PG_NAME="psql-account-opening-dev-eus2"

# Check if already running
echo -e "${CYAN}📊 Checking current status...${NC}"
aks_state=$(az aks show -g "$RESOURCE_GROUP" -n "$AKS_NAME" --query "powerState.code" -o tsv 2>/dev/null || echo "Unknown")
pg_state=$(az postgres flexible-server show -g "$RESOURCE_GROUP" -n "$PG_NAME" --query "state" -o tsv 2>/dev/null || echo "Unknown")

if [ "$aks_state" = "Running" ] && [ "$pg_state" = "Ready" ]; then
    echo -e "${GREEN}✅ Infrastructure is already running!${NC}"
    echo ""
    echo -e "${YELLOW}💰 Current cost: ~\$0.068/hour = ~\$1.63/day${NC}"
    exit 0
fi

# Start PostgreSQL first (faster startup)
echo ""
echo -e "${CYAN}🗄️  Starting PostgreSQL database...${NC}"
echo "   This takes about 2 minutes..."
if [ "$pg_state" != "Ready" ]; then
    az postgres flexible-server start -g "$RESOURCE_GROUP" -n "$PG_NAME" --no-wait
fi

# Start AKS cluster
echo ""
echo -e "${CYAN}☸️  Starting AKS cluster...${NC}"
echo "   This takes about 3-5 minutes..."
if [ "$aks_state" != "Running" ]; then
    az aks start -g "$RESOURCE_GROUP" -n "$AKS_NAME" --no-wait
fi

# Wait for both to be ready
echo ""
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"

max_wait=600  # 10 minutes max
elapsed=0
interval=15

while [ $elapsed -lt $max_wait ]; do
    sleep $interval
    elapsed=$((elapsed + interval))

    aks_state=$(az aks show -g "$RESOURCE_GROUP" -n "$AKS_NAME" --query "powerState.code" -o tsv 2>/dev/null || echo "Unknown")
    pg_state=$(az postgres flexible-server show -g "$RESOURCE_GROUP" -n "$PG_NAME" --query "state" -o tsv 2>/dev/null || echo "Unknown")

    echo -e "${GRAY}   [$elapsed s] AKS: $aks_state | PostgreSQL: $pg_state${NC}"

    if [ "$aks_state" = "Running" ] && [ "$pg_state" = "Ready" ]; then
        break
    fi
done

if [ "$aks_state" = "Running" ] && [ "$pg_state" = "Ready" ]; then
    echo ""
    echo -e "${GREEN}✅ Infrastructure started successfully!${NC}"
    echo ""
    echo -e "${CYAN}📊 Status:${NC}"
    echo -e "   ${GREEN}☸️  AKS Cluster: Running${NC}"
    echo -e "   ${GREEN}🗄️  PostgreSQL: Ready${NC}"
    echo ""
    echo -e "${YELLOW}💰 Costs:${NC}"
    echo -e "   ${WHITE}• Per hour: ~\$0.068${NC}"
    echo -e "   ${WHITE}• Per day (24h): ~\$1.63${NC}"
    echo -e "   ${WHITE}• Per month (24/7): ~\$49${NC}"
    echo ""
    echo -e "${YELLOW}💡 Remember to stop when done to save costs!${NC}"
    echo -e "   ${CYAN}Run: ./stop-infra.sh${NC}"
    echo ""

    # Get AKS credentials
    echo -e "${CYAN}🔑 Updating kubectl credentials...${NC}"
    az aks get-credentials -g "$RESOURCE_GROUP" -n "$AKS_NAME" --overwrite-existing

    echo ""
    echo -e "${GREEN}✅ Ready to deploy! Run:${NC}"
    echo -e "   ${WHITE}kubectl get nodes${NC}"
    echo -e "   ${WHITE}kubectl get pods -A${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠️  Startup is taking longer than expected...${NC}"
    echo -e "   ${WHITE}Check status with:${NC}"
    echo -e "   ${GRAY}az aks show -g $RESOURCE_GROUP -n $AKS_NAME --query powerState${NC}"
    echo -e "   ${GRAY}az postgres flexible-server show -g $RESOURCE_GROUP -n $PG_NAME --query state${NC}"
fi
