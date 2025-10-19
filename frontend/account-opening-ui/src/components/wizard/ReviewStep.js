import React from 'react';
import {
  Box,
  Button,
  Typography,
  Card,
  CardContent,
  Grid,
  Divider,
  Chip,
} from '@mui/material';
import {
  Person,
  Description,
  AccountBalance,
  CheckCircle,
} from '@mui/icons-material';

const ReviewStep = ({ formData, onBack, onSubmit, loading }) => {
  const accountTypeLabels = {
    SAVINGS: 'Savings Account',
    CHECKING: 'Checking Account',
    INVESTMENT: 'Investment Account',
    BUSINESS: 'Business Account',
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom>
        Review & Submit
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Please review your information before submitting your account application.
      </Typography>

      {/* Customer Information */}
      <Card variant="outlined" sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
            <Person color="primary" sx={{ mr: 1 }} />
            <Typography variant="h6">Customer Information</Typography>
          </Box>
          <Divider sx={{ mb: 2 }} />
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <Typography variant="body2" color="text.secondary">
                Name
              </Typography>
              <Typography variant="body1">
                {formData.customer.firstName} {formData.customer.lastName}
              </Typography>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="body2" color="text.secondary">
                Email
              </Typography>
              <Typography variant="body1">{formData.customer.email}</Typography>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="body2" color="text.secondary">
                Phone Number
              </Typography>
              <Typography variant="body1">
                {formData.customer.phoneNumber}
              </Typography>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="body2" color="text.secondary">
                Date of Birth
              </Typography>
              <Typography variant="body1">
                {formData.customer.dateOfBirth}
              </Typography>
            </Grid>
            <Grid item xs={12}>
              <Typography variant="body2" color="text.secondary">
                Address
              </Typography>
              <Typography variant="body1">{formData.customer.address}</Typography>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Documents */}
      <Card variant="outlined" sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
            <Description color="primary" sx={{ mr: 1 }} />
            <Typography variant="h6">Documents</Typography>
          </Box>
          <Divider sx={{ mb: 2 }} />
          {formData.documents.length > 0 ? (
            <Box>
              {formData.documents.map((doc, index) => (
                <Box
                  key={index}
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    mb: 1,
                  }}
                >
                  <Typography variant="body1">{doc.fileName}</Typography>
                  <Chip
                    label={doc.type}
                    size="small"
                    color="primary"
                    variant="outlined"
                  />
                </Box>
              ))}
            </Box>
          ) : (
            <Typography variant="body2" color="text.secondary">
              No documents uploaded
            </Typography>
          )}
        </CardContent>
      </Card>

      {/* Account Details */}
      <Card variant="outlined" sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
            <AccountBalance color="primary" sx={{ mr: 1 }} />
            <Typography variant="h6">Account Details</Typography>
          </Box>
          <Divider sx={{ mb: 2 }} />
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <Typography variant="body2" color="text.secondary">
                Account Type
              </Typography>
              <Typography variant="body1">
                {accountTypeLabels[formData.account.accountType] ||
                  formData.account.accountType}
              </Typography>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Typography variant="body2" color="text.secondary">
                Initial Deposit
              </Typography>
              <Typography variant="h6" color="primary.main">
                ${formData.account.initialDeposit.toFixed(2)}
              </Typography>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Terms and Conditions */}
      <Card variant="outlined" sx={{ mb: 3, bgcolor: 'warning.50' }}>
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
            <CheckCircle color="warning" sx={{ mr: 1 }} />
            <Typography variant="h6">Terms & Conditions</Typography>
          </Box>
          <Typography variant="body2" paragraph>
            By submitting this application, you acknowledge that:
          </Typography>
          <Typography variant="body2" component="ul" sx={{ pl: 2 }}>
            <li>All information provided is accurate and complete</li>
            <li>You agree to the bank's terms and conditions</li>
            <li>Your documents will be verified as part of KYC compliance</li>
            <li>Account approval is subject to bank policies</li>
          </Typography>
        </CardContent>
      </Card>

      <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 3 }}>
        <Button onClick={onBack} size="large" disabled={loading}>
          Back
        </Button>
        <Button
          variant="contained"
          size="large"
          onClick={onSubmit}
          disabled={loading}
        >
          {loading ? 'Submitting...' : 'Submit Application'}
        </Button>
      </Box>
    </Box>
  );
};

export default ReviewStep;
