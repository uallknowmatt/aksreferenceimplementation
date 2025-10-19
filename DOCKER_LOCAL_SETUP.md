# 🐳 Local Development with Docker + PostgreSQL

This guide explains how to run the complete application stack locally using Docker for PostgreSQL databases.

---

## 🎯 Why Docker + PostgreSQL?

✅ **Production Parity** - Same database as production (Azure PostgreSQL)  
✅ **PostgreSQL-Specific Features** - Can use custom SQL, extensions, functions  
✅ **Data Persistence** - Data survives container restarts  
✅ **Easy Reset** - Can recreate fresh databases anytime  
✅ **No Installation Required** - Just need Docker Desktop  

---

## 📋 Prerequisites

### 1. Install Docker Desktop

**Download:** https://www.docker.com/products/docker-desktop

**Verify Installation:**
```powershell
docker --version
docker-compose --version
```

Should show version numbers.

**Start Docker Desktop** - Make sure it's running before proceeding.

---

## 🏗️ Architecture

### Database Layout

Each microservice gets its own PostgreSQL database in a separate container:

| Service | Container | Port | Database | User | Password |
|---------|-----------|------|----------|------|----------|
| Customer | customer-db | 5432 | customerdb | postgres | postgres |
| Document | document-db | 5433 | documentdb | postgres | postgres |
| Account | account-db | 5434 | accountdb | postgres | postgres |
| Notification | notification-db | 5435 | notificationdb | postgres | postgres |

**Plus:**
- **pgAdmin** - Web-based database management UI on port 5050

### Microservices

| Service | Port | Database Connection |
|---------|------|---------------------|
| Customer Service | 8081 | localhost:5432/customerdb |
| Document Service | 8082 | localhost:5433/documentdb |
| Account Service | 8083 | localhost:5434/accountdb |
| Notification Service | 8084 | localhost:5435/notificationdb |

### Frontend

| Component | Port |
|-----------|------|
| React UI | 3000 |

---

## 🚀 Quick Start

### Option 1: Automated Script (Recommended)

```powershell
cd c:\genaiexperiments\accountopening
.\start-local-dev.ps1
```

This script will:
1. ✅ Check Docker is running
2. ✅ Start PostgreSQL containers
3. ✅ Wait for databases to be ready
4. ✅ Build backend services
5. ✅ Start all microservices

Then start the frontend:
```powershell
cd frontend\account-opening-ui
npm start
```

---

### Option 2: Manual Step-by-Step

#### Step 1: Start PostgreSQL Databases

```powershell
cd c:\genaiexperiments\accountopening
docker-compose up -d
```

**What this does:**
- Downloads PostgreSQL 15 Alpine images (first time only)
- Creates 4 separate database containers
- Creates persistent volumes for data storage
- Starts pgAdmin for database management

**Verify containers are running:**
```powershell
docker ps
```

Should show 5 containers: customer-db, document-db, account-db, notification-db, pgadmin

#### Step 2: Wait for Databases

```powershell
# Check health status
docker-compose ps

# Wait until all show "healthy" or "Up"
```

Takes about 10-15 seconds for databases to initialize.

#### Step 3: Build Backend Services

```powershell
mvn clean compile -DskipTests
```

#### Step 4: Start Microservices

Open 4 terminals and run:

**Terminal 1:**
```powershell
cd customer-service
mvn spring-boot:run
```

**Terminal 2:**
```powershell
cd document-service
mvn spring-boot:run
```

**Terminal 3:**
```powershell
cd account-service
mvn spring-boot:run
```

**Terminal 4:**
```powershell
cd notification-service
mvn spring-boot:run
```

Wait for each to show: `Started [ServiceName]Application in X seconds`

#### Step 5: Start Frontend

```powershell
cd frontend\account-opening-ui
npm start
```

---

## 🔍 Verifying Everything Works

### Check Docker Containers

```powershell
# See all containers
docker ps

# Check logs of a specific database
docker logs customer-db
docker logs document-db
docker logs account-db
docker logs notification-db

# Check health
docker inspect --format='{{.State.Health.Status}}' customer-db
```

### Check Database Connectivity

```powershell
# Test customer database
docker exec -it customer-db psql -U postgres -d customerdb -c "SELECT version();"

# Test document database
docker exec -it document-db psql -U postgres -d documentdb -c "SELECT version();"

# Test account database
docker exec -it account-db psql -U postgres -d accountdb -c "SELECT version();"

# Test notification database
docker exec -it notification-db psql -U postgres -d notificationdb -c "SELECT version();"
```

### Check Microservices

