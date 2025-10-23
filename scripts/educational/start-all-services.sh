#!/usr/bin/env bash

# ============================================
# Backend Build and Start Script
# ============================================
# Run this to rebuild and start all backend services

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
echo -e "${CYAN}Backend Services Build & Start Script${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

services=("customer-service" "document-service" "account-service" "notification-service")
project_root="c:/genaiexperiments/accountopening"

# Check if PostgreSQL is running (via Docker)
echo -e "${YELLOW}Checking PostgreSQL...${NC}"
if docker ps | grep -q postgres; then
    echo -e "${GREEN}✅ PostgreSQL is running (Docker)${NC}"
else
    echo -e "${YELLOW}⚠️  PostgreSQL not found in Docker!${NC}"
    echo -e "${WHITE}Please start Docker containers:${NC}"
    echo -e "${WHITE}  docker-compose up -d${NC}"
    echo ""
    read -p "Press Enter to continue anyway..."
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${YELLOW}Step 1: Building all services...${NC}"
echo ""

cd "$project_root"

echo -e "${GRAY}Running: mvn clean compile -DskipTests${NC}"
mvn clean compile -DskipTests

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
else
    echo -e "${RED}❌ Build failed! Check errors above.${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${YELLOW}Step 2: Starting services in separate windows...${NC}"
echo ""

# Start each service in a new Git Bash window
for service in "${services[@]}"; do
    echo -e "${GRAY}Starting $service...${NC}"

    # Start in new Git Bash window
    start bash -c "cd $project_root/$service && echo -e '\033[0;36mStarting $service...\033[0m' && mvn spring-boot:run; read -p 'Press Enter to close...'"

    sleep 3
done

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✅ All services are starting!${NC}"
echo ""
echo -e "${YELLOW}4 Bash windows have been opened:${NC}"
echo -e "  ${WHITE}- Customer Service (port 8081)${NC}"
echo -e "  ${WHITE}- Document Service (port 8082)${NC}"
echo -e "  ${WHITE}- Account Service (port 8083)${NC}"
echo -e "  ${WHITE}- Notification Service (port 8084)${NC}"
echo ""
echo -e "${YELLOW}Wait for each service to show:${NC}"
echo -e "  ${WHITE}'Started [ServiceName]Application in X seconds'${NC}"
echo ""
echo -e "${CYAN}Then test at: http://localhost:3000${NC}"
echo ""
read -p "Press Enter to close this window..."
