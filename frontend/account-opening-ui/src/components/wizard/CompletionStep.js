import React from 'react';
import {
  Box,
  Button,
  Typography,
  Card,
  CardContent,
  Alert,
  Divider,
} from '@mui/material';
import {
  CheckCircle,
  AccountBalance,
  Email,
} from '@mui/icons-material';

const CompletionStep = ({ formData, onGoHome, onViewAccount }) => {
  const accountNumber = `ACC${formData.createdAccountId || Date.now()}`;

  return (
    <Box sx={{ textAlign: 'center' }}>
      <CheckCircle
        sx={{ fontSize: 80, color: 'success.main', mb: 2 }}
      />
      
      <Typography variant="h4" gutterBottom>
        Account Created Successfully! 🎉
      </Typography>
      
      <Typography variant="body1" color="text.secondary" paragraph>
        Congratulations! Your account has been created and is now active.
      </Typography>

      <Alert severity="success" sx={{ mb: 4, textAlign: 'left' }}>
        <Typography variant="body2" gutterBottom>
          A confirmation email has been sent to{' '}
          <strong>{formData.customer.email}</strong>
        </Typography>
        <Typography variant="body2">
          Your account number is: <strong>{accountNumber}</strong>
        </Typography>
      </Alert>

      <Card variant="outlined" sx={{ mb: 3, textAlign: 'left' }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Account Summary
          </Typography>
          <Divider sx={{ mb: 2 }} />
          
          <Box sx={{ mb: 2 }}>
            <Typography variant="body2" color="text.secondary">
              Account Holder
            </Typography>
            <Typography variant="body1">
              {formData.customer.firstName} {formData.customer.lastName}
            </Typography>
          </Box>

          <Box sx={{ mb: 2 }}>
            <Typography variant="body2" color="text.secondary">
              Account Type
            </Typography>
            <Typography variant="body1">
              {formData.account.accountType}
            </Typography>
          </Box>

          <Box sx={{ mb: 2 }}>
            <Typography variant="body2" color="text.secondary">
              Initial Balance
            </Typography>
            <Typography variant="h6" color="primary.main">
              ${formData.account.initialDeposit.toFixed(2)}
            </Typography>
          </Box>

          <Box>
            <Typography variant="body2" color="text.secondary">
              Documents Uploaded
            </Typography>
            <Typography variant="body1">
              {formData.documents.length} document(s)
            </Typography>
          </Box>
        </CardContent>
      </Card>

      <Card variant="outlined" sx={{ mb: 4, bgcolor: 'info.50', textAlign: 'left' }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            <Email sx={{ mr: 1, verticalAlign: 'middle' }} />
            Next Steps
          </Typography>
          <Typography variant="body2" component="ul" sx={{ pl: 2 }}>
            <li>Check your email for account details and welcome kit</li>
            <li>Your debit card will arrive within 7-10 business days</li>
            <li>Set up online banking using your email and temporary password</li>
            <li>Download our mobile app for convenient banking</li>
          </Typography>
        </CardContent>
      </Card>

      <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
        <Button
          variant="contained"
          size="large"
          startIcon={<AccountBalance />}
          onClick={onViewAccount}
        >
          View All Accounts
        </Button>
        <Button
          variant="outlined"
          size="large"
          onClick={onGoHome}
        >
          Go to Home
        </Button>
      </Box>
    </Box>
  );
};

export default CompletionStep;
