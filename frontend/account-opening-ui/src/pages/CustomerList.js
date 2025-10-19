import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  CircularProgress,
  Alert,
  Chip,
} from '@mui/material';
import { customerAPI } from '../services/api';

const CustomerList = () => {
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchCustomers();
  }, []);

  const fetchCustomers = async () => {
    try {
      setLoading(true);
      const response = await customerAPI.getAllCustomers();
      setCustomers(response.data);
      setError('');
    } catch (err) {
      console.error('Error fetching customers:', err);
      const errorMessage = err.code === 'ERR_NETWORK' || err.message.includes('Network Error')
        ? 'Cannot connect to backend server. Please start the backend services first.'
        : 'Failed to load customers. Please try again later.';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Box>
        <Typography variant="h2" component="h1" gutterBottom>
          Customers
        </Typography>
        <Alert severity="error" sx={{ mt: 2, mb: 2 }}>
          {error}
        </Alert>
        {error.includes('backend') && (
          <Alert severity="info" sx={{ mt: 2 }}>
            <Typography variant="body2" gutterBottom>
              <strong>To start the backend services:</strong>
            </Typography>
            <Typography variant="body2" component="div">
              1. Open a terminal in the project root<br />
              2. Navigate to each service directory<br />
              3. Run: <code>mvn spring-boot:run</code><br />
              <br />
              Services run on:<br />
              - Customer Service: http://localhost:8081<br />
              - Document Service: http://localhost:8082<br />
              - Account Service: http://localhost:8083<br />
              - Notification Service: http://localhost:8084
            </Typography>
          </Alert>
        )}
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h2" component="h1" gutterBottom>
        Customers
      </Typography>
      <Typography variant="body1" color="text.secondary" paragraph>
        View all registered customers
      </Typography>

      {customers.length === 0 ? (
        <Alert severity="info">No customers found.</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><strong>ID</strong></TableCell>
                <TableCell><strong>Name</strong></TableCell>
                <TableCell><strong>Email</strong></TableCell>
                <TableCell><strong>Phone</strong></TableCell>
                <TableCell><strong>Date of Birth</strong></TableCell>
                <TableCell><strong>Status</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {customers.map((customer) => (
                <TableRow key={customer.id} hover>
                  <TableCell>{customer.id}</TableCell>
                  <TableCell>
                    {customer.firstName} {customer.lastName}
                  </TableCell>
                  <TableCell>{customer.email}</TableCell>
                  <TableCell>{customer.phoneNumber}</TableCell>
                  <TableCell>{customer.dateOfBirth}</TableCell>
                  <TableCell>
                    <Chip
                      label={customer.kycStatus || 'PENDING'}
                      color={customer.kycStatus === 'APPROVED' ? 'success' : 'warning'}
                      size="small"
                    />
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  );
};

export default CustomerList;
