# 🚀 Quick Start Guide - Account Opening Application

This guide will get your complete account opening application running locally in under 10 minutes.

---

## 📋 Prerequisites Check

Before starting, verify you have:
- ✅ Java 17 or higher
- ✅ Maven 3.6+
- ✅ Node.js 14+ and npm
- ⚠️ PostgreSQL 15 (if not installed, follow setup below)

**Check your versions:**
```powershell
java -version
mvn -version
node -version
```

---

## 🗄️ Database Setup (One-Time)

### Option 1: Quick Install (Recommended)

**1. Download PostgreSQL for Windows:**
- Visit: https://www.postgresql.org/download/windows/
- Download PostgreSQL 15 installer
- Run installer

**2. During Installation:**
- Set password: `postgres` (or remember your custom password)
- Port: `5432` (default)
- Install all components including **pgAdmin**

**3. Create Databases:**
```powershell
cd c:\genaiexperiments\accountopening
.\setup-databases.ps1
```

✅ **That's it!** Four databases will be created automatically.

### Option 2: Manual Setup

If the script doesn't work, create databases manually:

```powershell
# Open psql
psql -U postgres

# Create databases
CREATE DATABASE customerdb;
CREATE DATABASE documentdb;
CREATE DATABASE accountdb;
CREATE DATABASE notificationdb;

# Exit
\q
```

### Verify Database Setup

```powershell
# Check PostgreSQL service
Get-Service postgresql*

# List databases
psql -U postgres -c "\l"
```

**Expected Output:** You should see customerdb, documentdb, accountdb, and notificationdb listed.

---

## 🏃 Running the Application

### Step 1: Start Backend Services

```powershell
cd c:\genaiexperiments\accountopening
.\start-all-services.ps1
```

**What happens:**
- Checks PostgreSQL is running
- Builds all 4 microservices
- Opens 4 PowerShell windows (one per service)
- Each service starts on its own port

**Wait for these messages in each window:**
```
Started CustomerServiceApplication in X seconds
Started DocumentServiceApplication in X seconds
Started AccountServiceApplication in X seconds
Started NotificationServiceApplication in X seconds
```

**Service Ports:**
- Customer Service: http://localhost:8081
- Document Service: http://localhost:8082
- Account Service: http://localhost:8083
- Notification Service: http://localhost:8084

### Step 2: Start Frontend

Open a **NEW** PowerShell window:

```powershell
cd c:\genaiexperiments\accountopening\frontend\account-opening-ui
npm start
```

**What happens:**
- Frontend builds and starts
- Browser opens automatically to http://localhost:3000
- Hot-reload is enabled (changes appear automatically)

---

## ✅ Testing the Application

### End-to-End Test Flow

**1. Open Application:**
- Navigate to http://localhost:3000
- Click "Open New Account"

**2. Complete Wizard Steps:**

**Step 1 - Customer Information:**
- First Name: `John`
- Last Name: `Doe`
- Email: `john.doe@example.com`
- Phone: `555-0123`
- Address: `123 Main St, City, State 12345`
- Date of Birth: Select any date
- Click "Next"

**Step 2 - Document Upload:**
- Click "Choose File"
- Select any PDF, JPG, or PNG file
- Verify file appears in the list
- Click "Next"

**Step 3 - Account Details:**
- Account Type: Select "Savings" or "Checking"
- Initial Deposit: `1000`
- Branch: `Main Branch`
- Click "Next"

**Step 4 - Review:**
- Verify all information is correct
- Click "Submit Application"

**Expected Success:**
```
✅ Application submitted successfully!
Application ID: [UUID]
```

### Verify Data Was Saved

**Option 1: Using pgAdmin (Visual Interface)**
1. Open pgAdmin (installed with PostgreSQL)
2. Connect to localhost server
3. Navigate: Databases → customerdb → Schemas → public → Tables
4. Right-click "customer" → View/Edit Data → All Rows
5. You should see John Doe's record

