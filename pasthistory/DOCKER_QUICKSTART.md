# 🐳 Docker + PostgreSQL Local Development - QUICK START

## ✅ What's Been Set Up

**Created:**
- ✅ `docker-compose.yml` - 4 PostgreSQL databases + pgAdmin
- ✅ `docker/init-scripts/` - Database initialization scripts
- ✅ `start-local-dev.ps1` - Automated startup script
- ✅ `DOCKER_LOCAL_SETUP.md` - Complete documentation

**Updated:**
- ✅ All 4 `application.yml` files with correct database ports
- ✅ Database passwords changed from "password" to "postgres"

---

## 🚀 TO GET STARTED NOW

### Prerequisites

1. **Install Docker Desktop**
   - Download: https://www.docker.com/products/docker-desktop
   - Install and start Docker Desktop
   - Verify: `docker --version`

### Start Everything (3 Commands!)

```powershell
# 1. Start databases and services
cd c:\genaiexperiments\accountopening
.\start-local-dev.ps1

# 2. Wait for all services to start (check each terminal window)
# Look for: "Started [ServiceName]Application in X seconds"

# 3. Start frontend (in new terminal)
cd c:\genaiexperiments\accountopening\frontend\account-opening-ui
npm start
```

That's it! Open http://localhost:3000

---

## 📊 What's Running

### PostgreSQL Databases (Docker)

| Service | Container | Port | URL |
|---------|-----------|------|-----|
| Customer | customer-db | 5432 | localhost:5432 |
| Document | document-db | 5433 | localhost:5433 |
| Account | account-db | 5434 | localhost:5434 |
| Notification | notification-db | 5435 | localhost:5435 |
| **pgAdmin** | pgadmin | 5050 | http://localhost:5050 |

**pgAdmin Login:**
- Email: admin@accountopening.com
- Password: admin

### Microservices (Java/Spring Boot)

| Service | Port | Database |
|---------|------|----------|
| Customer | 8081 | customer-db:5432 |
| Document | 8082 | document-db:5433 |
| Account | 8083 | account-db:5434 |
| Notification | 8084 | notification-db:5435 |

### Frontend (React)

| Component | Port |
|-----------|------|
| React UI | 3000 |

---

## 🔍 Verify Everything Works

```powershell
# Check Docker containers
docker ps

# Should show 5 containers running:
# customer-db, document-db, account-db, notification-db, pgadmin

# Check services
.\check-services.ps1

# Should show 4 green checkmarks
```

---

## 🗄️ View Database Data

### Option 1: Command Line

```powershell
# See all customers
docker exec -it customer-db psql -U postgres -d customerdb -c "SELECT * FROM customer;"

# See all accounts
docker exec -it account-db psql -U postgres -d accountdb -c "SELECT * FROM account;"
```

### Option 2: pgAdmin (Visual)

1. Open http://localhost:5050
2. Login: admin@accountopening.com / admin
3. Add server:
   - Host: `customer-db`
   - Port: 5432
   - Database: customerdb
   - User: postgres
   - Password: postgres
4. Browse tables visually

---

## 🛑 Stop Everything

```powershell
# Stop backend services
# (Close all PowerShell windows or Ctrl+C in each)

# Stop frontend
# (Ctrl+C in frontend terminal)

# Stop Docker containers (keeps data)
docker-compose stop

# Or completely remove (keeps data in volumes)
docker-compose down
```

---

## 🔄 Reset Databases (Fresh Start)

```powershell
# Delete all data and start fresh
docker-compose down -v
docker-compose up -d

# Wait 10 seconds for databases to initialize
```

---

## ✅ Benefits of This Setup

### ✅ Production Parity
- Same PostgreSQL as Azure production
- No H2 compatibility issues
- Test real PostgreSQL features

### ✅ Easy Management
- One command to start all databases
- pgAdmin for visual management
- Easy to reset/recreate

### ✅ Data Persistence
- Data survives container restarts
- Can backup/restore databases
- Realistic testing environment

### ✅ Custom SQL Support
- Can use PostgreSQL-specific SQL
- Can add custom functions
- Can use extensions (uuid, etc.)