```powershell
# Test each service API
Invoke-RestMethod -Uri "http://localhost:8081/api/customers"
Invoke-RestMethod -Uri "http://localhost:8082/api/documents"
Invoke-RestMethod -Uri "http://localhost:8083/api/accounts"
Invoke-RestMethod -Uri "http://localhost:8084/api/notifications"
```

All should return `[]` (empty array).

### Run Health Check Script

```powershell
.\check-services.ps1
```

Should show all green checkmarks.

---

## 🗄️ Using pgAdmin

pgAdmin is a web-based PostgreSQL management tool.

### Access pgAdmin

1. Open browser: http://localhost:5050
2. Login:
   - Email: `admin@accountopening.com`
   - Password: `admin`

### Connect to Databases

For each database, add a new server:

**Customer Database:**
- Name: Customer DB
- Host: `customer-db`
- Port: `5432`
- Database: `customerdb`
- Username: `postgres`
- Password: `postgres`

**Document Database:**
- Name: Document DB
- Host: `document-db`
- Port: `5432`
- Database: `documentdb`
- Username: `postgres`
- Password: `postgres`

*Repeat for account-db and notification-db*

**Note:** Use the container name (e.g., `customer-db`), not `localhost`, when connecting from pgAdmin.

---

## 🛠️ Common Operations

### View Database Tables

After starting services and creating data:

```powershell
# Customer database tables
docker exec -it customer-db psql -U postgres -d customerdb -c "\dt"

# Document database tables
docker exec -it document-db psql -U postgres -d documentdb -c "\dt"

# Account database tables
docker exec -it account-db psql -U postgres -d accountdb -c "\dt"

# Notification database tables
docker exec -it notification-db psql -U postgres -d notificationdb -c "\dt"
```

### Query Data

```powershell
# See all customers
docker exec -it customer-db psql -U postgres -d customerdb -c "SELECT * FROM customer;"

# See all accounts
docker exec -it account-db psql -U postgres -d accountdb -c "SELECT * FROM account;"

# See all documents
docker exec -it document-db psql -U postgres -d documentdb -c "SELECT * FROM document;"

# See all notifications
docker exec -it notification-db psql -U postgres -d notificationdb -c "SELECT * FROM notification;"
```

### Reset Database (Clear All Data)

```powershell
# Stop and remove containers (keeps images)
docker-compose down

# Remove volumes (deletes all data)
docker-compose down -v

# Start fresh
docker-compose up -d
```

### View Logs

```powershell
# View logs from all containers
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker logs customer-db -f
docker logs pgadmin -f
```

### Stop Services

```powershell
# Stop all containers (data persists)
docker-compose stop

# Stop and remove containers (data persists in volumes)
docker-compose down

# Stop and remove everything including data
docker-compose down -v
```

### Restart Services

```powershell
# Restart all containers
docker-compose restart

# Restart specific container
docker restart customer-db
```

---

## 🐛 Troubleshooting

### Docker Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solution:**
1. Open Docker Desktop
2. Wait for it to fully start (whale icon in system tray)
3. Try command again

---

### Port Already in Use

**Error:** `port is already allocated`

**Check what's using the port:**
```powershell
netstat -ano | findstr :5432
```

**Options:**
1. Kill the process using that port
2. OR change the port in docker-compose.yml:
   ```yaml
   ports:
     - "5436:5432"  # Use different host port
   ```

---

### Container Unhealthy

**Error:** Container shows as unhealthy

**Check logs:**
```powershell
docker logs customer-db
```

**Common fixes:**
1. Give it more time (30 seconds)
2. Restart container: `docker restart customer-db`
3. Remove and recreate: `docker-compose down && docker-compose up -d`

---

### Service Can't Connect to Database

**Error:** `Connection refused` in service logs

**Checks:**
1. Is database container running?
   ```powershell
   docker ps | findstr customer-db
   ```

2. Is database ready?
   ```powershell
   docker logs customer-db | findstr "ready"
   ```

3. Test connection:
   ```powershell
   docker exec -it customer-db psql -U postgres -d customerdb -c "SELECT 1;"
   ```

4. Check application.yml has correct port:
   - customer-service → 5432
   - document-service → 5433
   - account-service → 5434
   - notification-service → 5435

---

### Permission Denied on Volumes

**Error:** Permission errors with volumes

**Solution (Windows):**
1. Open Docker Desktop Settings
2. Resources → File Sharing
3. Add `C:\genaiexperiments\accountopening`
4. Apply & Restart

---

### Out of Disk Space

**Error:** `no space left on device`

**Clean up Docker:**
```powershell
# Remove unused containers, images, volumes
docker system prune -a

# Remove just volumes
docker volume prune
```

---

## 📊 Database Schema

Tables are created automatically by Hibernate/JPA when services start.

### Customer Service Tables