**Option 2: Using psql (Command Line)**
```powershell
# View customers
psql -U postgres -d customerdb -c "SELECT * FROM customer;"

# View accounts
psql -U postgres -d accountdb -c "SELECT * FROM account;"

# View documents
psql -U postgres -d documentdb -c "SELECT * FROM document;"

# View notifications
psql -U postgres -d notificationdb -c "SELECT * FROM notification;"
```

### Test Other Pages

**View Existing Data:**
- Click "Customers" in navigation → See all customers
- Click "Accounts" → See all accounts
- Click "Documents" → See all documents
- Click "Notifications" → See notification history

---

## 🛠️ Common Issues and Solutions

### PostgreSQL Not Running

**Symptom:** Backend services fail to start with connection errors

**Solution:**
```powershell
# Check status
Get-Service postgresql*

# Start if stopped
Start-Service postgresql-x64-15  # Adjust name if different

# Or restart PostgreSQL
Restart-Service postgresql-x64-15
```

### Port Already in Use

**Symptom:** "Port 8081 already in use" errors

**Solution:**
```powershell
# Find process using port
netstat -ano | findstr :8081

# Kill process (use PID from above)
taskkill /PID [PID] /F
```

### "psql is not recognized"

**Symptom:** Cannot run psql commands

**Solution:** Add PostgreSQL to PATH:
```powershell
# Temporary fix (this session only)
$env:Path += ";C:\Program Files\PostgreSQL\15\bin"

# Permanent fix: Add to System Environment Variables
# Search Windows: "Environment Variables"
# Edit Path → Add: C:\Program Files\PostgreSQL\15\bin
```

### Frontend Can't Connect to Backend

**Symptom:** "Failed to load customers" or network errors

**Solution:**
1. Verify all 4 backend services are running
2. Check console for startup messages
3. Test endpoints directly:
   ```powershell
   curl http://localhost:8081/api/customers
   curl http://localhost:8082/api/documents
   curl http://localhost:8083/api/accounts
   curl http://localhost:8084/api/notifications
   ```

### Database Authentication Failed

**Symptom:** "password authentication failed for user postgres"

**Solution:** Reset password or update application.yml files:

**Reset Password:**
```powershell
# Edit pg_hba.conf to temporarily allow all connections
# Location: C:\Program Files\PostgreSQL\15\data\pg_hba.conf
# Change "md5" to "trust" for local connections
# Restart PostgreSQL
# Reset password:
psql -U postgres -c "ALTER USER postgres PASSWORD 'postgres';"
# Change "trust" back to "md5"
# Restart PostgreSQL
```

---

## 🧪 Running Tests

### Backend Tests

```powershell
# Run all tests
cd c:\genaiexperiments\accountopening
mvn test

# Run tests for specific service
cd customer-service
mvn test

# Run with coverage
mvn test jacoco:report
```

**Expected:** 123/123 tests passing

### Frontend Tests

```powershell
cd frontend\account-opening-ui
npm test
```

**Expected:** 78/78 checks passing

---

## 📊 Checking Service Health

### Use the Health Check Script

```powershell
cd c:\genaiexperiments\accountopening
.\check-services.ps1
```

**Expected Output:**
```
Customer Service: ✅ Running (http://localhost:8081)
Document Service: ✅ Running (http://localhost:8082)
Account Service: ✅ Running (http://localhost:8083)
Notification Service: ✅ Running (http://localhost:8084)
Frontend: ✅ Running (http://localhost:3000)
PostgreSQL: ✅ Running
```

---

## 🧹 Cleanup and Reset

### Stop All Services

**Close All PowerShell Windows** (4 backend services + 1 frontend)

Or use Ctrl+C in each terminal

### Reset Databases

```powershell
# Drop and recreate all databases
psql -U postgres

DROP DATABASE IF EXISTS customerdb;
DROP DATABASE IF EXISTS documentdb;
DROP DATABASE IF EXISTS accountdb;
DROP DATABASE IF EXISTS notificationdb;

CREATE DATABASE customerdb;
CREATE DATABASE documentdb;
CREATE DATABASE accountdb;
CREATE DATABASE notificationdb;

\q
```

