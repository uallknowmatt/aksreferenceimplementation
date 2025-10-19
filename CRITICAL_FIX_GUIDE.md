# CRITICAL FIXES APPLIED - Backend API Configuration

## 🔴 ROOT CAUSE IDENTIFIED

**Problem:** Frontend was calling `http://localhost:8080` (single port) but backend services run on **4 different ports**:
- Customer Service: Port 8081
- Document Service: Port 8082
- Account Service: Port 8083
- Notification Service: Port 8084

**Additional Issues Found:**
1. ❌ CORS not configured - browsers block cross-origin requests
2. ❌ Missing `GET /api/customers` endpoint (only had GET by ID)
3. ❌ Missing `GET /api/documents` endpoint
4. ❌ Missing `GET /api/accounts` endpoint

---

## ✅ FIXES APPLIED

### 1. Frontend API Configuration Fixed

**File:** `src/services/api.js`

**Before:**
```javascript
const API_BASE_URL = 'http://localhost:8080'; // ❌ Wrong port!
```

**After:**
```javascript
const CUSTOMER_SERVICE_URL = 'http://localhost:8081';  // ✅
const DOCUMENT_SERVICE_URL = 'http://localhost:8082';   // ✅
const ACCOUNT_SERVICE_URL = 'http://localhost:8083';    // ✅
const NOTIFICATION_SERVICE_URL = 'http://localhost:8084'; // ✅
```

Now each API call goes to the correct service!

---

### 2. CORS Configuration Added

Added `@CrossOrigin` to all controllers to allow browser requests:

**Files Modified:**
- ✅ `CustomerController.java`
- ✅ `DocumentController.java`
- ✅ `AccountController.java`
- ✅ `NotificationController.java`

**CORS Configuration:**
```java
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001"}, 
             allowedHeaders = "*",
             methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
```

This allows your React app (port 3000) to call backend services (ports 8081-8084).

---

### 3. Missing Endpoints Added

#### Customer Service
**Added:**
- `GET /api/customers` - Get all customers

**Files:**
- ✅ `CustomerService.java` - Added `getAllCustomers()` method
- ✅ `CustomerController.java` - Added `@GetMapping` endpoint

#### Document Service
**Added:**
- `GET /api/documents` - Get all documents

**Files:**
- ✅ `DocumentService.java` - Added `getAllDocuments()` method
- ✅ `DocumentController.java` - Added `@GetMapping` endpoint

#### Account Service
**Added:**
- `GET /api/accounts` - Get all accounts

**Files:**
- ✅ `AccountService.java` - Added `getAllAccounts()` method
- ✅ `AccountController.java` - Added `@GetMapping` endpoint

---

## 🚀 HOW TO TEST THE FIXES

### Step 1: Rebuild Backend Services

Since we modified Java code, you MUST recompile and restart all services:

```powershell
# Navigate to project root
cd c:\genaiexperiments\accountopening

# Clean and compile all services
mvn clean install -DskipTests

# OR rebuild each service individually:
cd customer-service
mvn clean install -DskipTests

cd ../document-service
mvn clean install -DskipTests

cd ../account-service
mvn clean install -DskipTests

cd ../notification-service
mvn clean install -DskipTests
```

---

### Step 2: Ensure Database is Running

**If using PostgreSQL:**

```powershell
# Check if PostgreSQL is running
Get-Service -Name postgresql*

# If not running, start it:
Start-Service -Name postgresql-x64-14  # Adjust version number

# Verify PostgreSQL is listening on port 5432
netstat -ano | findstr :5432
```

**Create Required Databases:**

```sql
-- Connect to PostgreSQL (use pgAdmin or psql)
CREATE DATABASE customerdb;
CREATE DATABASE documentdb;
CREATE DATABASE accountdb;
CREATE DATABASE notificationdb;
```

**If using H2 (In-Memory):**
No setup needed - services will create H2 databases automatically.

---

### Step 3: Start All Backend Services

Open 4 separate PowerShell terminals:

#### Terminal 1: Customer Service
```powershell
cd c:\genaiexperiments\accountopening\customer-service
mvn spring-boot:run
```
✅ Wait for: `Started CustomerServiceApplication in X seconds`

#### Terminal 2: Document Service
```powershell
cd c:\genaiexperiments\accountopening\document-service
mvn spring-boot:run
```
✅ Wait for: `Started DocumentServiceApplication in X seconds`

#### Terminal 3: Account Service
```powershell
cd c:\genaiexperiments\accountopening\account-service
mvn spring-boot:run
```
✅ Wait for: `Started AccountServiceApplication in X seconds`

#### Terminal 4: Notification Service
```powershell
cd c:\genaiexperiments\accountopening\notification-service
mvn spring-boot:run
```
✅ Wait for: `Started NotificationServiceApplication in X seconds`

---

### Step 4: Verify Services Are Running

```powershell
# Check all ports are listening
netstat -ano | findstr "8081 8082 8083 8084"

# You should see 4 lines showing LISTENING on each port
```

**Test Each Service:**

```powershell
# Customer Service
Invoke-RestMethod -Uri "http://localhost:8081/api/customers" -Method Get

# Document Service
Invoke-RestMethod -Uri "http://localhost:8082/api/documents" -Method Get

# Account Service
Invoke-RestMethod -Uri "http://localhost:8083/api/accounts" -Method Get

# Notification Service
Invoke-RestMethod -Uri "http://localhost:8084/api/notifications" -Method Get
```

All should return `[]` (empty array) if database is empty, NOT an error.

---

### Step 5: Restart React App

The React app needs to reload to use the new API configuration:

