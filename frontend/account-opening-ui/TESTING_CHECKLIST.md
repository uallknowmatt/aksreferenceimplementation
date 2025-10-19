# ✅ Manual Testing Checklist

Use this checklist to manually test the application after starting it.

## 🚀 Prerequisites
- [ ] React app is running at http://localhost:3000
- [ ] Backend services are running (optional for frontend testing)

---

## 1️⃣ Home Page Testing

### Navigation to Home
- [ ] Open http://localhost:3000
- [ ] Page loads without errors
- [ ] No console errors in browser DevTools

### Visual Elements
- [ ] Bank icon and "Bank Account Opening" title visible in header
- [ ] Hero section displays "Welcome to Bank Account Opening"
- [ ] "Open New Account" button visible and styled
- [ ] "View Customers" button visible and styled
- [ ] 4 feature cards displayed:
  - [ ] Customer Management card
  - [ ] Document Upload card
  - [ ] Account Opening card
  - [ ] Notifications card
- [ ] "Why Choose Us" section visible with 3 features
- [ ] Footer displays copyright text

### Navigation
- [ ] Click "Home" in navigation → stays on home page
- [ ] Click "Open Account" → navigates to wizard
- [ ] Click "Customers" → navigates to customer list
- [ ] Click "Accounts" → navigates to account list
- [ ] Click "Documents" → navigates to document list
- [ ] Click "Notifications" → navigates to notification list

---

## 2️⃣ Account Opening Wizard Testing

### Starting the Wizard
- [ ] Click "Open New Account" button from home
- [ ] Wizard page loads
- [ ] Stepper shows 4 steps: Customer Information, Upload Documents, Account Details, Review & Submit
- [ ] Step 1 is highlighted as active

### Step 1: Customer Information
- [ ] Form displays all fields:
  - [ ] First Name
  - [ ] Last Name
  - [ ] Email Address
  - [ ] Phone Number
  - [ ] Date of Birth
  - [ ] Address (multiline)
- [ ] Try clicking "Next" without filling → validation errors appear
- [ ] Fill in First Name → error clears
- [ ] Fill in Last Name → error clears
- [ ] Enter invalid email (e.g., "test") → shows "Email is invalid"
- [ ] Enter valid email → error clears
- [ ] Fill all fields correctly → "Next" button works
- [ ] Click "Next" → advances to Step 2

### Step 2: Document Upload
- [ ] "Back" button visible
- [ ] Document type dropdown shows options:
  - [ ] Government ID
  - [ ] Passport
  - [ ] Driver's License
  - [ ] Proof of Address
  - [ ] Other
- [ ] "Choose File" button visible
- [ ] Try clicking "Next" without documents → error appears
- [ ] Select document type → saves selection
- [ ] Click "Choose File" → file picker opens
- [ ] Select a file → shows "Selected: [filename]"
- [ ] Click "Add Document" → document added to list
- [ ] Document appears in "Uploaded Documents" list
- [ ] Delete icon appears next to document
- [ ] Click delete → document removed
- [ ] Add at least one document
- [ ] Click "Back" → returns to Step 1 (data preserved)
- [ ] Click "Next" again → returns to Step 2
- [ ] Click "Next" → advances to Step 3

### Step 3: Account Details
- [ ] "Back" button visible
- [ ] Account Type dropdown shows 4 options:
  - [ ] Savings Account
  - [ ] Checking Account
  - [ ] Investment Account
  - [ ] Business Account
- [ ] Select "Savings Account" → card displays:
  - [ ] Savings icon
  - [ ] Description
  - [ ] "Minimum deposit: $100"
- [ ] Try entering deposit less than $100 → error appears
- [ ] Enter valid deposit (e.g., 500) → error clears
- [ ] Account features card shows 4 features
- [ ] Click "Back" → returns to Step 2
- [ ] Click "Next" → advances to Step 4

### Step 4: Review & Submit
- [ ] "Back" button visible
- [ ] Customer Information section displays:
  - [ ] Name
  - [ ] Email
  - [ ] Phone
  - [ ] Date of Birth
  - [ ] Address
- [ ] Documents section displays:
  - [ ] All uploaded documents with file names
  - [ ] Document types as chips
- [ ] Account Details section displays:
  - [ ] Account type
  - [ ] Initial deposit amount
- [ ] Terms & Conditions section visible
- [ ] "Submit Application" button visible
- [ ] Click "Back" → returns to Step 3
- [ ] Click "Submit Application" → submits (or shows error if backend not running)

### Step 5: Completion (if backend is running)
- [ ] Success icon (green checkmark) displays
- [ ] "Account Created Successfully!" message
- [ ] Confirmation email message shown
- [ ] Account number displayed
- [ ] Account summary card shows:
  - [ ] Account holder name
  - [ ] Account type
  - [ ] Initial balance
  - [ ] Documents uploaded count
- [ ] "Next Steps" section visible
- [ ] "View All Accounts" button works
- [ ] "Go to Home" button works

---

## 3️⃣ Customer List Testing

### Navigation
- [ ] Click "Customers" in navigation
- [ ] Page title shows "Customers"

### With Backend Running
- [ ] Loading spinner shows briefly
- [ ] Table displays with columns:
  - [ ] ID
  - [ ] Name
  - [ ] Email
  - [ ] Phone
  - [ ] Date of Birth
  - [ ] Status
- [ ] Customer data populates
- [ ] Status chips show colors (green for APPROVED, yellow for PENDING)
- [ ] Table rows are hoverable

### Without Backend Running
- [ ] Error alert displays: "Failed to load customers"
- [ ] Error message is user-friendly

