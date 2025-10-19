# Bank Account Opening System - Complete Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     REACT FRONTEND (Port 3000)                  │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   Home   │  │ Customers│  │ Accounts │  │Documents │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                 │
│  ┌─────────────────────────────────────────────────────┐       │
│  │      Account Opening Wizard (4 Steps)              │       │
│  │  1. Customer Info  2. Documents  3. Account  4.Review│      │
│  └─────────────────────────────────────────────────────┘       │
│                                                                 │
│  ┌─────────────────────────────────────────────────────┐       │
│  │              API Service Layer (axios)              │       │
│  └─────────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   API GATEWAY (Port 8080)                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   Customer      │ │   Document      │ │   Account       │
│   Service       │ │   Service       │ │   Service       │
│   Port 8081     │ │   Port 8082     │ │   Port 8083     │
│                 │ │                 │ │                 │
│ • Create        │ │ • Upload        │ │ • Create        │
│ • Update        │ │ • Verify        │ │ • View          │
│ • View          │ │ • View          │ │ • Close         │
└─────────────────┘ └─────────────────┘ └─────────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   PostgreSQL    │ │   PostgreSQL    │ │   PostgreSQL    │
│   (Customers)   │ │   (Documents)   │ │   (Accounts)    │
└─────────────────┘ └─────────────────┘ └─────────────────┘

┌─────────────────┐
│  Notification   │
│  Service        │
│  Port 8084      │
│                 │
│ • Email         │
│ • SMS           │
│ • View History  │
└─────────────────┘
        │
        ▼
┌─────────────────┐
│   PostgreSQL    │
│ (Notifications) │
└─────────────────┘
```

## Account Opening Flow

```
User Journey:
─────────────

1. HOME PAGE
   │
   ├─→ Click "Open New Account"
   │
   ▼

2. STEP 1: Customer Information
   │
   ├─→ Enter: First Name, Last Name, Email, Phone, DOB, Address
   ├─→ Real-time validation
   ├─→ Click "Next"
   │
   ▼

3. STEP 2: Document Upload
   │
   ├─→ Select Document Type (ID, Passport, etc.)
   ├─→ Upload Files (max 5MB each)
   ├─→ Add Multiple Documents
   ├─→ Click "Next"
   │
   ▼

4. STEP 3: Account Details
   │
   ├─→ Choose Account Type:
   │   • Savings ($100 min)
   │   • Checking ($50 min)
   │   • Investment ($1000 min)
   │   • Business ($500 min)
   ├─→ Enter Initial Deposit
   ├─→ Click "Next"
   │
   ▼

5. STEP 4: Review & Submit
   │
   ├─→ Review All Information
   ├─→ Confirm Terms
   ├─→ Click "Submit"
   │
   ▼

6. BACKEND PROCESSING (Sequential)
   │
   ├─→ [POST] Create Customer Record → customerId
   │
   ├─→ [POST] Upload Each Document → documentIds[]
   │
   ├─→ [POST] Create Account → accountId
   │
   ├─→ [POST] Send Welcome Email
   │
   ▼

7. COMPLETION PAGE
   │
   ├─→ Show Success Message
   ├─→ Display Account Number
   ├─→ Show Account Summary
   └─→ Provide Next Steps
```

## Component Hierarchy

```
App (Router + Theme)
│
├── Navigation (AppBar)
│
├── Home
│   ├── Hero Section
│   ├── Feature Cards (4)
│   └── Why Choose Us
│
├── AccountOpeningWizard
│   ├── Stepper
│   ├── CustomerInfoStep
│   │   └── Form with Validation
│   ├── DocumentUploadStep
│   │   ├── File Upload
│   │   └── Document List
│   ├── AccountDetailsStep
│   │   ├── Account Type Selector
│   │   └── Deposit Input
│   ├── ReviewStep
│   │   ├── Customer Summary
│   │   ├── Documents Summary
│   │   └── Account Summary
│   └── CompletionStep
│       └── Success Message
│
├── CustomerList
│   └── Table with Customer Data
│
├── AccountList
│   ├── Table with Accounts
│   └── Account Details Modal
│
├── DocumentList
│   └── Table with Documents
│
└── NotificationList
    └── Table with Notifications
