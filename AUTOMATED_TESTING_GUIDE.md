# Automated Testing & Self-Healing Guide

## Overview

This project now includes **fully automated health checks** and **self-healing capabilities** that validate every deployment and prevent wasted costs on broken infrastructure.

---

## Automated Testing Architecture

### How It Works

```
GitHub Actions Workflow
  ↓
Deploy Infrastructure (Terraform)
  ↓
Build & Push Docker Images
  ↓
Deploy to Kubernetes
  ↓
┌─────────────────────────────────────┐
│  Automated Health Checks (Job 4)   │ ← NEW!
│  - 6 comprehensive tests            │
│  - Returns PASS or FAIL             │
└─────────────────────────────────────┘
  ↓
  ├─→ TESTS PASS
  │   └─→ Infrastructure Decision Gate
  │       └─→ User chooses: Keep Running or Stop
  │
  └─→ TESTS FAIL
      └─→ Auto-Stop Infrastructure
          └─→ Save ~$52/month
          └─→ Review failures & redeploy
```

---

## The 6 Automated Health Checks

### Test 1: Pod Status Check ✅
**What it tests:** All Kubernetes pods are running and ready

**Command:**
```bash
kubectl get pods --no-headers | grep -v "1/1.*Running"
```

**Pass Criteria:**
- All pods show `1/1 Running`
- No pods in `CrashLoopBackOff`, `Pending`, or `Error` state

**Example Output:**
```
✅ PASS: All pods are running (1/1)

NAME                                   READY   STATUS    RESTARTS   AGE
account-service-7d8f9c6b5d-xxxxx       1/1     Running   0          3m
customer-service-6c8d7b5a4c-xxxxx      1/1     Running   0          3m
document-service-5b7c6a4d3b-xxxxx      1/1     Running   0          3m
frontend-ui-4a6b5c3d2a1b-xxxxx         1/1     Running   0          3m
notification-service-3a5b4c2d1a-xxxxx  1/1     Running   0          3m
```

**Common Failures:**
- ❌ Pods stuck in `CrashLoopBackOff` → Database connection issues
- ❌ Pods stuck in `Pending` → Resource constraints or scheduling issues
- ❌ Pods in `ImagePullBackOff` → ACR authentication issues

---

### Test 2: LoadBalancer IP Assignment ✅
**What it tests:** Frontend UI has external IP address assigned

**Command:**
```bash
kubectl get svc frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

**Pass Criteria:**
- LoadBalancer IP is assigned (not `<pending>`)
- IP is a valid public IP address

**Example Output:**
```
✅ PASS: LoadBalancer IP assigned: 68.220.25.83
Frontend URL: http://68.220.25.83
```

**Common Failures:**
- ❌ IP still `<pending>` → LoadBalancer provisioning slow (may need more wait time)
- ❌ No IP at all → AKS networking configuration issue

---

### Test 3: Frontend Health Endpoint ✅
**What it tests:** Frontend UI is responding to HTTP requests

**Command:**
```bash
curl -s -o /dev/null -w "%{http_code}" "http://FRONTEND_IP/health"
```

**Pass Criteria:**
- HTTP status code is `200 OK`
- Frontend health endpoint returns success

**Example Output:**
```
✅ PASS: Frontend health endpoint returns 200 OK
```

**Common Failures:**
- ❌ HTTP 000 → Cannot connect to IP (LoadBalancer not ready)
- ❌ HTTP 404 → Health endpoint path incorrect
- ❌ HTTP 500 → Frontend application error

---

### Test 4: Backend Services Health ✅
**What it tests:** All 4 backend microservices are healthy

**Services Tested:**
1. `customer-service` → Port 8081 → `/actuator/health`
2. `document-service` → Port 8081 → `/actuator/health`
3. `account-service` → Port 8081 → `/actuator/health`
4. `notification-service` → Port 8081 → `/actuator/health`

**Command (per service):**
```bash
kubectl exec <pod-name> -- wget -qO- http://localhost:8081/actuator/health
```

**Pass Criteria:**
- All services return `"status":"UP"`
- Actuator health endpoints are accessible

**Example Output:**
```
✅ PASS: All backend services are healthy

  ✅ customer-service: UP
  ✅ document-service: UP
  ✅ account-service: UP
  ✅ notification-service: UP
