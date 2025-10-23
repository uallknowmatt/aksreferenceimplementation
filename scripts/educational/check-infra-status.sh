#!/usr/bin/env bash

# ============================================
# Check Infrastructure Status
# ============================================
# This script displays the current status and costs of your infrastructure

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
RED='\033[0;31m'
NC='\033[0m' # No Color

RESOURCE_GROUP="rg-account-opening-dev-eus2"
AKS_NAME="aks-account-opening-dev-eus2"
PG_NAME="psql-account-opening-dev-eus2"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Infrastructure Status Report${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Get AKS status
echo -e "${YELLOW}Querying Azure resources...${NC}"
aks_state=$(az aks show -g "$RESOURCE_GROUP" -n "$AKS_NAME" --query "powerState.code" -o tsv 2>/dev/null || echo "Unknown")
pg_state=$(az postgres flexible-server show -g "$RESOURCE_GROUP" -n "$PG_NAME" --query "state" -o tsv 2>/dev/null || echo "Unknown")

echo ""
echo -e "${CYAN}📊 Current Status:${NC}"
echo ""

# Display AKS status
if [ "$aks_state" = "Running" ]; then
    echo -e "   ${GREEN}☸️  AKS Cluster: RUNNING ✅${NC}"
else
    echo -e "   ${GRAY}☸️  AKS Cluster: STOPPED ⏸️${NC}"
fi

# Display PostgreSQL status
if [ "$pg_state" = "Ready" ]; then
    echo -e "   ${GREEN}🗄️  PostgreSQL: READY ✅${NC}"
else
    echo -e "   ${GRAY}🗄️  PostgreSQL: STOPPED ⏸️${NC}"
fi

# Calculate costs
echo ""
echo -e "${CYAN}� Cost Breakdown:${NC}"
echo ""

aks_cost=0
pg_cost=0

if [ "$aks_state" = "Running" ]; then
    aks_cost=37  # ~$37/month when running
    echo -e "   ${WHITE}AKS Cluster (Running):${NC}"
    echo -e "      ${YELLOW}• ~\$0.051/hour${NC}"
    echo -e "      ${YELLOW}• ~\$37/month (if running 24/7)${NC}"
else
    echo -e "   ${GRAY}AKS Cluster (Stopped): \$0${NC}"
fi

echo ""

if [ "$pg_state" = "Ready" ]; then
    pg_cost=12  # ~$12/month when running
    echo -e "   ${WHITE}PostgreSQL (Running):${NC}"
    echo -e "      ${YELLOW}• ~\$0.017/hour${NC}"
    echo -e "      ${YELLOW}• ~\$12/month (if running 24/7)${NC}"
else
    echo -e "   ${GRAY}PostgreSQL (Stopped): ~\$0.50/month (storage)${NC}"
fi

total_cost=$((aks_cost + pg_cost))

echo ""
echo -e "${CYAN}========================================${NC}"
if [ $total_cost -gt 0 ]; then
    echo -e "${YELLOW}💵 Current Monthly Cost: ~\$$total_cost${NC}"
else
    echo -e "${GREEN}💵 Current Monthly Cost: ~\$1 (storage only) 💚${NC}"
fi
echo -e "${CYAN}========================================${NC}"

# Additional cluster info if running
if [ "$aks_state" = "Running" ]; then
    echo ""
    echo -e "${CYAN}🔍 Cluster Details:${NC}"

    node_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    if [ "$node_count" -gt 0 ]; then
        echo -e "   ${WHITE}Nodes: $node_count${NC}"

        pod_count=$(kubectl get pods -A --no-headers 2>/dev/null | wc -l)
        echo -e "   ${WHITE}Total Pods: $pod_count${NC}"

        echo ""
        echo -e "${GRAY}Recent pods:${NC}"
        kubectl get pods -A --sort-by=.metadata.creationTimestamp | tail -n 5
    else
        echo -e "   ${GRAY}Unable to query cluster (check kubectl connection)${NC}"
    fi
fi

# Quick actions
echo ""
echo -e "${CYAN}🚀 Quick Actions:${NC}"
echo ""

if [ "$aks_state" = "Running" ] || [ "$pg_state" = "Ready" ]; then
    echo -e "${YELLOW}To stop and save \$48/month:${NC}"
    echo -e "   ${CYAN}./stop-infra.sh${NC}"
else
    echo -e "${YELLOW}To start infrastructure (~5 min):${NC}"
    echo -e "   ${CYAN}./start-infra.sh${NC}"
fi

echo ""
echo -e "${GRAY}Check status anytime:${NC}"
echo -e "   ${GRAY}./check-infra-status.sh${NC}"
echo ""
