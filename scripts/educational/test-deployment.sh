#!/usr/bin/env bash

# ============================================
# Automated Health Check Script
# ============================================
# Tests deployed application to ensure it's ready for customers
# Returns exit code 0 if all tests pass, 1 if any fail

set +e  # Don't exit on errors, we want to count them

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

ENVIRONMENT="${1:-dev}"
TESTS_PASSED=0
TESTS_FAILED=0

echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}🔍 AUTOMATED HEALTH CHECK - $ENVIRONMENT${NC}"
echo -e "${CYAN}========================================\n${NC}"

# ============================================
# Test 1: Check if all pods are running
# ============================================
echo -e "${YELLOW}Test 1: Checking pod status...${NC}"

pods_json=$(kubectl get pods -o json 2>/dev/null)
all_pods_ready=true

if [ -n "$pods_json" ]; then
    # Parse JSON and check each pod
    pod_names=$(echo "$pods_json" | jq -r '.items[].metadata.name')
    
    while IFS= read -r pod_name; do
        pod_status=$(echo "$pods_json" | jq -r ".items[] | select(.metadata.name==\"$pod_name\") | .status.phase")
        ready=$(echo "$pods_json" | jq -r ".items[] | select(.metadata.name==\"$pod_name\") | .status.containerStatuses[0].ready")
        restart_count=$(echo "$pods_json" | jq -r ".items[] | select(.metadata.name==\"$pod_name\") | .status.containerStatuses[0].restartCount")
        
        if [ "$pod_status" != "Running" ] || [ "$ready" != "true" ]; then
            echo -e "  ${RED}❌ FAIL: $pod_name is $pod_status (Ready: $ready, Restarts: $restart_count)${NC}"
            all_pods_ready=false
        else
            echo -e "  ${GREEN}✅ PASS: $pod_name is Running (Restarts: $restart_count)${NC}"
        fi
    done <<< "$pod_names"
fi

if [ "$all_pods_ready" = true ]; then
    echo -e "\n${GREEN}✅ Test 1 PASSED: All pods are running\n${NC}"
    ((TESTS_PASSED++))
else
    echo -e "\n${RED}❌ Test 1 FAILED: Some pods are not running\n${NC}"
    ((TESTS_FAILED++))
fi

# ============================================
# Test 2: Check frontend LoadBalancer IP
# ============================================
echo -e "${YELLOW}Test 2: Checking frontend LoadBalancer...${NC}"

frontend_ip=$(kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

if [ -n "$frontend_ip" ]; then
    echo -e "  ${GREEN}✅ PASS: Frontend LoadBalancer IP assigned: $frontend_ip${NC}"
    echo -e "\n${GREEN}✅ Test 2 PASSED: LoadBalancer IP available\n${NC}"
    ((TESTS_PASSED++))
else
    echo -e "  ${RED}❌ FAIL: Frontend LoadBalancer IP not assigned${NC}"
    echo -e "\n${RED}❌ Test 2 FAILED: No LoadBalancer IP\n${NC}"
    ((TESTS_FAILED++))
fi

# ============================================
# Test 3: Check frontend health endpoint
# ============================================
echo -e "${YELLOW}Test 3: Checking frontend health endpoint...${NC}"

if [ -n "$frontend_ip" ]; then
    response_code=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "http://$frontend_ip/health" 2>/dev/null)
    if [ "$response_code" = "200" ]; then
        echo -e "  ${GREEN}✅ PASS: Frontend health endpoint returns 200 OK${NC}"
        echo -e "\n${GREEN}✅ Test 3 PASSED: Frontend is healthy\n${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "  ${RED}❌ FAIL: Frontend health endpoint returned $response_code${NC}"
        echo -e "\n${RED}❌ Test 3 FAILED: Frontend health check failed\n${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "  ${YELLOW}⚠️  SKIP: No LoadBalancer IP available${NC}"
    echo -e "\n${YELLOW}⚠️  Test 3 SKIPPED\n${NC}"
fi

