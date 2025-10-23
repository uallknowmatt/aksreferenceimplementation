#!/usr/bin/env bash

# ============================================
# Complete Local Development Startup Script
# ============================================
# This script starts PostgreSQL databases via Docker, then starts all backend services

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
echo -e "${CYAN}Local Development Environment Startup${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

project_root="c:/genaiexperiments/accountopening"
cd "$project_root"

# Check if Docker is running
echo -e "${YELLOW}Step 1: Checking Docker...${NC}"
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is running${NC}"
else
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo -e "${YELLOW}Please start Docker Desktop and try again.${NC}"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 2: Starting PostgreSQL databases...${NC}"
echo -e "${GRAY}Running: docker-compose up -d${NC}"
docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ PostgreSQL containers started!${NC}"
else
    echo -e "${RED}❌ Failed to start Docker containers!${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 3: Waiting for databases to be ready...${NC}"
sleep 10

# Check database health
echo -e "${GRAY}Checking database health...${NC}"
healthy=true
dbs=("customer-db" "document-db" "account-db" "notification-db")

for db in "${dbs[@]}"; do
    health=$(docker inspect --format='{{.State.Health.Status}}' "$db" 2>/dev/null || echo "unknown")
    if [ "$health" = "healthy" ] || [ "$health" = "" ]; then
        echo -e "  ${GREEN}✅ $db is ready${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $db status: $health${NC}"
        healthy=false
    fi
done

if [ "$healthy" = false ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Some databases are still starting up...${NC}"
    echo -e "${GRAY}Waiting 15 more seconds...${NC}"
    sleep 15
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${YELLOW}Step 4: Building backend services...${NC}"
echo ""

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
echo -e "${YELLOW}Step 5: Starting microservices...${NC}"
echo ""

services=("customer-service" "document-service" "account-service" "notification-service")

for service in "${services[@]}"; do
    echo -e "${GRAY}Starting $service...${NC}"
    start bash -c "cd $project_root/$service && echo -e '\033[0;36mStarting $service...\033[0m' && mvn spring-boot:run; read -p 'Press Enter to close...'"
    sleep 3
done

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✅ Environment is starting up!${NC}"
echo ""
echo -e "${YELLOW}Docker PostgreSQL Databases:${NC}"
echo -e "  ${WHITE}- customer-db     → localhost:5432${NC}"
echo -e "  ${WHITE}- document-db     → localhost:5433${NC}"
echo -e "  ${WHITE}- account-db      → localhost:5434${NC}"
echo -e "  ${WHITE}- notification-db → localhost:5435${NC}"
echo -e "  ${CYAN}- pgAdmin         → http://localhost:5050${NC}"
echo -e "${GRAY}    (Login: admin@accountopening.com / admin)${NC}"
echo ""
echo -e "${YELLOW}Microservices (starting in separate windows):${NC}"
echo -e "  ${WHITE}- Customer Service     → localhost:8081${NC}"
echo -e "  ${WHITE}- Document Service     → localhost:8082${NC}"
echo -e "  ${WHITE}- Account Service      → localhost:8083${NC}"
echo -e "  ${WHITE}- Notification Service → localhost:8084${NC}"
echo ""
echo -e "${YELLOW}Wait for each service to show:${NC}"
echo -e "  ${WHITE}'Started [ServiceName]Application in X seconds'${NC}"
echo ""
echo -e "${YELLOW}Then start the frontend:${NC}"
echo -e "  ${WHITE}cd frontend/account-opening-ui${NC}"
echo -e "  ${WHITE}npm start${NC}"
echo ""
echo -e "${YELLOW}To stop everything:${NC}"
echo -e "  ${WHITE}1. Close all service windows (Ctrl+C)${NC}"
echo -e "  ${WHITE}2. Run: docker-compose down${NC}"
echo ""
read -p "Press Enter to close this window..."
