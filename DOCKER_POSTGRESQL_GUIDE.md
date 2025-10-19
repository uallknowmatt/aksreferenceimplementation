# Docker PostgreSQL Quick Start Guide

This guide shows you how to run the Account Opening Application with PostgreSQL in Docker.

---

## ✅ What's Running

You now have **4 PostgreSQL databases** running in Docker containers:

| Service | Database | Port | Container |
|---------|----------|------|-----------|
| Customer Service | customerdb | 5432 | customer-db |
| Document Service | documentdb | 5433 | document-db |
| Account Service | accountdb | 5434 | account-db |
| Notification Service | notificationdb | 5435 | notification-db |

**Plus:**
- **pgAdmin** - Web-based database management tool on port 5050

---

## 🚀 Quick Start

### 1. Start PostgreSQL Databases

```powershell
cd c:\genaiexperiments\accountopening
docker compose up -d
```

**What this does:**
- Starts 4 PostgreSQL containers
- Starts pgAdmin container
- Creates Docker volumes for data persistence
- Creates Docker network for communication

**Wait for:** "✔ Container customer-db Started" (and 3 others)

### 2. Verify Databases Are Running

```powershell
docker compose ps
```

**Expected:** All containers show "Up" and "healthy"

### 3. Start Backend Services

```powershell
.\start-all-services.ps1
```

**What this does:**
- Builds all 4 microservices
- Opens 4 PowerShell windows
- Starts each service

**Wait for:** "Started CustomerServiceApplication" in each window

### 4. Start Frontend

```powershell
cd frontend\account-opening-ui
npm start
```

**Browser opens to:** http://localhost:3000

### 5. Test the Application

- Click "Open New Account"
- Complete the 4-step wizard
- Submit application
- Verify data saved

---

## 🗄️ Database Management

### Using pgAdmin (Web Interface)

1. **Open pgAdmin:**
   ```
   http://localhost:5050
   ```

2. **Login:**
   - Email: `admin@admin.com`
   - Password: `admin`

3. **Add Server Connections:**
   - Click "Add New Server"
   - General Tab: Name = "Customer DB"
   - Connection Tab:
     - Host: `customer-db`
     - Port: `5432`
     - Database: `customerdb`
     - Username: `postgres`
     - Password: `postgres`
   - Click "Save"
   
4. **Repeat for other databases:**
   - Document DB (host: `document-db`, port: 5432, database: `documentdb`)
   - Account DB (host: `account-db`, port: 5432, database: `accountdb`)
   - Notification DB (host: `notification-db`, port: 5432, database: `notificationdb`)

**Note:** Use container names (`customer-db`) not `localhost` in pgAdmin.

### Using Docker Commands

**Access database directly:**
```powershell
# Customer database
docker exec -it customer-db psql -U postgres -d customerdb

# Document database
docker exec -it document-db psql -U postgres -d documentdb

# Account database
docker exec -it account-db psql -U postgres -d accountdb

# Notification database
docker exec -it notification-db psql -U postgres -d notificationdb
```

**View tables:**
```powershell
docker exec customer-db psql -U postgres -d customerdb -c "\dt"
```

**View data:**
```powershell
docker exec customer-db psql -U postgres -d customerdb -c "SELECT * FROM customer;"
```

---

## 🛠️ Common Docker Commands

### Start/Stop All Containers

```powershell
# Start all containers
docker compose up -d

# Stop all containers
docker compose down

# Stop and remove volumes (deletes all data!)
docker compose down -v
```

### View Container Status

```powershell
# List running containers
docker compose ps

# View logs for specific container
docker compose logs customer-db

# Follow logs in real-time
docker compose logs -f customer-db

# View logs for all containers
docker compose logs
```

### Restart Containers

```powershell
# Restart all containers
docker compose restart

# Restart specific container
docker compose restart customer-db
```

### Health Checks

```powershell
# Check if database is ready
docker exec customer-db pg_isready -U postgres

# View container details
docker inspect customer-db
```

---

## 🧪 Testing Database Connections

### From Host Machine

```powershell
# Test Customer DB (port 5432)
Test-NetConnection -ComputerName localhost -Port 5432

# Test Document DB (port 5433)
Test-NetConnection -ComputerName localhost -Port 5433

# Test Account DB (port 5434)
Test-NetConnection -ComputerName localhost -Port 5434

# Test Notification DB (port 5435)
Test-NetConnection -ComputerName localhost -Port 5435
```

### From Backend Services

