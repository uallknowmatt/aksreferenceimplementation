#!/usr/bin/env bash

# ============================================
# Service Health Check Script
# ============================================
# Run this AFTER starting all backend services to verify they're working

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Backend Services Health Check${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Service definitions
declare -A services
services[customer]="8081 http://localhost:8081/api/customers"
services[document]="8082 http://localhost:8082/api/documents"
services[account]="8083 http://localhost:8083/api/accounts"
services[notification]="8084 http://localhost:8084/api/notifications"

echo -e "${YELLOW}Checking if services are running...${NC}"
echo ""

all_good=true

for service_name in customer document account notification; do
    IFS=' ' read -r port url <<< "${services[$service_name]}"

    echo -e "${GRAY}Testing ${service_name^} Service on port ${port}...${NC}"

    if response=$(curl -s -m 5 "$url" 2>/dev/null); then
        echo -e "  ${GREEN}✅ ${service_name^} Service is UP and responding${NC}"
        # Truncate response to 100 chars
        short_response=$(echo "$response" | cut -c1-100)
        echo -e "${GRAY}     Response: ${short_response}${NC}"
    else
        all_good=false
        status_code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$url" 2>/dev/null || echo "000")

        if [ "$status_code" = "000" ]; then
            echo -e "  ${RED}❌ ${service_name^} Service is NOT running on port ${port}${NC}"
            echo -e "${YELLOW}     Make sure the service is started${NC}"
        elif [ "$status_code" = "404" ]; then
            echo -e "  ${YELLOW}⚠️  ${service_name^} Service is running but endpoint returned 404${NC}"
            echo -e "${GRAY}     This might be normal if the endpoint doesn't exist yet${NC}"
        else
            echo -e "  ${RED}❌ ${service_name^} Service returned an error (HTTP $status_code)${NC}"
        fi
    fi
    echo ""
done

echo -e "${CYAN}========================================${NC}"

if [ "$all_good" = true ]; then
    echo -e "${GREEN}✅ ALL SERVICES ARE WORKING!${NC}"
    echo ""
    echo -e "${YELLOW}You can now test the UI at:${NC}"
    echo -e "  ${CYAN}http://localhost:3000${NC}"
else
    echo -e "${YELLOW}⚠️  Some services are not responding${NC}"
    echo ""
    echo -e "${YELLOW}Make sure all services are started:${NC}"
    echo "  1. Run: ./start-all-services.sh"
    echo "  2. Wait for 'Started...Application' in each window"
    echo "  3. Run this script again"
fi

echo ""