- `customer` - Customer information
  - id, first_name, last_name, email, phone_number, date_of_birth, address, kyc_verified, created_at

### Document Service Tables

- `document` - Document metadata
  - id, customer_id, file_name, file_type, type, content, verified, uploaded_at

### Account Service Tables

- `account` - Bank accounts
  - id, customer_id, account_number, account_type, balance, status, active, created_at

### Notification Service Tables

- `notification` - Sent notifications
  - id, recipient, message, type, status, sent_at

---

## 🔄 Data Persistence

### Where is Data Stored?

Data is stored in Docker volumes:
- `customer-data`
- `document-data`
- `account-data`
- `notification-data`

### View Volumes

```powershell
docker volume ls
```

### Backup Data

```powershell
# Backup customer database
docker exec customer-db pg_dump -U postgres customerdb > customer-backup.sql

# Backup all databases
docker exec customer-db pg_dump -U postgres customerdb > customer-backup.sql
docker exec document-db pg_dump -U postgres documentdb > document-backup.sql
docker exec account-db pg_dump -U postgres accountdb > account-backup.sql
docker exec notification-db pg_dump -U postgres notificationdb > notification-backup.sql
```

### Restore Data

```powershell
# Restore customer database
cat customer-backup.sql | docker exec -i customer-db psql -U postgres customerdb
```

---

## 🎯 Complete Workflow Example

### 1. Start Everything

```powershell
cd c:\genaiexperiments\accountopening
.\start-local-dev.ps1
```

Wait for all services to start.

### 2. Start Frontend

```powershell
cd frontend\account-opening-ui
npm start
```

### 3. Create Test Data

1. Go to http://localhost:3000
2. Click "Open New Account"
3. Fill in customer info
4. Upload documents
5. Create account
6. Submit

### 4. View Data in Database

```powershell
# See the customer you just created
docker exec -it customer-db psql -U postgres -d customerdb -c "SELECT id, first_name, last_name, email FROM customer;"

# See the account
docker exec -it account-db psql -U postgres -d accountdb -c "SELECT id, account_number, account_type, balance FROM account;"
```

### 5. Or Use pgAdmin

1. Open http://localhost:5050
2. Login: admin@accountopening.com / admin
3. Connect to databases
4. Browse tables
5. Run queries

### 6. Stop Everything

```powershell
# Stop backend services (Ctrl+C in each terminal)

# Stop frontend (Ctrl+C)

# Stop Docker containers
docker-compose stop

# Or completely remove (keeps data in volumes)
docker-compose down
```

---

## 📝 Configuration Files

### docker-compose.yml

Defines all PostgreSQL containers and pgAdmin.

**Located at:** `c:\genaiexperiments\accountopening\docker-compose.yml`

### Init Scripts

SQL scripts that run when container first starts.

**Located at:** `docker/init-scripts/`
- `customer-init.sql`
- `document-init.sql`
- `account-init.sql`
- `notification-init.sql`

**Note:** These only run on first container creation. To re-run, delete volumes: `docker-compose down -v`

### Application Configuration

Each service's database connection configured in:

**Customer Service:** `customer-service/src/main/resources/application.yml`
```yaml
datasource:
  url: jdbc:postgresql://localhost:5432/customerdb
  username: postgres
  password: postgres
```

**Document Service:** `document-service/src/main/resources/application.yml`
```yaml
datasource:
  url: jdbc:postgresql://localhost:5433/documentdb
  username: postgres
  password: postgres
```

**Account Service:** `account-service/src/main/resources/application.yml`
```yaml
datasource:
  url: jdbc:postgresql://localhost:5434/accountdb
  username: postgres
  password: postgres
```

**Notification Service:** `notification-service/src/main/resources/application.yml`
```yaml
datasource:
  url: jdbc:postgresql://localhost:5435/notificationdb
  username: postgres
  password: postgres
```

---

## 🎉 Summary

### What You Have Now

✅ Production-ready PostgreSQL databases running in Docker  
✅ Each microservice has its own database  
✅ Data persists across restarts  
✅ pgAdmin for easy database management  
✅ Can use PostgreSQL-specific features  
✅ Easy to reset/recreate databases  
✅ Automated startup scripts  

### Quick Commands Reference

```powershell
# Start everything
.\start-local-dev.ps1

# Check status
docker-compose ps
.\check-services.ps1

# View logs
docker-compose logs -f

# Stop everything
docker-compose stop

# Fresh start (deletes data)
docker-compose down -v
docker-compose up -d

# Backup database
docker exec customer-db pg_dump -U postgres customerdb > backup.sql

# Access database directly
docker exec -it customer-db psql -U postgres -d customerdb
```

---

**You're now ready for production-parity local development! 🚀**
