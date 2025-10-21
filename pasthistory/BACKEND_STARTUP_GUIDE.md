# Backend Services Startup Guide

## Quick Start

To test the full end-to-end account opening flow, you need to start all 4 backend microservices.

---

## Prerequisites

- Java 17 installed
- Maven 3.9+ installed
- PostgreSQL running (if using real database) OR services configured to use H2 in-memory database

---

## Starting All Services

### Option 1: Start All Services at Once (PowerShell)

Open PowerShell in the project root and run:

```powershell
# Start Customer Service
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd customer-service; mvn spring-boot:run"

# Wait 10 seconds
Start-Sleep -Seconds 10

# Start Document Service  
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd document-service; mvn spring-boot:run"

# Wait 10 seconds
Start-Sleep -Seconds 10

# Start Account Service
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd account-service; mvn spring-boot:run"

# Wait 10 seconds
Start-Sleep -Seconds 10

# Start Notification Service
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd notification-service; mvn spring-boot:run"
```

This will open 4 separate PowerShell windows, one for each service.

---

### Option 2: Start Services One by One

#### Terminal 1: Customer Service
```powershell
cd c:\genaiexperiments\accountopening\customer-service
mvn spring-boot:run
```

#### Terminal 2: Document Service
```powershell
cd c:\genaiexperiments\accountopening\document-service
mvn spring-boot:run
```

#### Terminal 3: Account Service
```powershell
cd c:\genaiexperiments\accountopening\account-service
mvn spring-boot:run
```

#### Terminal 4: Notification Service
```powershell
cd c:\genaiexperiments\accountopening\notification-service
mvn spring-boot:run
```

---

## Service Ports

Each service runs on a different port:

| Service | Port | URL |
|---------|------|-----|
| Customer Service | 8081 | http://localhost:8081 |
| Document Service | 8082 | http://localhost:8082 |
| Account Service | 8083 | http://localhost:8083 |
| Notification Service | 8084 | http://localhost:8084 |

---

## Verifying Services Are Running

### Check Health Endpoints

Open your browser or use curl:

```powershell
# Customer Service
Invoke-WebRequest -Uri http://localhost:8081/actuator/health

# Document Service
Invoke-WebRequest -Uri http://localhost:8082/actuator/health

# Account Service
Invoke-WebRequest -Uri http://localhost:8083/actuator/health

# Notification Service
Invoke-WebRequest -Uri http://localhost:8084/actuator/health
```

Each should return: `{"status":"UP"}`

---

## Testing the API

### Create a Customer
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/customers" -Method Post -ContentType "application/json" -Body '{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "dateOfBirth": "1990-01-01",
  "address": "123 Main St, City, State 12345"
}'
```

### Get All Customers
```powershell
Invoke-RestMethod -Uri "http://localhost:8081/api/customers" -Method Get
```

---

## Common Issues

### Issue: Port Already in Use

**Error:** `Port 8081 is already in use`

**Solution:**
```powershell
# Find process using the port
netstat -ano | findstr :8081

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Issue: Java Not Found

**Error:** `'java' is not recognized as an internal or external command`

**Solution:**
1. Install Java 17
2. Set JAVA_HOME environment variable
3. Add Java to PATH

### Issue: Maven Not Found

**Error:** `'mvn' is not recognized as an internal or external command`

**Solution:**
1. Use the included Maven: `tools\apache-maven-3.9.11\bin\mvn`
2. Or install Maven globally and add to PATH

---

## CORS Configuration

The backend services should already be configured to allow requests from `http://localhost:3000`.

If you encounter CORS errors, check each service's `application.yml` or add:

```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                    .allowedOrigins("http://localhost:3000")
                    .allowedMethods("GET", "POST", "PUT", "DELETE")
                    .allowedHeaders("*");
            }
        };
    }
}
```

---

## Stopping Services

To stop all services:

1. Go to each PowerShell window
2. Press `Ctrl + C`
3. Type `Y` to confirm

Or close the terminal windows.

---

## Next Steps

Once all services are running:

1. Open http://localhost:3000 in your browser
2. Click "Open New Account"
3. Complete the wizard:
   - Fill in customer information
   - Upload documents (passport, ID, etc.)
   - Select account type and deposit
   - Review and submit
4. Check that:
   - Customer is created
   - Documents are uploaded
   - Account is created
   - Notification is sent

---

## Troubleshooting Tips

### Check Logs

Each terminal window shows real-time logs. Look for:
- ✅ `Started [ServiceName]Application in X seconds`
- ❌ `Error starting ApplicationContext`
- ⚠️ Connection errors or exceptions

### Test Individual Services

Before testing the full flow, verify each service works:

```powershell
# Test customer service
Invoke-RestMethod -Uri "http://localhost:8081/api/customers" -Method Get

# Test document service  
Invoke-RestMethod -Uri "http://localhost:8082/api/documents" -Method Get

# Test account service
Invoke-RestMethod -Uri "http://localhost:8083/api/accounts" -Method Get

# Test notification service
Invoke-RestMethod -Uri "http://localhost:8084/api/notifications" -Method Get
```

### Database Issues

If using PostgreSQL, ensure:
1. PostgreSQL is running
2. Databases exist for each service
3. Connection credentials are correct in `application.yml`

If using H2 (in-memory), no setup needed.

---

## Quick Health Check Script

Save this as `check-services.ps1`:

```powershell
$services = @(
    @{Name="Customer"; Port=8081},
    @{Name="Document"; Port=8082},
    @{Name="Account"; Port=8083},
    @{Name="Notification"; Port=8084}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)/actuator/health" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name) Service is UP on port $($service.Port)" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ $($service.Name) Service is DOWN on port $($service.Port)" -ForegroundColor Red
    }
}
```

Run with: `.\check-services.ps1`

---

**Happy Testing! 🚀**