### ✅ Isolated Databases
- Each service has its own database
- True microservices architecture
- No database conflicts

---

## 📝 Files Created/Modified

### New Files (5)

1. **docker-compose.yml** - Docker container definitions
2. **docker/init-scripts/customer-init.sql** - Customer DB init
3. **docker/init-scripts/document-init.sql** - Document DB init
4. **docker/init-scripts/account-init.sql** - Account DB init
5. **docker/init-scripts/notification-init.sql** - Notification DB init
6. **start-local-dev.ps1** - Automated startup
7. **DOCKER_LOCAL_SETUP.md** - Complete documentation

### Modified Files (4)

1. **customer-service/src/main/resources/application.yml**
   - Port: 5432
   - Password: postgres

2. **document-service/src/main/resources/application.yml**
   - Port: 5433
   - Password: postgres

3. **account-service/src/main/resources/application.yml**
   - Port: 5434
   - Password: postgres

4. **notification-service/src/main/resources/application.yml**
   - Port: 5435
   - Password: postgres

---

## 🐛 Quick Troubleshooting

### "Docker is not running"

**Solution:** Start Docker Desktop and wait for it to fully start

### "Port already in use"

**Solution:**
```powershell
# Find what's using the port
netstat -ano | findstr :5432

# Kill the process
taskkill /PID <PID> /F
```

### "Container unhealthy"

**Solution:**
```powershell
# Check logs
docker logs customer-db

# Restart container
docker restart customer-db

# Or recreate
docker-compose down
docker-compose up -d
```

### "Service can't connect to database"

**Check:**
1. Is container running? `docker ps`
2. Check logs: `docker logs customer-db`
3. Test connection:
   ```powershell
   docker exec -it customer-db psql -U postgres -d customerdb -c "SELECT 1;"
   ```

---

## 🎯 Complete Test Flow

### 1. Start Everything

```powershell
# Terminal 1
cd c:\genaiexperiments\accountopening
.\start-local-dev.ps1

# Wait for services to start...

# Terminal 2
cd c:\genaiexperiments\accountopening\frontend\account-opening-ui
npm start
```

### 2. Create Account

1. Open http://localhost:3000
2. Click "Open New Account"
3. Fill in all 4 steps
4. Submit application
5. ✅ Success!

### 3. Verify Data in Database

```powershell
# See the customer
docker exec -it customer-db psql -U postgres -d customerdb -c "SELECT * FROM customer;"

# See the account
docker exec -it account-db psql -U postgres -d accountdb -c "SELECT * FROM account;"

# See the document
docker exec -it document-db psql -U postgres -d documentdb -c "SELECT * FROM document;"

# See the notification
docker exec -it notification-db psql -U postgres -d notificationdb -c "SELECT * FROM notification;"
```

### 4. Or Check in pgAdmin

1. Open http://localhost:5050
2. Connect to databases
3. Browse tables
4. See your data!

---

## 📚 Additional Resources

**Full Documentation:** `DOCKER_LOCAL_SETUP.md`

**Other Guides:**
- `COMPLETE_FIX_SUMMARY.md` - All fixes applied
- `CRITICAL_FIX_GUIDE.md` - Troubleshooting
- `BACKEND_STARTUP_GUIDE.md` - Service startup details

---

## 🎉 Summary

**Before:**
- ❌ No database running
- ❌ Couldn't test end-to-end
- ❌ Required PostgreSQL installation

**After:**
- ✅ 4 PostgreSQL databases in Docker
- ✅ Production-parity setup
- ✅ Easy to start/stop/reset
- ✅ pgAdmin for management
- ✅ One command to start everything
- ✅ Ready for testing!

---

## 🚀 NEXT STEPS

**Right now, do this:**

```powershell
# 1. Make sure Docker Desktop is running
docker --version

# 2. Start everything
cd c:\genaiexperiments\accountopening
.\start-local-dev.ps1

# 3. Wait for services to start (2-3 minutes)

# 4. Start frontend
cd frontend\account-opening-ui
npm start

# 5. Test!
# Open http://localhost:3000
# Create an account
# Check data in pgAdmin at http://localhost:5050
```

**That's it! You're ready for local development with real PostgreSQL! 🎉**
