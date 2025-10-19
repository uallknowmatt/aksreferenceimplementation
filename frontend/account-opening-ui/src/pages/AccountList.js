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
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
} from '@mui/material';
import { Delete, Visibility } from '@mui/icons-material';
import { accountAPI } from '../services/api';

const AccountList = () => {
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedAccount, setSelectedAccount] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);

  useEffect(() => {
    fetchAccounts();
  }, []);

  const fetchAccounts = async () => {
    try {
      setLoading(true);
      const response = await accountAPI.getAllAccounts();
      setAccounts(response.data);
      setError('');
    } catch (err) {
      console.error('Error fetching accounts:', err);
      setError('Failed to load accounts. Please try again later.');
    } finally {
      setLoading(false);
    }
  };

  const handleViewAccount = (account) => {
    setSelectedAccount(account);
    setOpenDialog(true);
  };

  const handleCloseAccount = async (accountId) => {
    if (window.confirm('Are you sure you want to close this account?')) {
      try {
        await accountAPI.closeAccount(accountId);
        fetchAccounts();
      } catch (err) {
        console.error('Error closing account:', err);
        alert('Failed to close account');
      }
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'ACTIVE':
        return 'success';
      case 'INACTIVE':
        return 'error';
      case 'PENDING':
        return 'warning';
      default:
        return 'default';
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
      <Alert severity="error" sx={{ mt: 2 }}>
        {error}
      </Alert>
    );
  }

  return (
    <Box>
      <Typography variant="h2" component="h1" gutterBottom>
        Accounts
      </Typography>
      <Typography variant="body1" color="text.secondary" paragraph>
        View all bank accounts
      </Typography>

      {accounts.length === 0 ? (
        <Alert severity="info">No accounts found.</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><strong>Account Number</strong></TableCell>
                <TableCell><strong>Customer ID</strong></TableCell>
                <TableCell><strong>Type</strong></TableCell>
                <TableCell align="right"><strong>Balance</strong></TableCell>
                <TableCell><strong>Status</strong></TableCell>
                <TableCell align="center"><strong>Actions</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {accounts.map((account) => (
                <TableRow key={account.id} hover>
                  <TableCell>{account.accountNumber}</TableCell>
                  <TableCell>{account.customerId}</TableCell>
                  <TableCell>
                    <Chip label={account.accountType} size="small" variant="outlined" />
                  </TableCell>
                  <TableCell align="right">
                    <Typography variant="body1" color="primary.main" fontWeight="bold">
                      ${account.balance?.toFixed(2) || '0.00'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={account.status}
                      color={getStatusColor(account.status)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell align="center">
                    <IconButton
                      size="small"
                      onClick={() => handleViewAccount(account)}
                      color="primary"
                    >
                      <Visibility />
                    </IconButton>
                    <IconButton
                      size="small"
                      onClick={() => handleCloseAccount(account.id)}
                      color="error"
                    >
                      <Delete />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Account Details Dialog */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Account Details</DialogTitle>
        <DialogContent>
          {selectedAccount && (
            <Box>
              <Typography variant="body2" color="text.secondary">
                Account Number
              </Typography>
              <Typography variant="body1" gutterBottom>
                {selectedAccount.accountNumber}
              </Typography>

              <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                Customer ID
              </Typography>
              <Typography variant="body1" gutterBottom>
                {selectedAccount.customerId}
              </Typography>

              <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                Account Type
              </Typography>
              <Typography variant="body1" gutterBottom>
                {selectedAccount.accountType}
              </Typography>

              <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                Balance
              </Typography>
              <Typography variant="h6" color="primary.main" gutterBottom>
                ${selectedAccount.balance?.toFixed(2) || '0.00'}
              </Typography>

              <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                Status
              </Typography>
              <Chip
                label={selectedAccount.status}
                color={getStatusColor(selectedAccount.status)}
                size="small"
              />
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Close</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AccountList;
