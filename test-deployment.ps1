#!/usr/bin/env pwsh
# ============================================
# Automated Health Check Script
# ============================================
# Tests deployed application to ensure it's ready for customers
# Returns exit code 0 if all tests pass, 1 if any fail

param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev"
)

$ErrorActionPreference = "Continue"
$TestsPassed = 0
$TestsFailed = 0

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🔍 AUTOMATED HEALTH CHECK - $Environment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ============================================
# Test 1: Check if all pods are running
# ============================================
Write-Host "Test 1: Checking pod status..." -ForegroundColor Yellow

$pods = kubectl get pods -o json | ConvertFrom-Json
$allPodsReady = $true

foreach ($pod in $pods.items) {
    $podName = $pod.metadata.name
    $podStatus = $pod.status.phase
    $containerStatuses = $pod.status.containerStatuses
    
    if ($containerStatuses) {
        $ready = $containerStatuses[0].ready
        $restartCount = $containerStatuses[0].restartCount
        
        if ($podStatus -ne "Running" -or -not $ready) {
            Write-Host "  ❌ FAIL: $podName is $podStatus (Ready: $ready, Restarts: $restartCount)" -ForegroundColor Red
            $allPodsReady = $false
        } else {
            Write-Host "  ✅ PASS: $podName is Running (Restarts: $restartCount)" -ForegroundColor Green
        }
    }
}

if ($allPodsReady) {
    Write-Host "`n✅ Test 1 PASSED: All pods are running`n" -ForegroundColor Green
    $TestsPassed++
} else {
    Write-Host "`n❌ Test 1 FAILED: Some pods are not running`n" -ForegroundColor Red
    $TestsFailed++
}

# ============================================
# Test 2: Check frontend LoadBalancer IP
# ============================================
Write-Host "Test 2: Checking frontend LoadBalancer..." -ForegroundColor Yellow

$frontendIP = kubectl get service frontend-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null

if ($frontendIP) {
    Write-Host "  ✅ PASS: Frontend LoadBalancer IP assigned: $frontendIP" -ForegroundColor Green
    Write-Host "`n✅ Test 2 PASSED: LoadBalancer IP available`n" -ForegroundColor Green
    $TestsPassed++
} else {
    Write-Host "  ❌ FAIL: Frontend LoadBalancer IP not assigned" -ForegroundColor Red
    Write-Host "`n❌ Test 2 FAILED: No LoadBalancer IP`n" -ForegroundColor Red
    $TestsFailed++
}

# ============================================
# Test 3: Check frontend health endpoint
# ============================================
Write-Host "Test 3: Checking frontend health endpoint..." -ForegroundColor Yellow

if ($frontendIP) {
    try {
        $response = Invoke-WebRequest -Uri "http://$frontendIP/health" -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✅ PASS: Frontend health endpoint returns 200 OK" -ForegroundColor Green
            Write-Host "`n✅ Test 3 PASSED: Frontend is healthy`n" -ForegroundColor Green
            $TestsPassed++
        } else {
            Write-Host "  ❌ FAIL: Frontend health endpoint returned $($response.StatusCode)" -ForegroundColor Red
            Write-Host "`n❌ Test 3 FAILED: Frontend health check failed`n" -ForegroundColor Red
            $TestsFailed++
        }
    } catch {
        Write-Host "  ❌ FAIL: Cannot reach frontend health endpoint - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "`n❌ Test 3 FAILED: Frontend not accessible`n" -ForegroundColor Red
        $TestsFailed++
    }
} else {
    Write-Host "  ⚠️  SKIP: No LoadBalancer IP available" -ForegroundColor Yellow
    Write-Host "`n⚠️  Test 3 SKIPPED`n" -ForegroundColor Yellow
}

# ============================================
# Test 4: Check backend service health (via port-forward)
# ============================================
Write-Host "Test 4: Checking backend service health..." -ForegroundColor Yellow

$services = @("customer-service", "document-service", "account-service", "notification-service")
$allServicesHealthy = $true

foreach ($service in $services) {
    try {
        # Port forward in background
        $portForwardJob = Start-Job -ScriptBlock {
            param($svc)
            kubectl port-forward "service/$svc" 8080:80 2>$null
        } -ArgumentList $service
        
        Start-Sleep -Seconds 3
        
        # Test health endpoint
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 5 -UseBasicParsing
            $healthData = $response.Content | ConvertFrom-Json
            
            if ($healthData.status -eq "UP") {
                Write-Host "  ✅ PASS: $service is UP" -ForegroundColor Green
            } else {
                Write-Host "  ❌ FAIL: $service status is $($healthData.status)" -ForegroundColor Red
                $allServicesHealthy = $false
            }
        } catch {
            Write-Host "  ❌ FAIL: $service health check failed - $($_.Exception.Message)" -ForegroundColor Red
            $allServicesHealthy = $false
        } finally {
            Stop-Job -Job $portForwardJob -ErrorAction SilentlyContinue
            Remove-Job -Job $portForwardJob -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "  ❌ FAIL: Cannot port-forward to $service" -ForegroundColor Red
        $allServicesHealthy = $false
    }
}

