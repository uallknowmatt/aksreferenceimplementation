# Local Development Guide

This guide covers setting up and running the Account Opening application on your local machine.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Option 1: Docker Compose (Recommended)](#option-1-docker-compose-recommended)
- [Option 2: Manual Setup](#option-2-manual-setup)
- [Local Testing](#local-testing)
- [Database Management](#database-management)

---

## Prerequisites

### Required Software

| Tool | Version | Purpose | Download |
|------|---------|---------|----------|
| Docker | 20.10+ | Container runtime | [Install](https://www.docker.com/products/docker-desktop) |
| Git | 2.30+ | Version control | [Install](https://git-scm.com/downloads) |
| Node.js | 18+ | Frontend development | [Install](https://nodejs.org/) |
| Java | 17+ | Backend development | [Install](https://adoptium.net/) |
| Maven | 3.8+ | Build tool | [Install](https://maven.apache.org/download.cgi) |

### Optional Tools
- pgAdmin (database GUI)
- Postman (API testing)
- VS Code (recommended IDE)

---

## Option 1: Docker Compose (Recommended)

The fastest way to run everything locally with all dependencies.

### 1. Start All Services

```bash
# Clone repository (if not already done)
git clone https://github.com/your-org/accountopening.git
cd accountopening

# Start PostgreSQL databases and all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Tail specific service
docker-compose logs -f customer-service
```

### 2. Access Services

- **Frontend UI:** http://localhost:3000
- **Customer Service:** http://localhost:8081/actuator/health
- **Document Service:** http://localhost:8082/actuator/health
- **Account Service:** http://localhost:8083/actuator/health
- **Notification Service:** http://localhost:8084/actuator/health
- **pgAdmin:** http://localhost:5050
  - Login: `admin@accountopening.com`
  - Password: `admin`

### 3. Database Connections (from pgAdmin)

| Database | Host | Port | Database Name | User | Password |
|----------|------|------|---------------|------|----------|
| Customer DB | customer-db | 5432 | customerdb | postgres | postgres |
| Document DB | document-db | 5432 | documentdb | postgres | postgres |
| Account DB | account-db | 5432 | accountdb | postgres | postgres |
| Notification DB | notification-db | 5432 | notificationdb | postgres | postgres |

### 4. Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean database)
docker-compose down -v
```

### 5. Rebuild After Code Changes

```bash
# Rebuild specific service
docker-compose up -d --build customer-service

# Rebuild all services
docker-compose up -d --build
```

---

## Option 2: Manual Setup

For developers who want more control or don't want to use Docker.

### 1. Setup Databases

**Option A: Use Docker for databases only:**
```bash
docker-compose up -d customer-db document-db account-db notification-db
```

**Option B: Install PostgreSQL locally:**
```bash
# Using the setup script
cd scripts/educational
./setup-databases.sh

# OR manually:
# Install PostgreSQL 15
# Create databases:
createdb -U postgres customerdb
createdb -U postgres documentdb
createdb -U postgres accountdb
createdb -U postgres notificationdb
```

### 2. Build Backend Services

```bash
# Build all services
mvn clean install -DskipTests

# OR build individually
cd customer-service && mvn clean install -DskipTests
cd ../document-service && mvn clean install -DskipTests
cd ../account-service && mvn clean install -DskipTests
cd ../notification-service && mvn clean install -DskipTests
```

### 3. Start Backend Services

**Option A: Use start script (opens multiple terminals):**
```bash
cd scripts/educational
./start-all-services.sh
```

**Option B: Start manually in separate terminals:**

**Terminal 1 - Customer Service:**
```bash
cd customer-service
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/customerdb
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres
mvn spring-boot:run
```

**Terminal 2 - Document Service:**
```bash
cd document-service
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/documentdb
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres
mvn spring-boot:run
```

**Terminal 3 - Account Service:**
```bash
cd account-service
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/accountdb
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres
mvn spring-boot:run
```

**Terminal 4 - Notification Service:**
```bash
cd notification-service
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/notificationdb
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres
mvn spring-boot:run
```

### 4. Start Frontend

```bash
cd frontend/account-opening-ui
npm install
npm start
```

The frontend will open automatically at http://localhost:3000

### 5. Verify Services Running

```bash
# Check backend services
curl http://localhost:8081/actuator/health  # Customer Service
curl http://localhost:8082/actuator/health  # Document Service
curl http://localhost:8083/actuator/health  # Account Service
curl http://localhost:8084/actuator/health  # Notification Service

# Check frontend
curl http://localhost:3000
```

---

## Local Testing

### Health Check Script

Test all local services at once:

```bash
cd scripts/educational
./check-services.sh
```

**Expected Output:**
```
========================================
Backend Services Health Check
========================================

Checking if services are running...

Testing Customer Service on port 8081...
  ✅ Customer Service is UP and responding
     Response: {"status":"UP","groups":["liveness","readiness"]}

Testing Document Service on port 8082...
  ✅ Document Service is UP and responding
     
Testing Account Service on port 8083...
  ✅ Account Service is UP and responding
     
Testing Notification Service on port 8084...
  ✅ Notification Service is UP and responding

========================================
✅ ALL SERVICES ARE WORKING!

You can now test the UI at:
  http://localhost:3000
```

### Manual API Testing

#### Test Customer Service

```bash
# Create a customer
curl -X POST http://localhost:8081/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1-555-0100",
    "dateOfBirth": "1990-01-01"
  }'

# Get all customers
curl http://localhost:8081/api/customers

# Get specific customer
curl http://localhost:8081/api/customers/1
```

#### Test Document Service

```bash
# Upload document metadata
curl -X POST http://localhost:8082/api/documents \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": 1,
    "documentType": "ID_PROOF",
    "documentName": "drivers_license.pdf",
    "uploadDate": "2024-10-23"
  }'

# Get documents for customer
curl http://localhost:8082/api/documents?customerId=1
```

#### Test Account Service

```bash
# Create account
curl -X POST http://localhost:8083/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": 1,
    "accountType": "SAVINGS",
    "initialDeposit": 1000.00,
    "currency": "USD"
  }'

# Get accounts
curl http://localhost:8083/api/accounts?customerId=1
```

#### Test Notification Service

```bash
# Send notification
curl -X POST http://localhost:8084/api/notifications \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": 1,
    "notificationType": "EMAIL",
    "subject": "Account Opened",
    "message": "Your savings account has been opened successfully."
  }'

# Get notifications
curl http://localhost:8084/api/notifications?customerId=1
```

---

## Database Management

### Connect to PostgreSQL

**Using Docker:**
```bash
# Customer DB
docker exec -it customer-db psql -U postgres -d customerdb

# Inside psql:
\dt                           # List tables
SELECT * FROM customer;       # Query customers
\q                            # Quit
```

**Using psql (local installation):**
```bash
psql -U postgres -d customerdb
```

### Using pgAdmin

1. **Open pgAdmin:** http://localhost:5050 (if using Docker Compose)
2. **Login:** `admin@accountopening.com` / `admin`
3. **Add Server:**
   - Right-click "Servers" → Register → Server
   - **General Tab:**
     - Name: `customer-db`
   - **Connection Tab:**
     - Host: `customer-db` (Docker) or `localhost` (local)
     - Port: `5432`
     - Database: `customerdb`
     - Username: `postgres`
     - Password: `postgres`
   - Click "Save"

4. **Browse Data:**
   - Expand: Servers → customer-db → Databases → customerdb → Schemas → public → Tables
   - Right-click table → View/Edit Data → All Rows

### Reset Database

```bash
# Using Docker Compose (removes all data)
docker-compose down -v
docker-compose up -d

# Using script
cd scripts/educational
./reset-databases.sh
```

### View Liquibase Migrations

```bash
# Check what migrations have run
psql -U postgres -d customerdb -c "SELECT * FROM databasechangelog ORDER BY dateexecuted DESC LIMIT 10;"
```

---

## Troubleshooting Local Development

### Service Won't Start

**Error: Port already in use**
```bash
# Find process using port 8081
lsof -i :8081  # macOS/Linux
netstat -ano | findstr :8081  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows
```

### Database Connection Failed

```bash
# Check if PostgreSQL is running (Docker)
docker ps | grep postgres

# Check if PostgreSQL is running (local)
pg_isready -U postgres

# View database logs (Docker)
docker logs customer-db
```

### Frontend Can't Connect to Backend

**Check CORS configuration:**
- Ensure backend services allow `http://localhost:3000` origin
- Check `application.yml` in each service:
  ```yaml
  spring:
    web:
      cors:
        allowed-origins: "http://localhost:3000"
        allowed-methods: "*"
  ```

### Maven Build Fails

```bash
# Clean Maven cache
mvn clean

# Skip tests
mvn clean install -DskipTests

# Update dependencies
mvn clean install -U
```

### Docker Compose Issues

```bash
# View logs
docker-compose logs -f

# Restart specific service
docker-compose restart customer-service

# Rebuild and restart
docker-compose up -d --build customer-service

# Clean everything
docker-compose down -v
docker system prune -a
```

---

## Development Tips

### Hot Reload

**Backend (Spring Boot DevTools):**
- Add dependency in `pom.xml`:
  ```xml
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>true</optional>
  </dependency>
  ```
- Changes auto-reload when you rebuild

**Frontend (React):**
- `npm start` enables hot reload automatically
- Changes apply instantly without restart

### IDE Configuration

**VS Code:**
- Install extensions: Spring Boot Extension Pack, ESLint, Prettier
- Use `.vscode/settings.json` (included in repo)

**IntelliJ IDEA:**
- Import Maven project
- Enable annotation processing
- Configure Spring Boot run configurations

### Debugging

**Backend:**
```bash
# Run with debug port
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"

# Connect debugger to port 5005
```

**Frontend:**
- Use browser DevTools (F12)
- React DevTools extension
- Console logs and breakpoints

---

**See Also:**
- [Testing Guide](TESTING_GUIDE.md)
- [Deployment Guide](DEPLOYMENT_GUIDE.md)
- [Technology Deep Dive](TECHNOLOGY_DEEP_DIVE.md)
