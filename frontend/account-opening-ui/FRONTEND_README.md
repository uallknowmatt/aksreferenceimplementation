# Bank Account Opening - Frontend Documentation

A modern, responsive React application for the Bank Account Opening System.

## Quick Start

```bash
npm install
npm start
```

Visit `http://localhost:3000`

## Features

- ✅ Complete end-to-end account opening wizard
- ✅ Customer information management
- ✅ Document upload and verification
- ✅ Account management with multiple types
- ✅ Notification tracking
- ✅ Responsive Material-UI design
- ✅ Form validation and error handling

## Configuration

Create/edit `.env` file:
```
REACT_APP_API_BASE_URL=http://localhost:8080
```

## Backend Services Required

Ensure these services are running:
- Customer Service: `http://localhost:8081`
- Document Service: `http://localhost:8082`
- Account Service: `http://localhost:8083`
- Notification Service: `http://localhost:8084`

## Account Opening Flow

1. **Customer Information** - Enter personal details
2. **Upload Documents** - Upload ID and verification documents
3. **Account Details** - Select account type and initial deposit
4. **Review & Submit** - Confirm and submit application
5. **Completion** - Receive account confirmation

## Technology Stack

- React 18
- React Router v6
- Material-UI (MUI)
- Axios
- JavaScript ES6+
