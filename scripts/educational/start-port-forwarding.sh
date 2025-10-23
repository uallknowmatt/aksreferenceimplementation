#!/usr/bin/env bash

# ============================================
# Start Port Forwarding for All Microservices
# ============================================
# This allows the React UI to connect to services running in AKS

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Starting port forwarding for all microservices...${NC}"
echo ""

# Function to start port forwarding in a new window
start_port_forward() {
    local service_name=$1
    local local_port=$2
    local remote_port=${3:-80}

    echo -e "${YELLOW}Starting port-forward: $service_name -> localhost:$local_port${NC}"

    # Start in new Git Bash window
    start bash -c "
        echo -e '${CYAN}==================================${NC}'
        echo -e '${GREEN}Port Forwarding: $service_name${NC}'
        echo -e '${YELLOW}Local: http://localhost:$local_port${NC}'
        echo -e '${YELLOW}Remote: $service_name:$remote_port${NC}'
        echo -e '${CYAN}==================================${NC}'
        echo ''
        echo -e '${GRAY}Press Ctrl+C to stop port forwarding${NC}'
        echo ''
        kubectl port-forward svc/$service_name $local_port:$remote_port
        read -p 'Press Enter to close...'
    "
}

# Start port forwarding for each service
start_port_forward "customer-service" 8081
sleep 2

start_port_forward "document-service" 8082
sleep 2

start_port_forward "account-service" 8083
sleep 2

start_port_forward "notification-service" 8084
sleep 2

echo ""
echo -e "${GREEN}✅ All port forwarding sessions started!${NC}"
echo ""
echo -e "${CYAN}Services are now accessible at:${NC}"
echo -e "  ${YELLOW}• Customer Service:     http://localhost:8081${NC}"
echo -e "  ${YELLOW}• Document Service:     http://localhost:8082${NC}"
echo -e "  ${YELLOW}• Account Service:      http://localhost:8083${NC}"
echo -e "  ${YELLOW}• Notification Service: http://localhost:8084${NC}"
echo ""
echo -e "${RED}⚠️  Note: Account Service may not be working (database connection issue)${NC}"
echo ""
echo -e "${CYAN}Now you can start the UI:${NC}"
echo -e "  ${WHITE}cd frontend/account-opening-ui${NC}"
echo -e "  ${WHITE}npm start${NC}"
echo ""
echo -e "${CYAN}Or use the start script:${NC}"
echo -e "  ${WHITE}cd frontend/account-opening-ui${NC}"
echo -e "  ${WHITE}npm start${NC}"
echo ""
echo -e "${GRAY}To stop all port forwarding, close the Bash windows.${NC}"