The services connect using these JDBC URLs:
- Customer: `jdbc:postgresql://localhost:5432/customerdb`
- Document: `jdbc:postgresql://localhost:5433/documentdb`
- Account: `jdbc:postgresql://localhost:5434/accountdb`
- Notification: `jdbc:postgresql://localhost:5435/notificationdb`

---

## 📊 Data Persistence

**Data is persisted in Docker volumes:**
- `accountopening_customer-data`
- `accountopening_document-data`
- `accountopening_account-data`
- `accountopening_notification-data`

**View volumes:**
```powershell
docker volume ls
```

**Your data survives:**
- ✅ Container restarts
- ✅ `docker compose down`
- ✅ Computer restarts

**Data is deleted when:**
- ❌ You run `docker compose down -v`
- ❌ You manually delete volumes

---

## 🔧 Troubleshooting

### Container Won't Start

```powershell
# View error logs
docker compose logs customer-db

# Check if port is already in use
netstat -ano | findstr :5432

# Kill process using port (replace PID)
taskkill /PID [PID] /F
```

### Database Connection Refused

```powershell
# Check container is running
docker compose ps

# Check health status
docker exec customer-db pg_isready -U postgres

# Restart container
docker compose restart customer-db
```

### Cannot Connect from Backend

**Check configuration:**
1. Verify `application.yml` has correct port
2. Ensure container is healthy: `docker compose ps`
3. Test connection: `Test-NetConnection -ComputerName localhost -Port 5432`

### Reset Everything

```powershell
# Stop containers and delete all data
docker compose down -v

# Remove images (force fresh download)
docker compose down --rmi all -v

# Start fresh
docker compose up -d
```

### Out of Disk Space

```powershell
# Remove unused Docker resources
docker system prune -a

# Remove specific volumes
docker volume rm accountopening_customer-data
```

---

## 🎯 Daily Workflow

### Starting Work

```powershell
# 1. Start databases
docker compose up -d

# 2. Wait for healthy status
docker compose ps

# 3. Start backend services
.\start-all-services.ps1

# 4. Start frontend
cd frontend\account-opening-ui
npm start
```

### Ending Work

```powershell
# 1. Stop frontend (Ctrl+C in terminal)

# 2. Stop backend services (close 4 PowerShell windows)

# 3. Stop databases (optional - can leave running)
docker compose down
```

---

## 📈 Performance Tips

### Optimize Docker Performance

1. **Allocate more resources to Docker Desktop:**
   - Open Docker Desktop
   - Settings → Resources
   - Increase CPUs and Memory

2. **Use WSL2 backend:**
   - Docker Desktop → Settings → General
   - Enable "Use the WSL 2 based engine"

3. **Enable file sharing:**
   - Docker Desktop → Settings → Resources → File Sharing
   - Add project directory

---

## 🔍 Monitoring

### Check Container Resources

```powershell
# View resource usage
docker stats

# View specific container
docker stats customer-db
```

### Check Database Size

```powershell
docker exec customer-db psql -U postgres -d customerdb -c "SELECT pg_size_pretty(pg_database_size('customerdb'));"
```

---

## 🚀 Next Steps

Once local testing is complete:

1. **Deploy to Azure:**
   - Use Terraform in `infrastructure/` folder
   - Switch to Azure PostgreSQL Flexible Server

2. **CI/CD:**
   - Use GitHub Actions workflows
   - Build and push Docker images
   - Deploy to AKS

---

## 📞 Need Help?

**Quick Fixes:**
```powershell
# Restart everything
docker compose restart

# View all logs
docker compose logs -f

# Check service health
.\check-services.ps1
```

**Documentation:**
- [QUICK_START.md](QUICK_START.md) - Complete setup guide
- [CRITICAL_FIX_GUIDE.md](CRITICAL_FIX_GUIDE.md) - Troubleshooting
- [README.md](README.md) - Project overview

---

## ✅ Success Checklist

- [ ] Docker Desktop installed and running
- [ ] `docker compose up -d` completes successfully
- [ ] All 5 containers show "healthy" status
- [ ] Can access pgAdmin at http://localhost:5050
- [ ] All 4 backend services start without errors
- [ ] Frontend loads at http://localhost:3000
- [ ] Can complete account opening wizard
- [ ] Data persists after container restart

---

**Document Version:** 1.0  
**Last Updated:** October 2025  
**Docker Compose Version:** 2.40.0  
**PostgreSQL Version:** 15-alpine
