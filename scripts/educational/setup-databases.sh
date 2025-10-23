#!/usr/bin/env bash

# ============================================
# PostgreSQL Database Setup Script
# ============================================
# Creates all required databases using Docker PostgreSQL

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}PostgreSQL Database Setup${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if Docker is running
echo -e "${YELLOW}Checking Docker...${NC}"
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is running${NC}"
else
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo -e "${YELLOW}Please start Docker Desktop and try again.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Starting PostgreSQL containers...${NC}"
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to start Docker containers!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL containers started!${NC}"
echo ""
echo -e "${YELLOW}Waiting for databases to be ready...${NC}"
sleep 10

# Verify databases
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${YELLOW}Verifying Databases...${NC}"
echo ""

dbs=("customer-db:customerdb" "document-db:documentdb" "account-db:accountdb" "notification-db:notificationdb")

for db_info in "${dbs[@]}"; do
    IFS=':' read -r container dbname <<< "$db_info"

    # Test connection
    if docker exec "$container" psql -U postgres -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw "$dbname"; then
        echo -e "  ${GREEN}✅ $dbname exists in $container${NC}"
    else
        echo -e "  ${RED}❌ $dbname NOT found in $container!${NC}"
    fi
done

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✅ Database Setup Complete!${NC}"
echo ""
echo -e "${YELLOW}Databases created:${NC}"
echo -e "  ${WHITE}- customerdb     (Customer Service) → localhost:5432${NC}"
echo -e "  ${WHITE}- documentdb     (Document Service) → localhost:5433${NC}"
echo -e "  ${WHITE}- accountdb      (Account Service) → localhost:5434${NC}"
echo -e "  ${WHITE}- notificationdb (Notification Service) → localhost:5435${NC}"
echo ""
echo -e "${YELLOW}Connection details:${NC}"
echo -e "  ${WHITE}Host: localhost${NC}"
echo -e "  ${WHITE}Ports: 5432, 5433, 5434, 5435${NC}"
echo -e "  ${WHITE}Username: postgres${NC}"
echo -e "  ${WHITE}Password: postgres${NC}"
echo ""
echo -e "${YELLOW}pgAdmin available at:${NC}"
echo -e "  ${CYAN}http://localhost:5050${NC}"
echo -e "  ${GRAY}Login: admin@accountopening.com / admin${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  ${WHITE}1. Start backend services: ./start-all-services.sh${NC}"
echo -e "  ${WHITE}2. Wait for all services to start${NC}"
echo -e "  ${WHITE}3. Start frontend: cd frontend/account-opening-ui && npm start${NC}"
echo -e "  ${CYAN}4. Test at: http://localhost:3000${NC}"
echo ""
read -p "Press Enter to exit..."