if ($allServicesHealthy) {
    Write-Host "`n✅ Test 4 PASSED: All backend services are healthy`n" -ForegroundColor Green
    $TestsPassed++
} else {
    Write-Host "`n❌ Test 4 FAILED: Some backend services are unhealthy`n" -ForegroundColor Red
    $TestsFailed++
}

# ============================================
# Test 5: Check database connectivity from pods
# ============================================
Write-Host "Test 5: Checking database connectivity..." -ForegroundColor Yellow

$podName = kubectl get pods -l app=customer-service -o jsonpath='{.items[0].metadata.name}' 2>$null

if ($podName) {
    try {
        $dbTest = kubectl exec $podName -- sh -c "wget -qO- http://localhost:8081/actuator/health/db 2>/dev/null" 2>$null
        
        if ($dbTest -like "*UP*") {
            Write-Host "  ✅ PASS: Database connectivity verified from customer-service" -ForegroundColor Green
            Write-Host "`n✅ Test 5 PASSED: Database is accessible`n" -ForegroundColor Green
            $TestsPassed++
        } else {
            Write-Host "  ❌ FAIL: Database connectivity failed" -ForegroundColor Red
            Write-Host "`n❌ Test 5 FAILED: Cannot connect to database`n" -ForegroundColor Red
            $TestsFailed++
        }
    } catch {
        Write-Host "  ❌ FAIL: Database connectivity check failed - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "`n❌ Test 5 FAILED: Database connectivity error`n" -ForegroundColor Red
        $TestsFailed++
    }
} else {
    Write-Host "  ⚠️  SKIP: No customer-service pod found" -ForegroundColor Yellow
    Write-Host "`n⚠️  Test 5 SKIPPED`n" -ForegroundColor Yellow
}

# ============================================
# Test 6: End-to-end smoke test (create customer)
# ============================================
Write-Host "Test 6: Running end-to-end smoke test..." -ForegroundColor Yellow

if ($frontendIP) {
    try {
        $customerData = @{
            firstName = "Test"
            lastName = "Customer"
            email = "test@example.com"
            phone = "+1-555-0100"
            dateOfBirth = "1990-01-01"
        } | ConvertTo-Json

        $response = Invoke-WebRequest `
            -Uri "http://$frontendIP/api/customer/customers" `
            -Method POST `
            -Body $customerData `
            -ContentType "application/json" `
            -TimeoutSec 10 `
            -UseBasicParsing
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
            Write-Host "  ✅ PASS: Successfully created test customer" -ForegroundColor Green
            Write-Host "`n✅ Test 6 PASSED: End-to-end flow working`n" -ForegroundColor Green
            $TestsPassed++
        } else {
            Write-Host "  ❌ FAIL: Customer creation returned $($response.StatusCode)" -ForegroundColor Red
            Write-Host "`n❌ Test 6 FAILED: End-to-end flow failed`n" -ForegroundColor Red
            $TestsFailed++
        }
    } catch {
        Write-Host "  ❌ FAIL: End-to-end test failed - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "`n❌ Test 6 FAILED: Cannot complete end-to-end test`n" -ForegroundColor Red
        $TestsFailed++
    }
} else {
    Write-Host "  ⚠️  SKIP: No LoadBalancer IP available" -ForegroundColor Yellow
    Write-Host "`n⚠️  Test 6 SKIPPED`n" -ForegroundColor Yellow
}

# ============================================
# Final Summary
# ============================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📊 TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Tests Passed: $TestsPassed" -ForegroundColor Green
Write-Host "❌ Tests Failed: $TestsFailed" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

if ($TestsFailed -eq 0) {
    Write-Host "🎉 ALL TESTS PASSED - Application is ready for customers!" -ForegroundColor Green
    Write-Host "Frontend URL: http://$frontendIP`n" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "⚠️  TESTS FAILED - Application is NOT ready!" -ForegroundColor Red
    Write-Host "Please review the errors above and fix before proceeding.`n" -ForegroundColor Yellow
    exit 1
}