```powershell
# If React is running, stop it (Ctrl+C in its terminal)
cd c:\genaiexperiments\accountopening\frontend\account-opening-ui

# Start it again
npm start
```

Or if you closed the terminal, just double-click `start.bat`

---

### Step 6: Test Complete Flow

1. **Open Browser:** http://localhost:3000

2. **Test Customer List:**
   - Click "Customers" in navigation
   - Should see "No customers found" (not an error!)
   - ✅ This confirms backend is connected

3. **Create New Account:**
   - Click "Open New Account"
   - Fill in Step 1 (Customer Info):
     - First Name: John
     - Last Name: Doe
     - Email: john.doe@example.com
     - Phone: +1234567890
     - Date of Birth: 1990-01-01
     - Address: 123 Main St
   - Click "Next"
   
   - Fill in Step 2 (Documents):
     - Select "Passport"
     - Choose any file (image or PDF)
     - Click "Add Document"
     - ✅ Document appears in list
     - Click "Next"
   
   - Fill in Step 3 (Account Details):
     - Account Type: Savings Account
     - Initial Deposit: 1000
     - Click "Next"
   
   - Step 4 (Review):
     - Verify all information
     - Click "Submit Application"
     - ✅ Should show success message!

4. **Verify Data Created:**
   - Go to "Customers" → John Doe should appear
   - Go to "Accounts" → New account should appear
   - Go to "Documents" → Uploaded passport should appear
   - Go to "Notifications" → Welcome email should appear

---

## 🐛 TROUBLESHOOTING

### Issue: "Failed to load customers" Error

**Check:**
1. Are all 4 backend services running?
   ```powershell
   netstat -ano | findstr "8081 8082 8083 8084"
   ```

2. Check service logs for errors (look in each terminal window)

3. Test direct API call:
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:8081/api/customers"
   ```

---

### Issue: "Network Error" or "ERR_CONNECTION_REFUSED"

**Cause:** Backend service isn't running on that port

**Solution:**
- Verify service started successfully (no errors in terminal)
- Check port isn't already in use:
  ```powershell
  netstat -ano | findstr :8081  # Check specific port
  ```
- If port in use, kill the process:
  ```powershell
  taskkill /PID <PID> /F
  ```

---

### Issue: Database Connection Errors in Backend Logs

**Error:** `org.postgresql.util.PSQLException: Connection refused`

**Solution 1 - Use H2 Instead:**

Edit each service's `application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
```

**Solution 2 - Fix PostgreSQL:**
1. Ensure PostgreSQL is running
2. Create databases (see Step 2 above)
3. Verify connection in `application.yml`:
   ```yaml
   datasource:
     url: jdbc:postgresql://localhost:5432/customerdb
     username: postgres
     password: yourpassword  # Update this!
   ```

---

### Issue: CORS Errors in Browser Console

**Error:** `Access to XMLHttpRequest blocked by CORS policy`

**Cause:** Old backend code is still running (before CORS fix)

**Solution:**
1. Stop ALL backend services (Ctrl+C in each terminal)
2. Rebuild: `mvn clean install -DskipTests`
3. Restart all services
4. Refresh browser

---

### Issue: React App Shows Old API URLs

**Solution:**
1. Stop React app (Ctrl+C)
2. Delete `.env.local` if it exists
3. Verify `.env` has correct ports
4. Restart: `npm start`
5. Hard refresh browser: Ctrl+Shift+R

---

## 📊 VERIFICATION CHECKLIST

Before testing, verify:

- [ ] All 4 backend services rebuilt with `mvn clean install`
- [ ] PostgreSQL running OR services configured for H2
- [ ] All 4 services started (look for "Started...Application" message)
- [ ] All 4 ports listening (8081, 8082, 8083, 8084)
- [ ] Direct API calls return `[]` not errors
- [ ] React app restarted after `.env` changes
- [ ] Browser cache cleared (Ctrl+Shift+R)
- [ ] No CORS errors in browser console

---

## 🎯 EXPECTED RESULTS

**After These Fixes:**

✅ Frontend calls correct service ports (8081-8084)  
✅ CORS allows browser to make requests  
✅ All GET endpoints exist and work  
✅ Customer list loads (empty or with data)  
✅ Account opening wizard completes successfully  
✅ Data persists in database  
✅ All pages display data correctly  

---

## 📝 FILES CHANGED SUMMARY

### Frontend (3 files)
1. `src/services/api.js` - Multi-port API configuration
2. `.env` - Service URL configuration
3. `src/pages/CustomerList.js` - Better error messages (from previous fix)

### Backend - Customer Service (2 files)
1. `CustomerController.java` - Added CORS, GET all endpoint
2. `CustomerService.java` - Added getAllCustomers() method

### Backend - Document Service (2 files)
1. `DocumentController.java` - Added CORS, GET all endpoint
2. `DocumentService.java` - Added getAllDocuments() method

### Backend - Account Service (2 files)
1. `AccountController.java` - Added CORS, GET all endpoint
2. `AccountService.java` - Added getAllAccounts() method

### Backend - Notification Service (1 file)
1. `NotificationController.java` - Added CORS (already had GET all)

**Total: 10 files modified**

---

## 🚀 NEXT STEPS

1. **Rebuild backend** - Run `mvn clean install -DskipTests`
2. **Start database** - PostgreSQL or use H2
3. **Start all 4 services** - Wait for each to fully start
4. **Restart React app** - Load new API configuration
5. **Test complete flow** - Create account end-to-end
6. **Celebrate!** 🎉

---

**All critical issues are now fixed! The application should work end-to-end once you rebuild and restart the backend services.** 🚀
