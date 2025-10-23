#!/usr/bin/env bash

# ============================================
# Clean Databases for Liquibase Migration Test
# ============================================

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}=== Cleaning Databases for Liquibase Testing ===${NC}"
echo ""

echo -e "${YELLOW}Dropping and recreating databases...${NC}"

# Customer DB
docker exec customer-db psql -U postgres -c "DROP DATABASE IF EXISTS customerdb;"
docker exec customer-db psql -U postgres -c "CREATE DATABASE customerdb;"
echo -e "${GREEN}Customer database cleaned${NC}"

# Document DB
docker exec document-db psql -U postgres -c "DROP DATABASE IF EXISTS documentdb;"
docker exec document-db psql -U postgres -c "CREATE DATABASE documentdb;"
echo -e "${GREEN}Document database cleaned${NC}"

# Account DB
docker exec account-db psql -U postgres -c "DROP DATABASE IF EXISTS accountdb;"
docker exec account-db psql -U postgres -c "CREATE DATABASE accountdb;"
echo -e "${GREEN}Account database cleaned${NC}"

# Notification DB
docker exec notification-db psql -U postgres -c "DROP DATABASE IF EXISTS notificationdb;"
docker exec notification-db psql -U postgres -c "CREATE DATABASE notificationdb;"
echo -e "${GREEN}Notification database cleaned${NC}"

echo ""
echo -e "${CYAN}=== Databases Ready for Liquibase Migrations ===${NC}"
echo -e "${WHITE}You can now start the services to test Liquibase migrations${NC}"
