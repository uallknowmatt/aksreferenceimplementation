# 🚀 PostgreSQL for Windows - Quick Setup (No Docker Required!)

## Why This Approach?

✅ **No Virtualization Required** - Works on any Windows machine  
✅ **No Docker Desktop Needed** - Native Windows installation  
✅ **Production Parity** - Still using real PostgreSQL  
✅ **Quick Setup** - Install once, ready to go  
✅ **Single Instance** - One PostgreSQL with multiple databases  

---

## 📥 Step 1: Install PostgreSQL for Windows

### Option A: Using Installer (Recommended)

1. **Download PostgreSQL 15 for Windows**
   - URL: https://www.postgresql.org/download/windows/
   - Or direct: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
   - Choose: **PostgreSQL 15.x** for Windows x86-64

2. **Run the Installer**
   - Double-click the downloaded `.exe` file
   - Click "Next" through the wizard

3. **Installation Settings:**
   - **Installation Directory:** Default is fine (`C:\Program Files\PostgreSQL\15`)
   - **Components:** Select all (PostgreSQL Server, pgAdmin, Command Line Tools)
   - **Data Directory:** Default is fine
   - **Password:** Enter `postgres` (or remember your password!)
   - **Port:** Keep default `5432`
   - **Locale:** Default

4. **Complete Installation**
   - Click "Next" through remaining screens
   - Uncheck "Stack Builder" at the end
   - Click "Finish"

### Option B: Using Chocolatey (If you have it)

```powershell
choco install postgresql15 -y
```

---

## ✅ Step 2: Verify PostgreSQL is Running

### Check Service Status

```powershell
# Check if PostgreSQL service is running
Get-Service -Name postgresql*

# Should show "Running"
```

### Test Connection

```powershell
# Open PowerShell and test
psql -U postgres -c "SELECT version();"

# If prompted for password, enter: postgres
```

**If `psql` command not found:**
```powershell
# Add to PATH temporarily
$env:PATH += ";C:\Program Files\PostgreSQL\15\bin"

# Test again
psql -U postgres -c "SELECT version();"
```

---

## 🗄️ Step 3: Create All Required Databases

### Option A: Using Script (Automated)

Run this PowerShell script:

```powershell
cd c:\genaiexperiments\accountopening
.\setup-databases.ps1
```

### Option B: Manual Creation

Open PowerShell and run:

```powershell
# Set PATH
$env:PATH += ";C:\Program Files\PostgreSQL\15\bin"

# Create databases
psql -U postgres -c "CREATE DATABASE customerdb;"
psql -U postgres -c "CREATE DATABASE documentdb;"
psql -U postgres -c "CREATE DATABASE accountdb;"
psql -U postgres -c "CREATE DATABASE notificationdb;"

# Verify
psql -U postgres -c "\l"
```

You should see all 4 databases listed!

---

## 🔧 Step 4: Update Application Configuration

**Good news:** I've already updated the configuration files!

All services now connect to `localhost:5432` with different databases:

| Service | Database | Port |
|---------|----------|------|
| Customer Service | customerdb | 5432 |
| Document Service | documentdb | 5432 |
| Account Service | accountdb | 5432 |
| Notification Service | notificationdb | 5432 |

**Note:** All use the same PostgreSQL instance on port 5432, just different databases.

---

## 🚀 Step 5: Start Everything

### 1. Verify PostgreSQL is Running

```powershell
Get-Service -Name postgresql*
```

Should show "Running". If not:

```powershell
Start-Service -Name postgresql-x64-15  # Adjust version number if needed
```

### 2. Start Backend Services

```powershell
cd c:\genaiexperiments\accountopening
.\start-all-services.ps1
```

This opens 4 terminal windows for the services.

**Wait for each to show:** `Started [ServiceName]Application in X seconds`

### 3. Start Frontend

```powershell
cd c:\genaiexperiments\accountopening\frontend\account-opening-ui
npm start
```

### 4. Test!

Open http://localhost:3000

---

## 🗄️ Managing Databases

### Using pgAdmin (GUI)

PostgreSQL installation includes pgAdmin:

1. **Open pgAdmin 4** from Start Menu
2. **Connect to Server:**
   - Host: localhost
   - Port: 5432
   - Username: postgres
   - Password: postgres (or what you set during installation)
3. **Browse Databases:**
   - Expand "Servers" → "PostgreSQL 15" → "Databases"
   - You'll see: customerdb, documentdb, accountdb, notificationdb

### Using Command Line (psql)

```powershell
# Set PATH
$env:PATH += ";C:\Program Files\PostgreSQL\15\bin"

# Connect to a database
psql -U postgres -d customerdb

# Inside psql:
\dt                    # List tables
SELECT * FROM customer; # Query data
\q                     # Quit
```

### View All Data

```powershell
# Customer data
psql -U postgres -d customerdb -c "SELECT * FROM customer;"

# Account data
psql -U postgres -d accountdb -c "SELECT * FROM account;"

# Document data
psql -U postgres -d documentdb -c "SELECT * FROM document;"

# Notification data
psql -U postgres -d notificationdb -c "SELECT * FROM notification;"
```

---

## 🔄 Reset Databases (Clear All Data)