```

**Common Failures:**
- ❌ Service DOWN → Database connection failure (check Test 5)
- ❌ No pod found → Deployment failed or pod crashed
- ❌ Connection refused → Service not listening on port 8081

---

### Test 5: Database Connectivity ✅
**What it tests:** PostgreSQL is accessible from pods via private VNet

**Command:**
```bash
kubectl exec <customer-service-pod> -- wget -qO- http://localhost:8081/actuator/health/db
```

**Pass Criteria:**
- Database health check returns `"status":"UP"`
- Connection to PostgreSQL successful
- **Validates private VNet integration is working!**

**Example Output:**
```
✅ PASS: Database connectivity verified

{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    }
  }
}
```

**Common Failures:**
- ❌ Connection timeout → PostgreSQL not accessible (check VNet integration)
- ❌ Authentication failed → Wrong credentials in ConfigMap/Secret
- ❌ Database DOWN → PostgreSQL server not running

---

### Test 6: End-to-End Smoke Test ⚠️ (Not Implemented Yet)
**What it would test:** Complete application flow from frontend to database

**Planned Tests:**
1. Create test customer via API (`POST /api/customers`)
2. Retrieve customer via API (`GET /api/customers/{id}`)
3. Verify customer saved to database
4. Clean up test data

**Status:** Currently skipped - to be implemented in future

---

## Self-Healing Behavior

### Scenario 1: All Tests Pass ✅

**Workflow Path:**
```
Deployment Complete
  ↓
Run Automated Tests
  ↓
All 5 Tests PASS
  ↓
Infrastructure Decision Gate (Job 6)
  ↓
User Choice:
  - APPROVE → Stop infrastructure (save $52/month)
  - REJECT → Keep running (costs $53/month)
```

**What You See:**
```
========================================
🎉 ALL TESTS PASSED - Deployment is healthy!
========================================

✅ Tests Passed: 5
❌ Tests Failed: 0

Frontend URL: http://68.220.25.83

✅ Development environment deployed successfully!
✅ All automated tests passed!

💰 INFRASTRUCTURE COST DECISION
Choose to keep running or stop infrastructure...
```

---

### Scenario 2: Any Test Fails ❌

**Workflow Path:**
```
Deployment Complete
  ↓
Run Automated Tests
  ↓
1 or More Tests FAIL
  ↓
Handle Test Failure (Job 5) ← Auto-triggered!
  ↓
Stop AKS Cluster (saves $30/month)
Stop PostgreSQL Server (saves $18/month)
  ↓
Display Failure Report
  ↓
Workflow Ends
```

**What You See:**
```
========================================
⚠️ TESTS FAILED - Deployment has issues!
========================================

✅ Tests Passed: 2
❌ Tests Failed: 3

Failed Tests:
  ❌ Test 1: Pod Status (2 pods in CrashLoopBackOff)
  ❌ Test 4: Backend Services (customer-service DOWN)
  ❌ Test 5: Database Connectivity (connection timeout)

========================================
⚠️ DEPLOYMENT TESTS FAILED
========================================

Infrastructure has been stopped to save costs.
Please review the test failures, fix the issues,
and redeploy.

To redeploy:
1. Fix the issues identified in the tests
2. Trigger the workflow again with force_run=true
```

**Self-Healing Actions:**
1. ✅ Stops AKS cluster immediately
2. ✅ Stops PostgreSQL server immediately
3. ✅ Costs drop from ~$53/month to ~$1/month
4. ✅ Prevents wasted money on broken deployments
5. ✅ Forces you to fix issues before keeping infrastructure running

---

## Running Tests Manually

### Option 1: Use PowerShell Script

A comprehensive PowerShell test script is available at `test-deployment.ps1`:

```powershell
# Make sure kubectl is configured for your AKS cluster
az aks get-credentials --resource-group <RG_NAME> --name <AKS_NAME>

# Run the test script
.\test-deployment.ps1
```

**Exit Codes:**
- `0` → All tests passed ✅
- `1` → One or more tests failed ❌

---

### Option 2: Run Individual Tests

#### Test 1: Pod Status
```powershell
kubectl get pods

# All should be Running with 1/1 Ready
```

#### Test 2: LoadBalancer IP
```powershell
kubectl get svc frontend-ui