```

## Data Flow

```
User Action → Component State → API Call → Backend → Database
                                    ↓
                              Response
                                    ↓
                            Update State
                                    ↓
                            Re-render UI
```

## API Endpoints Used

```javascript
// Customer Service
POST   /api/customers           → Create customer
GET    /api/customers           → List all customers
GET    /api/customers/{id}      → Get customer details

// Document Service
POST   /api/documents           → Upload document
GET    /api/documents           → List all documents
PUT    /api/documents/{id}/verify → Verify document

// Account Service
POST   /api/accounts            → Create account
GET    /api/accounts            → List all accounts
DELETE /api/accounts/{id}       → Close account

// Notification Service
POST   /api/notifications       → Send notification
GET    /api/notifications       → List all notifications
```

## State Management

```
AccountOpeningWizard State:
{
  activeStep: 0,
  loading: false,
  error: '',
  formData: {
    customer: {
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      dateOfBirth: '',
      address: ''
    },
    documents: [
      {
        fileName: '',
        fileType: '',
        type: 'ID',
        content: ''
      }
    ],
    account: {
      accountType: 'SAVINGS',
      initialDeposit: 0
    },
    createdCustomerId: null,
    createdDocumentIds: [],
    createdAccountId: null
  }
}
```

## File Structure

```
frontend/account-opening-ui/
│
├── public/                      # Static assets
│   ├── index.html
│   ├── favicon.ico
│   └── manifest.json
│
├── src/
│   ├── components/              # Reusable components
│   │   ├── Navigation.js
│   │   └── wizard/
│   │       ├── CustomerInfoStep.js
│   │       ├── DocumentUploadStep.js
│   │       ├── AccountDetailsStep.js
│   │       ├── ReviewStep.js
│   │       └── CompletionStep.js
│   │
│   ├── pages/                   # Full page components
│   │   ├── Home.js
│   │   ├── AccountOpeningWizard.js
│   │   ├── CustomerList.js
│   │   ├── AccountList.js
│   │   ├── DocumentList.js
│   │   └── NotificationList.js
│   │
│   ├── services/                # API layer
│   │   └── api.js
│   │
│   ├── App.js                   # Main app component
│   ├── App.css                  # Global styles
│   └── index.js                 # Entry point
│
├── .env                         # Environment config
├── package.json                 # Dependencies
├── start.bat                    # Launcher script
├── FRONTEND_README.md           # Documentation
├── QUICKSTART.md                # Quick start guide
└── UI_IMPLEMENTATION_SUMMARY.md # Complete summary
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Static Web Apps                     │
│                      (React Frontend)                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTPS
┌─────────────────────────────────────────────────────────────┐
│                    Azure API Management                      │
│                      (API Gateway)                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│               Azure Kubernetes Service (AKS)                 │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Customer  │  │Document  │  │ Account  │  │Notification│  │
│  │Service   │  │Service   │  │Service   │  │Service     │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Azure Database for PostgreSQL                   │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack Summary

### Frontend
- React 18 (UI Framework)
- React Router v6 (Routing)
- Material-UI (Component Library)
- Axios (HTTP Client)
- Emotion (CSS-in-JS)

### Backend
- Spring Boot 3.1.5 (Framework)
- Java 17 (Runtime)
- Maven (Build Tool)
- JPA/Hibernate (ORM)

### Infrastructure
- Azure Kubernetes Service (Container Orchestration)
- Azure Container Registry (Container Images)
- Azure Database for PostgreSQL (Database)
- Azure API Management (API Gateway)
- Terraform (Infrastructure as Code)

## Security Features

```
Frontend Security:
├── HTTPS Only
├── Environment Variables
├── CORS Configuration
├── Input Validation
└── XSS Protection

Backend Security:
├── Authentication (JWT)
├── Authorization
├── Input Validation
├── SQL Injection Prevention
└── Rate Limiting
```

## Performance Features

```
Frontend Optimization:
├── Code Splitting
├── Lazy Loading
├── Bundle Optimization
├── Caching Strategy
└── Minification

Backend Optimization:
├── Database Indexing
├── Connection Pooling
├── Caching
├── Load Balancing
└── Horizontal Scaling
```

---

**This architecture provides a complete, scalable, secure solution for bank account opening!** 🚀
