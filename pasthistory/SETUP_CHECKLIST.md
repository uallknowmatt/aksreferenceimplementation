# 🎯 Setup Checklist - Account Opening Application

Use this checklist to track your progress setting up the application.

---

## 📋 Prerequisites

- [ ] Java 17 or higher installed
- [ ] Maven 3.6+ installed
- [ ] Node.js 14+ and npm installed
- [ ] Git installed (optional)
- [ ] VS Code or preferred IDE installed

**Verify with:**
```powershell
java -version
mvn -version
node -version
```

---

## 🗄️ Database Setup

### Install PostgreSQL

- [ ] Downloaded PostgreSQL 15 from https://www.postgresql.org/download/windows/
- [ ] Ran installer
- [ ] Set password to `postgres` (or noted custom password)
- [ ] Kept default port `5432`
- [ ] Installed all components including pgAdmin
- [ ] PostgreSQL service is running

**Verify with:**
```powershell
Get-Service postgresql*
# Should show "Running"
```

### Create Databases

- [ ] Opened PowerShell in project directory
- [ ] Ran `.\setup-databases.ps1`
- [ ] Saw "✅ Database [name] created successfully" for all 4 databases
- [ ] Verified databases exist

**Verify with:**
```powershell
psql -U postgres -c "\l"
# Should see: customerdb, documentdb, accountdb, notificationdb
```

---

## 🔧 Backend Setup

### Build Services

- [ ] Opened PowerShell in project root
- [ ] Ran `mvn clean compile -DskipTests`
- [ ] Build completed successfully
- [ ] No error messages

### Start Services

- [ ] Ran `.\start-all-services.ps1`
- [ ] Four PowerShell windows opened (one per service)
- [ ] Waited for startup messages in each window
- [ ] Saw "Started CustomerServiceApplication" in window 1
- [ ] Saw "Started DocumentServiceApplication" in window 2
- [ ] Saw "Started AccountServiceApplication" in window 3
- [ ] Saw "Started NotificationServiceApplication" in window 4

**Verify with:**
```powershell
.\check-services.ps1
# Should show all services ✅ Running
```

**Or test manually:**
```powershell
curl http://localhost:8081/api/customers
curl http://localhost:8082/api/documents
curl http://localhost:8083/api/accounts
curl http://localhost:8084/api/notifications
```

---

## 🎨 Frontend Setup

### Install Dependencies

- [ ] Opened new PowerShell window
- [ ] Changed to frontend directory: `cd frontend\account-opening-ui`
- [ ] Ran `npm install`
- [ ] Installation completed without errors

### Start Frontend

- [ ] Ran `npm start`
- [ ] Saw "Compiled successfully!"
- [ ] Browser opened automatically to http://localhost:3000
- [ ] Application loaded without errors

**Verify with:**
- [ ] Can see navigation bar
- [ ] Can see "Open New Account" button
- [ ] No errors in browser console (F12)

---

## ✅ End-to-End Testing

### Create Account Wizard

- [ ] Clicked "Open New Account" button
- [ ] Step 1 - Customer Information:
  - [ ] Entered First Name: `John`
  - [ ] Entered Last Name: `Doe`
  - [ ] Entered Email: `john.doe@example.com`
  - [ ] Entered Phone: `555-0123`
  - [ ] Entered Address: `123 Main St, City, State 12345`
  - [ ] Selected Date of Birth
  - [ ] Clicked "Next"
  
- [ ] Step 2 - Document Upload:
  - [ ] Clicked "Choose File"
  - [ ] Selected a PDF, JPG, or PNG file
  - [ ] Saw file appear in list below
  - [ ] Clicked "Next"
  
- [ ] Step 3 - Account Details:
  - [ ] Selected Account Type (Savings or Checking)
  - [ ] Entered Initial Deposit: `1000`
  - [ ] Entered Branch: `Main Branch`
  - [ ] Clicked "Next"
  
- [ ] Step 4 - Review:
  - [ ] Verified all information correct
  - [ ] Clicked "Submit Application"
  - [ ] Saw success message
  - [ ] Saw Application ID displayed

### View Created Data

- [ ] Clicked "Customers" in navigation
- [ ] Saw John Doe in the list
- [ ] Verified customer details displayed correctly

- [ ] Clicked "Accounts" in navigation
- [ ] Saw new account in the list
- [ ] Verified account details displayed correctly

- [ ] Clicked "Documents" in navigation
- [ ] Saw uploaded document in the list
- [ ] Verified document details displayed correctly

- [ ] Clicked "Notifications" in navigation
- [ ] Saw notification in the list

### Verify Data Persistence