### Clean Build Artifacts

```powershell
cd c:\genaiexperiments\accountopening
mvn clean

cd frontend\account-opening-ui
rm -r -force node_modules
rm -r -force build
npm install
```

---

## 🌐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Browser (localhost:3000)                 │
│                     React Frontend with Material-UI              │
└────────────┬────────────────────────────────────────────────────┘
             │ HTTP REST API Calls
             │
    ┌────────┴─────────┬──────────────┬──────────────┐
    │                  │              │              │
┌───▼───┐         ┌───▼───┐      ┌───▼───┐      ┌───▼────┐
│:8081  │         │:8082  │      │:8083  │      │:8084   │
│Customer│        │Document│     │Account│      │Notific │
│Service │        │Service │     │Service│      │Service │
└───┬───┘         └───┬───┘      └───┬───┘      └───┬────┘
    │                 │              │              │
    │                 │              │              │
┌───▼─────────────────▼──────────────▼──────────────▼────┐
│         PostgreSQL (localhost:5432)                     │
│  ┌──────────┐  ┌──────────┐  ┌─────────┐  ┌─────────┐ │
│  │customerdb│  │documentdb│  │accountdb│  │notifdb  │ │
│  └──────────┘  └──────────┘  └─────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Key Points:**
- Each microservice has its own database
- All databases run in single PostgreSQL instance
- Frontend communicates with each service independently
- CORS enabled for localhost:3000

---

## 📚 Additional Documentation

For more detailed information, see:

- **POSTGRESQL_WINDOWS_SETUP.md** - Complete PostgreSQL setup guide with troubleshooting
- **COMPLETE_FIX_SUMMARY.md** - All fixes applied to the application
- **CRITICAL_FIX_GUIDE.md** - Detailed troubleshooting for backend/frontend issues
- **FRONTEND_README.md** - Frontend-specific documentation
- **BACKEND_STARTUP_GUIDE.md** - Backend service details

---

## 🎯 Success Checklist

Before considering setup complete, verify:

- [ ] PostgreSQL 15 installed and running
- [ ] Four databases created (customerdb, documentdb, accountdb, notificationdb)
- [ ] All 4 backend services start without errors
- [ ] Frontend starts and loads at http://localhost:3000
- [ ] Can complete account opening wizard end-to-end
- [ ] Can view data in Customers, Accounts, Documents, and Notifications pages
- [ ] Data persists in PostgreSQL (visible in pgAdmin or psql)
- [ ] All 123 backend tests pass
- [ ] All 78 frontend checks pass

---

## 🚀 Next Steps - Cloud Deployment

Once local testing is complete, deploy to Azure:

1. **Azure PostgreSQL Flexible Server**
   - Create in Azure Portal
   - Update connection strings in application.yml files
   - Configure firewall rules

2. **Backend Deployment Options:**
   - Azure App Service (easiest)
   - Azure Kubernetes Service (scalable)
   - Azure Container Instances

3. **Frontend Deployment:**
   - Azure Static Web Apps
   - Update API URLs to point to Azure backend

4. **CI/CD:**
   - GitHub Actions workflows already exist
   - Update for Azure deployment targets

---

## 📞 Need Help?

If you encounter issues not covered here:

1. Check **POSTGRESQL_WINDOWS_SETUP.md** for database issues
2. Check **CRITICAL_FIX_GUIDE.md** for application errors
3. View logs in each service's PowerShell window
4. Check browser console for frontend errors (F12)
5. Verify PostgreSQL logs: `C:\Program Files\PostgreSQL\15\data\pg_log\`

---

**Last Updated:** December 2024
**Application Version:** 1.0.0-SNAPSHOT
**PostgreSQL Version:** 15
**Java Version:** 17
**Node Version:** 14+