# ============================================
# Test 4: Check backend service health (via port-forward)
# ============================================
echo -e "${YELLOW}Test 4: Checking backend service health...${NC}"

services=("customer-service" "document-service" "account-service" "notification-service")
all_services_healthy=true

for service in "${services[@]}"; do
    # Start port-forward in background
    kubectl port-forward "service/$service" 8080:80 > /dev/null 2>&1 &
    pf_pid=$!
    sleep 3
    
    # Test health endpoint
    health_response=$(curl -s "http://localhost:8080/actuator/health" 2>/dev/null)
    health_status=$(echo "$health_response" | jq -r '.status' 2>/dev/null)
    
    if [ "$health_status" = "UP" ]; then
        echo -e "  ${GREEN}✅ PASS: $service is UP${NC}"
    else
        echo -e "  ${RED}❌ FAIL: $service status is $health_status${NC}"
        all_services_healthy=false
    fi
    
    # Kill port-forward
    kill $pf_pid 2>/dev/null
    wait $pf_pid 2>/dev/null
done

if [ "$all_services_healthy" = true ]; then
    echo -e "\n${GREEN}✅ Test 4 PASSED: All backend services are healthy\n${NC}"
    ((TESTS_PASSED++))
else
    echo -e "\n${RED}❌ Test 4 FAILED: Some backend services are unhealthy\n${NC}"
    ((TESTS_FAILED++))
fi

# ============================================
# Test 5: Check database connectivity from pods
# ============================================
echo -e "${YELLOW}Test 5: Checking database connectivity...${NC}"

pod_name=$(kubectl get pods -l app=customer-service -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$pod_name" ]; then
    db_test=$(kubectl exec "$pod_name" -- sh -c "wget -qO- http://localhost:8081/actuator/health/db 2>/dev/null" 2>/dev/null)
    
    if echo "$db_test" | grep -q "UP"; then
        echo -e "  ${GREEN}✅ PASS: Database connectivity verified from customer-service${NC}"
        echo -e "\n${GREEN}✅ Test 5 PASSED: Database is accessible\n${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "  ${RED}❌ FAIL: Database connectivity failed${NC}"
        echo -e "\n${RED}❌ Test 5 FAILED: Cannot connect to database\n${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "  ${YELLOW}⚠️  SKIP: No customer-service pod found${NC}"
    echo -e "\n${YELLOW}⚠️  Test 5 SKIPPED\n${NC}"
fi

# ============================================
# Test 6: End-to-end smoke test (create customer)
# ============================================
echo -e "${YELLOW}Test 6: Running end-to-end smoke test...${NC}"

if [ -n "$frontend_ip" ]; then
    response_code=$(curl -s -o /dev/null -w "%{http_code}" -m 10 \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"firstName":"Test","lastName":"Customer","email":"test@example.com","phone":"+1-555-0100","dateOfBirth":"1990-01-01"}' \
        "http://$frontend_ip/api/customer/customers" \
        2>/dev/null)
    
    if [ "$response_code" = "200" ] || [ "$response_code" = "201" ]; then
        echo -e "  ${GREEN}✅ PASS: Successfully created test customer${NC}"
        echo -e "\n${GREEN}✅ Test 6 PASSED: End-to-end flow working\n${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "  ${RED}❌ FAIL: Customer creation returned $response_code${NC}"
        echo -e "\n${RED}❌ Test 6 FAILED: End-to-end flow failed\n${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "  ${YELLOW}⚠️  SKIP: No LoadBalancer IP available${NC}"
    echo -e "\n${YELLOW}⚠️  Test 6 SKIPPED\n${NC}"
fi

# ============================================
# Final Summary
# ============================================
echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}📊 TEST SUMMARY${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
echo -e "${CYAN}========================================\n${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED - Application is ready for customers!${NC}"
    echo -e "${CYAN}Frontend URL: http://$frontend_ip\n${NC}"
    exit 0
else
    echo -e "${RED}⚠️  TESTS FAILED - Application is NOT ready!${NC}"
    echo -e "${YELLOW}Please review the errors above and fix before proceeding.\n${NC}"
    exit 1
fi