**Option 1: Using pgAdmin**
- [ ] Opened pgAdmin (Start → PostgreSQL 15 → pgAdmin 4)
- [ ] Connected to localhost server
- [ ] Expanded Databases → customerdb → Schemas → public → Tables
- [ ] Right-clicked "customer" → View/Edit Data → All Rows
- [ ] Saw John Doe's record with all details

**Option 2: Using psql**
```powershell
# View customers
psql -U postgres -d customerdb -c "SELECT * FROM customer;"
# Should see John Doe

# View accounts
psql -U postgres -d accountdb -c "SELECT * FROM account;"
# Should see new account

# View documents
psql -U postgres -d documentdb -c "SELECT * FROM document;"
# Should see uploaded document

# View notifications
psql -U postgres -d notificationdb -c "SELECT * FROM notification;"
# Should see notification
```

- [ ] Saw data in all 4 databases
- [ ] Data matches what was entered in the wizard

---

## 🧪 Testing (Optional but Recommended)

### Backend Tests

```powershell
cd c:\genaiexperiments\accountopening
mvn test
```

- [ ] All 123 tests passed
- [ ] No test failures
- [ ] Build successful

### Frontend Tests

```powershell
cd frontend\account-opening-ui
npm test
```

- [ ] All 78 checks passed
- [ ] No test failures

---

## 🔄 Multiple Runs Test

### Test Data Persistence

- [ ] Closed all PowerShell windows (services and frontend)
- [ ] Verified PostgreSQL still running: `Get-Service postgresql*`
- [ ] Restarted services: `.\start-all-services.ps1`
- [ ] Restarted frontend: `cd frontend\account-opening-ui; npm start`
- [ ] Opened http://localhost:3000
- [ ] Clicked "Customers"
- [ ] Still saw John Doe from previous run (data persisted!)

### Create Second Account

- [ ] Clicked "Open New Account"
- [ ] Entered different customer details:
  - [ ] Name: `Jane Smith`
  - [ ] Email: `jane.smith@example.com`
  - [ ] Phone: `555-0456`
  - [ ] Address: `456 Oak Ave, Town, State 67890`
- [ ] Uploaded a different document
- [ ] Selected different account type
- [ ] Entered different deposit amount: `2000`
- [ ] Completed wizard successfully

- [ ] Clicked "Customers"
- [ ] Saw BOTH John Doe AND Jane Smith (data accumulated!)

- [ ] Clicked "Accounts"
- [ ] Saw BOTH accounts listed

---

## 🎨 UI/UX Validation

### Visual Checks

- [ ] Navigation bar displays correctly
- [ ] All buttons are styled properly
- [ ] Forms are aligned and readable
- [ ] Tables display data clearly
- [ ] Colors and theme are consistent
- [ ] Responsive design works on window resize

### Functionality Checks

- [ ] All form validations work (try submitting empty form)
- [ ] Error messages display clearly
- [ ] Success messages display after submission
- [ ] Loading states work (if you see them)
- [ ] File upload shows file name and size
- [ ] Can navigate between all pages
- [ ] Browser back button works

### Error Handling

- [ ] Tried submitting form with missing fields → Saw validation errors
- [ ] Tried uploading wrong file type → Saw error message
- [ ] If you stop a service and try to use it → Saw meaningful error

---

## 📊 Health Checks

### Service Health

```powershell
.\check-services.ps1
```

Expected output:
```
✅ Customer Service: Running (http://localhost:8081)
✅ Document Service: Running (http://localhost:8082)
✅ Account Service: Running (http://localhost:8083)
✅ Notification Service: Running (http://localhost:8084)
✅ Frontend: Running (http://localhost:3000)
✅ PostgreSQL: Running
```

- [ ] All services showing ✅ Running
- [ ] No ❌ errors displayed

### Database Health

```powershell
# Check service status
Get-Service postgresql*

# Check connections
psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Check database sizes
psql -U postgres -c "SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database WHERE datname IN ('customerdb', 'documentdb', 'accountdb', 'notificationdb');"
```

- [ ] PostgreSQL service running
- [ ] Can connect to postgres user
- [ ] All 4 databases exist
- [ ] Databases have reasonable sizes

---

## 🐛 Troubleshooting Test

### Simulate Common Issues

**Test 1: Service Restart**
- [ ] Closed one service window (e.g., customer-service)
- [ ] Tried to view customers in UI → Saw error message
- [ ] Restarted that service
- [ ] Waited for "Started..." message
- [ ] Refreshed browser
- [ ] Could view customers again ✅