---

## 4️⃣ Account List Testing

### Navigation
- [ ] Click "Accounts" in navigation
- [ ] Page title shows "Accounts"

### With Backend Running
- [ ] Loading spinner shows briefly
- [ ] Table displays with columns:
  - [ ] Account Number
  - [ ] Customer ID
  - [ ] Type
  - [ ] Balance
  - [ ] Status
  - [ ] Actions
- [ ] Account data populates
- [ ] Balance shows with $ and 2 decimals
- [ ] Status chips colored (green for ACTIVE)
- [ ] Eye icon (view) button visible
- [ ] Delete icon (close account) button visible
- [ ] Click eye icon → modal opens with account details
- [ ] Modal shows all account information
- [ ] Click "Close" → modal closes
- [ ] Click delete icon → confirmation dialog appears
- [ ] Confirm deletion → account removed (or API call made)

### Without Backend Running
- [ ] Error alert displays: "Failed to load accounts"

---

## 5️⃣ Document List Testing

### Navigation
- [ ] Click "Documents" in navigation
- [ ] Page title shows "Documents"

### With Backend Running
- [ ] Loading spinner shows briefly
- [ ] Table displays with columns:
  - [ ] ID
  - [ ] Customer ID
  - [ ] File Name
  - [ ] Document Type
  - [ ] File Type
  - [ ] Status
  - [ ] Actions
- [ ] Document data populates
- [ ] File icons (document icon) display
- [ ] Document type chips show
- [ ] Status chips colored (green for VERIFIED, yellow for PENDING)
- [ ] Check icon appears for unverified documents
- [ ] Click check icon → document verified (API call)

### Without Backend Running
- [ ] Error alert displays: "Failed to load documents"

---

## 6️⃣ Notification List Testing

### Navigation
- [ ] Click "Notifications" in navigation
- [ ] Page title shows "Notifications"

### With Backend Running
- [ ] Loading spinner shows briefly
- [ ] Table displays with columns:
  - [ ] ID
  - [ ] Type
  - [ ] Recipient
  - [ ] Message
  - [ ] Status
- [ ] Notification data populates
- [ ] Email icon displays for EMAIL type
- [ ] SMS icon displays for SMS type
- [ ] Type chips colored (blue for EMAIL, pink for SMS)
- [ ] Status chips colored (green for SENT, yellow for PENDING)
- [ ] Long messages truncated with ellipsis

### Without Backend Running
- [ ] Error alert displays: "Failed to load notifications"

---

## 7️⃣ Responsive Design Testing

### Desktop (1920x1080)
- [ ] All pages display properly
- [ ] No horizontal scrolling
- [ ] Tables fit on screen
- [ ] Forms properly sized

### Laptop (1366x768)
- [ ] All pages display properly
- [ ] Tables scrollable if needed
- [ ] Forms still readable

### Tablet (iPad - 768x1024)
- [ ] Navigation collapses appropriately
- [ ] Tables scroll horizontally
- [ ] Forms stack properly
- [ ] Buttons touch-friendly

### Mobile (iPhone - 375x667)
- [ ] Navigation shows hamburger menu
- [ ] Single column layout
- [ ] Forms full-width
- [ ] Tables scroll
- [ ] All text readable

---

## 8️⃣ Browser Console Testing

### Check for Errors
- [ ] Open browser DevTools (F12)
- [ ] Go to Console tab
- [ ] No RED errors (warnings OK)
- [ ] Navigate through all pages
- [ ] Complete wizard flow
- [ ] Check for errors after each action

### Network Tab (with backend)
- [ ] Open Network tab
- [ ] Complete account opening
- [ ] Verify API calls:
  - [ ] POST /api/customers (201 Created)
  - [ ] POST /api/documents (201 Created)
  - [ ] POST /api/accounts (201 Created)
  - [ ] POST /api/notifications (201 Created)

---

## 9️⃣ Performance Testing

### Page Load Times
- [ ] Home page loads < 3 seconds
- [ ] Navigation between pages instant
- [ ] Wizard steps transition smoothly
- [ ] No lag when typing in forms

### UI Responsiveness
- [ ] Buttons respond immediately to clicks
- [ ] Forms validate in real-time
- [ ] Loading spinners show for async operations
- [ ] No frozen UI states

---

## 🔟 Accessibility Testing

### Keyboard Navigation
- [ ] Tab through form fields
- [ ] All buttons reachable via keyboard
- [ ] Enter key submits forms
- [ ] Esc key closes modals

### Screen Reader (Optional)
- [ ] Form labels read correctly
- [ ] Buttons announced properly
- [ ] Error messages announced

---

## ✅ Sign-Off

**Date:** _______________

**Tester:** _______________

**Overall Result:**
- [ ] All tests passed - Ready for production
- [ ] Minor issues found - Document below
- [ ] Major issues found - Needs fixes

**Issues Found:**
```
[List any issues here]




```

**Additional Notes:**
```
[Add any other observations]




```

---

## 🎯 Quick Test (5 Minutes)

If short on time, run these critical tests:

1. [ ] Open http://localhost:3000 - page loads
2. [ ] Click "Open New Account"
3. [ ] Fill Step 1 with valid data → Next
4. [ ] Upload one document → Next
5. [ ] Select account type, enter deposit → Next
6. [ ] Review page shows all data correctly
7. [ ] Click all navigation links - pages load
8. [ ] No console errors in browser

**Quick Test Result:** [ ] PASS [ ] FAIL

---

**Happy Testing! 🎉**