```powershell
$env:PATH += ";C:\Program Files\PostgreSQL\15\bin"

# Drop and recreate databases
psql -U postgres -c "DROP DATABASE IF EXISTS customerdb;"
psql -U postgres -c "DROP DATABASE IF EXISTS documentdb;"
psql -U postgres -c "DROP DATABASE IF EXISTS accountdb;"
psql -U postgres -c "DROP DATABASE IF EXISTS notificationdb;"

psql -U postgres -c "CREATE DATABASE customerdb;"
psql -U postgres -c "CREATE DATABASE documentdb;"
psql -U postgres -c "CREATE DATABASE accountdb;"
psql -U postgres -c "CREATE DATABASE notificationdb;"
```

---

## 🐛 Troubleshooting

### "psql is not recognized"

**Solution:** Add PostgreSQL to PATH:

**Permanent:**
1. Search Windows for "Environment Variables"
2. Edit "System Variables" → "Path"
3. Add: `C:\Program Files\PostgreSQL\15\bin`
4. Click OK, restart PowerShell

**Temporary (each PowerShell session):**
```powershell
$env:PATH += ";C:\Program Files\PostgreSQL\15\bin"
```

### "Password authentication failed"

**Solution:** Reset password:
1. Find `pg_hba.conf` file (usually in `C:\Program Files\PostgreSQL\15\data`)
2. Change `md5` to `trust` for localhost connections
3. Restart PostgreSQL service
4. Connect and change password:
   ```sql
   psql -U postgres -c "ALTER USER postgres PASSWORD 'postgres';"
   ```
5. Change `trust` back to `md5` in pg_hba.conf
6. Restart service again

### "Connection refused"

**Solution:** Start PostgreSQL service:
```powershell
Start-Service -Name postgresql-x64-15
```

### "Database does not exist"

**Solution:** Create the databases:
```powershell
.\setup-databases.ps1
```

---

## 📊 Database Schema

Tables are created automatically by Hibernate/JPA when services start.

After starting services and creating an account, you'll have:

**customerdb:**
- `customer` table (id, first_name, last_name, email, phone, address, etc.)

**documentdb:**
- `document` table (id, customer_id, file_name, type, content, etc.)

**accountdb:**
- `account` table (id, customer_id, account_number, balance, type, etc.)

**notificationdb:**
- `notification` table (id, recipient, message, type, status, etc.)

---

## ✅ Advantages Over Docker (For Your Case)

| Feature | Docker | Native PostgreSQL |
|---------|--------|-------------------|
| Requires Virtualization | ❌ **Yes** | ✅ **No** |
| Works Immediately | ❌ No (BIOS change) | ✅ **Yes** |
| Production Parity | ✅ Yes | ✅ **Yes** |
| Performance | ⚠️ Slower | ✅ **Faster** |
| Persistent Data | ✅ Yes | ✅ **Yes** |
| Easy Management | ⚠️ Docker commands | ✅ **Native tools** |
| pgAdmin | ✅ Yes | ✅ **Yes (included)** |

---

## 🎯 Complete Test Workflow

### 1. Verify PostgreSQL Running

```powershell
Get-Service -Name postgresql*
```

### 2. Verify Databases Exist

```powershell
$env:PATH += ";C:\Program Files\PostgreSQL\15\bin"
psql -U postgres -c "\l"
```

Should list customerdb, documentdb, accountdb, notificationdb

### 3. Start Services

```powershell
cd c:\genaiexperiments\accountopening
.\start-all-services.ps1
```

### 4. Start Frontend

```powershell
cd frontend\account-opening-ui
npm start
```

### 5. Create Account

1. Open http://localhost:3000
2. Complete account opening wizard
3. Submit application
4. ✅ Success!

### 6. Verify Data in PostgreSQL

```powershell
# Check customer created
psql -U postgres -d customerdb -c "SELECT first_name, last_name, email FROM customer;"

# Check account created
psql -U postgres -d accountdb -c "SELECT account_number, account_type, balance FROM account;"

# Check document uploaded
psql -U postgres -d documentdb -c "SELECT file_name, type FROM document;"

# Check notification sent
psql -U postgres -d notificationdb -c "SELECT recipient, type, status FROM notification;"
```

---

## 📝 Quick Commands Reference

```powershell
# Set PATH (run once per PowerShell session)
$env:PATH += ";C:\Program Files\PostgreSQL\15\bin"

# Check PostgreSQL service
Get-Service postgresql*

# Start PostgreSQL (if not running)
Start-Service postgresql-x64-15

# Create databases
.\setup-databases.ps1

# Start backend
.\start-all-services.ps1

# Check services
.\check-services.ps1

# View data
psql -U postgres -d customerdb -c "SELECT * FROM customer;"

# Open pgAdmin
# Search "pgAdmin" in Start Menu
```

---

## 🎉 Summary

**You now have:**
- ✅ Native PostgreSQL for Windows (no Docker needed)
- ✅ No virtualization required
- ✅ Same production database (PostgreSQL)
- ✅ All 4 databases created
- ✅ pgAdmin for visual management
- ✅ Fast, native performance
- ✅ Ready to test end-to-end!

**Next:** Run `.\setup-databases.ps1` then start testing! 🚀