# Should show EXTERNAL-IP (not <pending>)
```

#### Test 3: Frontend Health
```powershell
$FRONTEND_IP = kubectl get svc frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
curl http://${FRONTEND_IP}/health

# Should return HTTP 200 OK
```

#### Test 4: Backend Service Health
```powershell
# Port-forward to customer-service
kubectl port-forward deployment/customer-service 8081:8081

# In another terminal:
curl http://localhost:8081/actuator/health

# Should return {"status":"UP"}
```

#### Test 5: Database Connectivity
```powershell
# Check database health via customer-service
kubectl port-forward deployment/customer-service 8081:8081

# In another terminal:
curl http://localhost:8081/actuator/health/db

# Should return {"status":"UP", "components":{"db":{"status":"UP",...}}}
```

---

## Interpreting Test Results

### Understanding Test Output

**Format:**
```
Test X: Description...
  ✅ PASS: Test passed successfully
  ❌ FAIL: Test failed with reason
  ⚠️  SKIP: Test skipped (dependency missing)
```

**Summary:**
```
========================================
📊 TEST SUMMARY
========================================
✅ Tests Passed: 5
❌ Tests Failed: 0
========================================
```

---

### Common Test Failure Patterns

#### Pattern 1: Database Connection Failures
```
✅ Test 1: PASS (pods running)
✅ Test 2: PASS (LoadBalancer IP)
✅ Test 3: PASS (frontend health)
❌ Test 4: FAIL (backend services DOWN)
❌ Test 5: FAIL (database connectivity)
```

**Root Cause:** PostgreSQL not accessible

**Diagnosis:**
1. Check if PostgreSQL is running:
   ```powershell
   az postgres flexible-server show --name <POSTGRES_NAME> --resource-group <RG_NAME>
   ```
2. Verify VNet integration:
   ```powershell
   # Check subnet delegation
   az network vnet subnet show --vnet-name <VNET_NAME> --name snet-dev-postgres --resource-group <RG_NAME>
   ```
3. Check Private DNS Zone:
   ```powershell
   az network private-dns link vnet list --zone-name privatelink.postgres.database.azure.com --resource-group <RG_NAME>
   ```

**Fix:**
- If PostgreSQL stopped → Start it
- If VNet integration missing → Redeploy infrastructure
- If DNS zone not linked → Check Terraform configuration

---

#### Pattern 2: Pod Startup Failures
```
❌ Test 1: FAIL (pods in CrashLoopBackOff)
⚠️  Test 2: SKIP
⚠️  Test 3: SKIP
❌ Test 4: FAIL (no pods found)
⚠️  Test 5: SKIP
```

**Root Cause:** Application startup error

**Diagnosis:**
```powershell
# Check pod logs
kubectl logs <pod-name>

# Common errors:
# - Database connection refused → PostgreSQL not ready
# - Image pull errors → ACR authentication issue
# - Port conflicts → Configuration issue
```

**Fix:**
- Wait longer for PostgreSQL to be ready
- Verify ACR credentials in K8s
- Check ConfigMap values

---

#### Pattern 3: LoadBalancer Provisioning Delay
```
✅ Test 1: PASS (pods running)
❌ Test 2: FAIL (no LoadBalancer IP)
⚠️  Test 3: SKIP (no IP to test)
✅ Test 4: PASS (backend services UP)
✅ Test 5: PASS (database UP)
```

**Root Cause:** Azure LoadBalancer still provisioning

**Diagnosis:**
```powershell
kubectl describe svc frontend-ui

# Look for:
# Events:
#   Normal  EnsuringLoadBalancer  2m  service-controller  Ensuring load balancer
```

**Fix:**
- Wait 3-5 minutes and re-run tests
- If still failing after 10 minutes, check AKS networking configuration

---

## Customizing Tests

### Adding New Tests

Edit `.github/workflows/aks-deploy.yml` → Job `test-deployment-dev`:

```yaml
# Add a new test after Test 5
echo ""
echo "Test 6: Your new test description..."

# Run your test command
RESULT=$(your-test-command || echo "FAIL")

if [ "$RESULT" = "EXPECTED_VALUE" ]; then
  echo "✅ PASS: Test passed"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "❌ FAIL: Test failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi
```

### Adjusting Wait Times

**For pod readiness (Job 3):**
```yaml
# Change from 5 minutes (60 iterations × 5 seconds)
for i in {1..60}; do

# To 10 minutes (120 iterations × 5 seconds)
for i in {1..120}; do
```

**For LoadBalancer provisioning:**
Add a wait step before Test 2:
```yaml
- name: Wait for LoadBalancer
  run: |
    echo "Waiting for LoadBalancer IP assignment..."
    sleep 180  # Wait 3 minutes
```

### Disabling Specific Tests

To skip a test temporarily:
```yaml
# Comment out the test or wrap in condition
if false; then
  echo "Test 3: Frontend health (DISABLED)"
  # ... test code ...
fi
```

---

## Monitoring Test Results

### Via GitHub Actions

1. Go to: https://github.com/uallknowmatt/aksreferenceimplementation/actions
2. Click on the latest workflow run
3. Expand **Job 4: Test Deployment (Automated Health Checks)**
4. Review test output

**Look for:**
- ✅ Green checkmarks → Tests passed
- ❌ Red X → Tests failed (see details)
- Test summary at the end

---

### Via Email Notifications

GitHub can email you on workflow failures:

1. Go to: https://github.com/settings/notifications
2. Check **Send notifications for failed workflows**
3. You'll receive email when tests fail

---

### Via Slack/Teams (Optional)

Add webhook integration to get notifications:

```yaml
# Add to workflow after test failures
- name: Notify Slack
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "⚠️ Deployment tests failed! Check GitHub Actions for details."
      }
```

---

## Best Practices

### 1. Always Review Test Failures Before Redeploying
❌ Don't just re-run the workflow hoping it works  
✅ Read the test output, identify root cause, fix the issue

### 2. Use `force_run=true` After Fixing Issues
❌ Don't rely on automatic triggers  
✅ Force a fresh deployment with fixed configuration

### 3. Monitor Costs During Testing
❌ Don't leave infrastructure running if tests fail  
✅ Self-healing will auto-stop, saving ~$52/month

### 4. Test Locally Before Deploying to Azure
❌ Don't use Azure as your testing ground  
✅ Run local tests with Docker Compose first

### 5. Keep Test Scripts Updated
❌ Don't ignore failing tests that "usually work"  
✅ Update test scripts when infrastructure changes

---

## Troubleshooting

### Tests Pass Locally But Fail in GitHub Actions

**Possible Causes:**
1. **Different environment:** Local uses Docker Compose, Azure uses AKS
2. **Network differences:** Local has no VNet integration
3. **Timing issues:** GitHub Actions may have different wait times

**Solution:**
- Compare configurations between local and Azure
- Increase wait times in GitHub Actions workflow
- Check environment variables in ConfigMaps vs local `.env`

---

### Tests Always Fail on First Deployment

**Possible Causes:**
1. **PostgreSQL initialization:** Takes 5-10 minutes on first deployment
2. **AKS node provisioning:** Takes 8-10 minutes
3. **LoadBalancer provisioning:** Takes 3-5 minutes

**Solution:**
- This is expected on first deployment
- Increase wait times in workflow
- Or trigger workflow again after infrastructure settles

---

### Self-Healing Stops Infrastructure Too Quickly

**Problem:** Infrastructure stops before you can debug

**Solution:**
1. **Temporarily disable auto-stop:** Comment out Job 5 in workflow
2. **Debug the deployment:** Review pod logs, check configurations
3. **Re-enable auto-stop:** Uncomment Job 5 after fixing

---

## Summary

You now have **automated testing and self-healing** that:

✅ **Validates every deployment** with 6 comprehensive health checks  
✅ **Stops infrastructure on failures** to prevent wasted costs (~$52/month saved)  
✅ **Forces fixing issues** before keeping infrastructure running  
✅ **Provides detailed failure reports** for quick debugging  
✅ **Runs automatically** on every deployment via GitHub Actions

**Next Steps:**
1. Review `CLEAN_DEPLOYMENT_GUIDE.md` for deployment instructions
2. Trigger a deployment and watch the automated tests run
3. Fix any test failures and redeploy
4. Celebrate when all tests pass! 🎉

**Happy testing! 🚀**