**Test 2: Database Connection**
- [ ] Stopped PostgreSQL: `Stop-Service postgresql-x64-15`
- [ ] Tried to create account → Saw connection error
- [ ] Started PostgreSQL: `Start-Service postgresql-x64-15`
- [ ] Waited 10 seconds
- [ ] Tried to create account again → Success ✅

**Test 3: Port Conflict**
- [ ] Ran `netstat -ano | findstr :8081`
- [ ] Verified only one process on port 8081
- [ ] If multiple processes, killed extras

---

## 📝 Documentation Review

- [ ] Read QUICK_START.md
- [ ] Understood architecture diagram
- [ ] Know how to start services
- [ ] Know how to check health
- [ ] Know how to troubleshoot common issues
- [ ] Know how to reset databases if needed
- [ ] Reviewed POSTGRESQL_WINDOWS_SETUP.md
- [ ] Bookmarked CRITICAL_FIX_GUIDE.md for future reference

---

## 🚀 Final Validation

### Complete System Test

- [ ] All 4 backend services running
- [ ] Frontend running
- [ ] PostgreSQL running
- [ ] Can complete full account opening workflow
- [ ] Can view all created entities
- [ ] Data persists across restarts
- [ ] No error messages in any console
- [ ] No browser console errors
- [ ] All tests passing (backend + frontend)
- [ ] Health check script shows all green

### Performance Check

- [ ] Services started within reasonable time (< 2 minutes)
- [ ] UI loads quickly (< 5 seconds)
- [ ] Forms respond immediately to input
- [ ] API calls complete within 1-2 seconds
- [ ] No visible lag or delays

---

## ✨ Success Criteria

You've successfully set up the application when:

✅ **All of these are true:**
- [ ] PostgreSQL is installed and running
- [ ] Four databases exist and are accessible
- [ ] All 4 backend services start without errors
- [ ] Frontend starts and loads at http://localhost:3000
- [ ] Can complete account opening wizard end-to-end
- [ ] Created data appears in all list views
- [ ] Data persists in PostgreSQL (visible in pgAdmin or psql)
- [ ] All 123 backend tests pass
- [ ] All 78 frontend checks pass
- [ ] Health check shows all services green
- [ ] No errors in any console or log

---

## 🎓 What's Next?

Once all checkboxes above are checked:

### Immediate Next Steps
- [ ] Test with different data scenarios
- [ ] Try edge cases (long names, special characters, etc.)
- [ ] Test with multiple users (open in different browsers)
- [ ] Load test with many accounts

### Prepare for Cloud Deployment
- [ ] Review infrastructure code in `infrastructure/`
- [ ] Review Kubernetes manifests in `k8s/`
- [ ] Plan Azure resource names
- [ ] Prepare Azure subscription
- [ ] Review CI/CD workflows in `.github/workflows/`

### Optional Enhancements
- [ ] Add more validation rules
- [ ] Enhance error messages
- [ ] Add user authentication
- [ ] Add audit logging
- [ ] Add data export features
- [ ] Enhance UI with more Material-UI components

---

## 🆘 If Something Doesn't Work

**Don't panic!** Check these resources:

1. **QUICK_START.md** - Section "Common Issues and Solutions"
2. **POSTGRESQL_WINDOWS_SETUP.md** - Database troubleshooting
3. **CRITICAL_FIX_GUIDE.md** - Application error fixes
4. Service logs in each PowerShell window
5. Browser console (F12) for frontend errors
6. PostgreSQL logs at `C:\Program Files\PostgreSQL\15\data\pg_log\`

**Common Quick Fixes:**
```powershell
# Restart PostgreSQL
Restart-Service postgresql-x64-15

# Rebuild services
mvn clean compile -DskipTests

# Reinstall frontend dependencies
cd frontend\account-opening-ui
rm -r -force node_modules
npm install

# Check all services
.\check-services.ps1
```

---

## 📊 Progress Tracking

Track your progress:

- **Prerequisites:** __ / 5 checked
- **Database Setup:** __ / 11 checked
- **Backend Setup:** __ / 13 checked
- **Frontend Setup:** __ / 9 checked
- **E2E Testing:** __ / 41 checked
- **Testing:** __ / 5 checked
- **Multiple Runs:** __ / 12 checked
- **UI/UX:** __ / 21 checked
- **Health Checks:** __ / 12 checked
- **Troubleshooting:** __ / 9 checked
- **Documentation:** __ / 7 checked
- **Final Validation:** __ / 14 checked

**Total Progress:** __ / 159 checked

**Target:** 159 / 159 (100%) ✅

---

**Good luck with your setup! 🚀**

**Document Version:** 1.0
**Last Updated:** December 2024
