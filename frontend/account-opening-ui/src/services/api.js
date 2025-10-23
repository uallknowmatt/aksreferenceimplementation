import axios from 'axios';

// Base API URLs for each microservice
// In Kubernetes/production: use nginx proxy paths (relative URLs)
// In local development: use direct service URLs
const CUSTOMER_SERVICE_URL = process.env.REACT_APP_CUSTOMER_SERVICE_URL || (process.env.NODE_ENV === 'production' ? '/api/customer' : 'http://localhost:8081');
const DOCUMENT_SERVICE_URL = process.env.REACT_APP_DOCUMENT_SERVICE_URL || (process.env.NODE_ENV === 'production' ? '/api/document' : 'http://localhost:8082');
const ACCOUNT_SERVICE_URL = process.env.REACT_APP_ACCOUNT_SERVICE_URL || (process.env.NODE_ENV === 'production' ? '/api/account' : 'http://localhost:8083');
const NOTIFICATION_SERVICE_URL = process.env.REACT_APP_NOTIFICATION_SERVICE_URL || (process.env.NODE_ENV === 'production' ? '/api/notification' : 'http://localhost:8084');

// Create axios instance with default config
const createApiClient = (baseURL) => axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 second timeout
});

// Create separate clients for each service
const customerClient = createApiClient(CUSTOMER_SERVICE_URL);
const documentClient = createApiClient(DOCUMENT_SERVICE_URL);
const accountClient = createApiClient(ACCOUNT_SERVICE_URL);
const notificationClient = createApiClient(NOTIFICATION_SERVICE_URL);

// Customer Service API
export const customerAPI = {
  createCustomer: (customerData) =>
    customerClient.post('/api/customers', customerData),

  getCustomer: (id) =>
    customerClient.get(`/api/customers/${id}`),

  updateCustomer: (id, customerData) =>
    customerClient.put(`/api/customers/${id}`, customerData),

  getAllCustomers: () =>
    customerClient.get('/api/customers'),
};

// Document Service API
export const documentAPI = {
  uploadDocument: (documentData) =>
    documentClient.post('/api/documents', documentData),

  getDocument: (id) =>
    documentClient.get(`/api/documents/${id}`),

  verifyDocument: (id) =>
    documentClient.put(`/api/documents/${id}/verify`),

  getAllDocuments: () =>
    documentClient.get('/api/documents'),
};

// Account Service API
export const accountAPI = {
  createAccount: (accountData) =>
    accountClient.post('/api/accounts', accountData),

  getAccount: (id) =>
    accountClient.get(`/api/accounts/${id}`),

  closeAccount: (id) =>
    accountClient.delete(`/api/accounts/${id}`),

  getAllAccounts: () =>
    accountClient.get('/api/accounts'),
};

// Notification Service API
export const notificationAPI = {
  sendNotification: (notificationData) =>
    notificationClient.post('/api/notifications', notificationData),

  getAllNotifications: () =>
    notificationClient.get('/api/notifications'),
};

export default {
  customerClient,
  documentClient,
  accountClient,
  notificationClient,
};
