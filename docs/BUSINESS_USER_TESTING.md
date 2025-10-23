# Business User Testing Guide

This guide provides step-by-step manual testing procedures for business users to validate the Account Opening application.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Test Scenario 1: Create Customer](#test-scenario-1-create-a-new-customer)
- [Test Scenario 2: Upload Documents](#test-scenario-2-upload-documents)
- [Test Scenario 3: Open Account](#test-scenario-3-open-a-new-account)
- [Test Scenario 4: View Dashboard](#test-scenario-4-view-customer-dashboard)
- [Expected Behavior](#expected-application-behavior)
- [Test Data](#test-data-sets)
- [Reporting Issues](#reporting-issues)

---

## Prerequisites

- **Application URL:** Get from IT/DevOps or see [Application Access Guide](APPLICATION_ACCESS.md)
- **Web Browser:** Chrome, Firefox, Edge (latest version recommended)
- **Test Data:** Sample customer information (provided below)
- **Network Access:** Ensure you can access the application URL

---

## Test Scenario 1: Create a New Customer

### Purpose
Verify customer registration functionality works correctly.

### Steps

**1. Open Application**
- Navigate to the application URL: `http://<EXTERNAL-IP>`
- Example: `http://68.220.25.83`
- You should see the Account Opening application homepage

**2. Navigate to Customer Registration**
- Click **"New Customer"** or **"Register Customer"** button
- Registration form should load with input fields

**3. Fill Customer Information**

```
First Name:    John
Last Name:     Doe
Email:         john.doe@example.com
Phone:         +1-555-0100
Date of Birth: 01/01/1990
Address:       123 Main St
City:          New York
State:         NY
Zip Code:      10001
SSN:           123-45-6789 (test data only)
```

**4. Submit Form**
- Click **"Submit"** or **"Register"** button
- Wait for response (should be < 2 seconds)

**5. Expected Results**
- ✅ Success message: "Customer registered successfully"
- ✅ Customer ID displayed (e.g., "Customer ID: 12345")
- ✅ Page redirects to customer details or dashboard
- ✅ No error messages

**6. Verify Customer Created**
- Navigate to **"Search Customers"** or **"Customer List"**
- Search for "John Doe" or use the customer ID
- **Expected:**
  - ✅ Customer appears in list
  - ✅ All details match what you entered
  - ✅ Status shows "Active" or "Pending"
  - ✅ Registration timestamp is current

### ⚠️ If Test Fails

**Error: "Email already exists"**
- Use different email address
- Or use format: `john.doe+test1@example.com`

**Error: "Service unavailable"**
- Customer Service may be down
- Contact IT/DevOps
- See [Troubleshooting Guide](TROUBLESHOOTING.md)

**Form validation errors:**
- Check all required fields filled
- Check email format is valid
- Check phone format: +1-555-0100
- Check date format: MM/DD/YYYY

---

## Test Scenario 2: Upload Documents

### Purpose
Verify document upload and storage functionality.

### Prerequisites
- Complete Test Scenario 1 (have a customer ID)
- Have a test PDF file ready (< 5 MB)

### Steps

**1. Navigate to Document Upload**
- Go to customer details page (from Test Scenario 1)
- Click **"Upload Documents"** or **"Documents"** tab

**2. Select Document Type**
- Choose from dropdown:
  - [ ] **ID Proof** (Driver's License, Passport)
  - [ ] **Address Proof** (Utility Bill, Bank Statement)
  - [ ] **Income Proof** (Pay Stub, Tax Return)

**3. Upload Document**
- Click **"Choose File"** button
- Select a PDF file from your computer (< 5 MB)
- File name should appear next to button
- Click **"Upload"** button

**4. Monitor Upload**
- **Expected:**
  - ✅ Progress bar shows upload progress
  - ✅ Upload completes in < 5 seconds
  - ✅ Success message: "Document uploaded successfully"

**5. Verify Document Uploaded**
- Document should appear in document list
- **Expected:**
  - ✅ Document name displayed
  - ✅ Document type correct (ID_PROOF, ADDRESS_PROOF, etc.)
  - ✅ Upload date is today's date
  - ✅ File size displayed
  - ✅ Status: "Uploaded" or "Pending Review"

**6. View Document (Optional)**
- Click on uploaded document
- **Expected:**
  - ✅ Document preview loads (if browser supports)
  - ✅ OR download link works
  - ✅ Downloaded file opens correctly
  - ✅ Metadata correct (upload date, file size, customer ID)

### Test Data Files

**If you need test files:**
- Use any PDF file under 5 MB
- Sample files available in: `scripts/educational/test-data/`
- Or create a simple PDF from any document

### ⚠️ If Test Fails

**Error: "File too large"**
- Use file < 5 MB
- Compress PDF if needed

**Error: "Invalid file type"**
- Only PDF files supported
- Check file extension is .pdf

**Upload hangs or times out:**
- Check network connection
- Try smaller file
- Contact IT/DevOps (Document Service may be down)

---

## Test Scenario 3: Open a New Account

### Purpose
Verify end-to-end account opening process including notification.

### Prerequisites
- Complete Test Scenario 1 (customer created)
- Complete Test Scenario 2 (documents uploaded)
- Customer status should be "Active"

### Steps

**1. Navigate to Account Opening**
- Go to customer details page
- Click **"Open New Account"** button
- Account opening form should load

**2. Select Account Type**
- Choose account type from dropdown:
  - [ ] **Checking Account**
  - [ ] **Savings Account**
  - [ ] **Money Market Account**

**3. Enter Account Details**

```
Account Type:       Savings Account
Initial Deposit:    $1,000.00
Currency:           USD
Branch:             Main Branch
Product Code:       SAV-001 (may auto-populate)
```

**4. Review Terms and Conditions**
- Read terms (or scroll to bottom)
- Check **"I accept terms and conditions"** checkbox
- Checkbox must be checked to proceed

**5. Submit Account Opening**
- Click **"Open Account"** button
- Wait for processing (should be < 2 seconds)

**6. Expected Results - Account Created**
- ✅ Success message: "Account opened successfully"
- ✅ Account number displayed (e.g., "ACC-12345678")
- ✅ Confirmation screen shows:
  - Account number
  - Account type
  - Initial balance
  - Opening date
  - Status: "Active"

**7. Verify Account in Customer Profile**
- Navigate back to customer details/dashboard
- **Expected:**
  - ✅ New account appears in customer's account list
  - ✅ Account number matches confirmation
  - ✅ Balance shows $1,000.00
  - ✅ Status: "Active"
  - ✅ Opening date is today

**8. Verify Notification Sent**
- Check **Notifications** section (on dashboard or separate tab)
- **Expected:**
  - ✅ Notification record exists
  - ✅ Type: "EMAIL" or "Account Opening Confirmation"
  - ✅ Subject: "Account Opened Successfully" or similar
  - ✅ Status: "Sent" or "Pending"
  - ✅ Timestamp is current
  - ✅ Contains account number and details

### ⚠️ If Test Fails

**Error: "Customer not eligible"**
- Verify customer status is "Active"
- Verify documents uploaded
- May need KYC approval first

**Error: "Invalid initial deposit"**
- Check minimum deposit requirement
- May need at least $100 or $500
- Check currency format (no $ symbol needed)

**Account created but no notification:**
- Notification Service may be delayed
- Wait 1-2 minutes and refresh
- If still missing, contact IT/DevOps

---

## Test Scenario 4: View Customer Dashboard

### Purpose
Verify all services integrate correctly and data is consistent.

### Prerequisites
- Complete all previous test scenarios
- Have at least 1 customer, 1 document, 1 account

### Steps

**1. Navigate to Customer Dashboard**
- Search for customer created in Scenario 1
- Click customer name/ID to view full profile
- Dashboard should load with all sections

**2. Verify Customer Information Section**

Expected content:
- ✅ **Personal Details:**
  - Full name (John Doe)
  - Email address
  - Phone number
  - Date of birth
  - Full address
- ✅ **Customer Metadata:**
  - Customer ID
  - Registration date
  - Status (Active/Pending)
  - Last updated timestamp

**3. Verify Documents Section**

Expected content:
- ✅ **Document List:**
  - All uploaded documents displayed
  - Document type (ID_PROOF, ADDRESS_PROOF, etc.)
  - Document name/title
  - Upload date
  - File size
  - Status (Uploaded/Pending Review/Approved)
- ✅ **Document Count:**
  - Matches number you uploaded
  - "Documents: 1" or "Documents: 2"

**4. Verify Accounts Section**

Expected content:
- ✅ **Account List:**
  - All opened accounts displayed
  - Account numbers
  - Account types (Checking/Savings/Money Market)
  - Current balances ($1,000.00 or as entered)
  - Opening dates
  - Account statuses (Active)
- ✅ **Account Summary:**
  - Total accounts count
  - Total balance across all accounts

**5. Verify Notifications Section**

Expected content:
- ✅ **Notification List:**
  - All notifications sent to customer
  - Notification types (EMAIL, SMS)
  - Subjects/titles
  - Send dates
  - Delivery statuses (Sent/Pending/Failed)
- ✅ **Expected Notifications:**
  - At least 1: "Account Opened" notification
  - Possibly 2+: "Customer Registered", "Documents Received"

**6. Verify Data Consistency**

Check that all counts and data match:
- ✅ Customer count: 1 (in system)
- ✅ Document count: Matches what you uploaded (1-3)
- ✅ Account count: 1 (or number you created)
- ✅ Notification count: 1+ (at least account opening)
- ✅ All dates are logical (registration before account opening)
- ✅ All IDs are consistent (customer ID same everywhere)

**7. Test Navigation**

- ✅ Click on document → Opens document details/preview
- ✅ Click on account → Opens account details
- ✅ Click on notification → Opens notification details
- ✅ Back button works correctly
- ✅ No broken links or 404 errors

### ⚠️ If Test Fails

**Some sections empty:**
- Verify previous test scenarios completed
- Refresh page (Ctrl+F5 or Cmd+Shift+R)
- Check browser console for errors (F12)

**Data inconsistent:**
- Document uploaded but not showing → Check Document Service logs
- Account opened but not showing → Check Account Service logs
- Contact IT/DevOps with specific discrepancy

---

## Expected Application Behavior

### Performance Expectations

| Action | Expected Time | Acceptable Time | Poor |
|--------|---------------|-----------------|------|
| Page load | < 1 second | < 2 seconds | > 3 seconds |
| Form submission | < 1 second | < 2 seconds | > 3 seconds |
| Document upload (1 MB) | < 2 seconds | < 5 seconds | > 10 seconds |
| Search results | < 0.5 seconds | < 1 second | > 2 seconds |
| Dashboard load | < 1 second | < 2 seconds | > 3 seconds |

### User Experience

**✅ Good UX:**
- Clear navigation menus
- Intuitive button labels
- Helpful form field hints
- Responsive design (works on tablet/mobile)
- Consistent styling and colors
- Success/error messages clearly visible
- No confusing jargon

**❌ Poor UX (report these):**
- Blank/white screens
- Cryptic error codes
- Buttons that don't respond
- Forms that reset unexpectedly
- Data that disappears
- Inconsistent styling

### Error Handling

**✅ Good error handling:**
- Clear error messages (e.g., "Email address is invalid")
- Suggestion for fix (e.g., "Use format: user@example.com")
- Option to retry
- Error doesn't lose your data (form values preserved)

**❌ Poor error handling (report these):**
- Generic errors: "Error 500" or "Something went wrong"
- No guidance on how to fix
- Page crashes or hangs
- Must re-enter all data

---

## Test Data Sets

Use these different data sets for thorough testing:

### Test Set 1: Happy Path (All Fields)

```
Name:     John Doe
Email:    john.doe@example.com
Phone:    +1-555-0100
DOB:      01/01/1990
Address:  123 Main St, Apt 4B
City:     New York
State:    NY
Zip:      10001
SSN:      123-45-6789
```

### Test Set 2: International Customer

```
Name:     María García-López
Email:    maria.garcia+test@example.com
Phone:    +34-91-123-4567
DOB:      12/31/1995
Address:  Calle Mayor 1
City:     Madrid
State:    MD
Zip:      28001
SSN:      987-65-4321
```

### Test Set 3: Minimum Required Fields

```
Name:     Jane Smith
Email:    jane.smith@example.com
Phone:    +1-555-0300
DOB:      06/15/1985
(Leave optional fields blank to test minimum data)
```

### Test Set 4: Edge Cases

```
Name:     Dr. Robert O'Brien-Smith Jr.
Email:    robert+test123@sub.example.co.uk
Phone:    +1-555-0400
DOB:      01/01/2000 (exactly 25 years old)
Address:  Unit 5, Floor 23, Building C, 789 Enterprise Way
City:     Los Angeles
State:    CA
Zip:      90001
```

---

## Reporting Issues

### When You Encounter an Issue

**1. Document the Error**
- Take screenshot (entire screen, not just error message)
- Note exact error message text
- Note the time (helps DevOps find logs)

**2. Document What You Did**
- What page were you on?
- What button did you click?
- What data did you enter?
- What were you trying to do?

**3. Try to Reproduce**
- Can you make it happen again?
- Does it happen with different data?
- Does it happen in different browser?

**4. Gather Information**

```
Application URL: http://________
Browser: Chrome/Firefox/Edge/Safari
Browser Version: _______
Date/Time: ___________
Your Location: ___________
Error Message: ___________
Steps to Reproduce:
1. _________
2. _________
3. _________
Expected: _________
Actual: _________
```

**5. Report to IT/DevOps**

Include:
- All information from step 4
- Screenshots
- Whether it's blocking your testing
- Workaround if you found one

### Issue Priority Guidelines

**🔴 CRITICAL (Report immediately):**
- Application completely down/inaccessible
- Data loss or corruption
- Security issue (can see other users' data)
- Cannot complete any core workflow

**🟡 HIGH (Report same day):**
- Major feature not working (can't create accounts)
- Frequent errors affecting multiple users
- Performance severely degraded
- Workaround exists but difficult

**🟢 MEDIUM (Report within 2 days):**
- Minor feature not working
- Cosmetic issues affecting usability
- Inconsistent behavior
- Easy workaround available

**⚪ LOW (Report when convenient):**
- Cosmetic issues (typos, colors)
- Nice-to-have features
- Enhancement requests
- Documentation errors

---

## Testing Checklist

Use this checklist to track your testing:

### Customer Management
- [ ] Create new customer (all fields)
- [ ] Create customer (minimum fields)
- [ ] Search for customer by name
- [ ] Search for customer by email
- [ ] Search for customer by ID
- [ ] View customer details
- [ ] Edit customer information (if supported)

### Document Management
- [ ] Upload ID Proof document
- [ ] Upload Address Proof document
- [ ] Upload Income Proof document
- [ ] View document list
- [ ] Download/preview document
- [ ] Verify document metadata

### Account Opening
- [ ] Open Checking Account
- [ ] Open Savings Account
- [ ] Open Money Market Account (if supported)
- [ ] Verify account appears in list
- [ ] Verify account balance correct
- [ ] Verify account status is Active

### Notifications
- [ ] Verify account opening notification
- [ ] Verify notification contains correct details
- [ ] Verify notification timestamp

### Integration
- [ ] View complete customer dashboard
- [ ] Verify all sections populated
- [ ] Verify data consistency across services
- [ ] Test navigation between sections

### Cross-Browser (Optional)
- [ ] Test in Chrome
- [ ] Test in Firefox
- [ ] Test in Edge
- [ ] Test in Safari (if on Mac)

### Mobile/Responsive (Optional)
- [ ] Test on tablet
- [ ] Test on mobile phone
- [ ] Verify responsive design works

---

**See Also:**
- [Application Access Guide](APPLICATION_ACCESS.md) - How to access the application
- [Testing Guide](TESTING_GUIDE.md) - Technical testing procedures
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues and solutions
