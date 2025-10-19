import React, { useState } from 'react';
import {
  Box,
  Button,
  Grid,
  Typography,
  TextField,
  MenuItem,
  Card,
  CardContent,
  Alert,
  InputAdornment,
} from '@mui/material';
import {
  AccountBalance,
  Savings,
  TrendingUp,
  AccountBalanceWallet,
} from '@mui/icons-material';

const accountTypes = [
  {
    value: 'SAVINGS',
    label: 'Savings Account',
    description: 'Earn interest on your deposits with flexible access',
    icon: <Savings fontSize="large" color="primary" />,
    minDeposit: 100,
  },
  {
    value: 'CHECKING',
    label: 'Checking Account',
    description: 'Easy access for daily transactions and bill payments',
    icon: <AccountBalanceWallet fontSize="large" color="primary" />,
    minDeposit: 50,
  },
  {
    value: 'INVESTMENT',
    label: 'Investment Account',
    description: 'Higher returns with managed investment portfolios',
    icon: <TrendingUp fontSize="large" color="primary" />,
    minDeposit: 1000,
  },
  {
    value: 'BUSINESS',
    label: 'Business Account',
    description: 'Designed for business transactions and operations',
    icon: <AccountBalance fontSize="large" color="primary" />,
    minDeposit: 500,
  },
];

const AccountDetailsStep = ({ data, onUpdate, onNext, onBack }) => {
  const [formData, setFormData] = useState(data);
  const [errors, setErrors] = useState({});

  const selectedAccountType = accountTypes.find(
    (type) => type.value === formData.accountType
  );

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === 'initialDeposit' ? parseFloat(value) || 0 : value,
    }));
    
    if (errors[name]) {
      setErrors((prev) => ({
        ...prev,
        [name]: '',
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    const minDeposit = selectedAccountType?.minDeposit || 0;

    if (!formData.accountType) {
      newErrors.accountType = 'Please select an account type';
    }

    if (formData.initialDeposit < minDeposit) {
      newErrors.initialDeposit = `Minimum deposit for ${selectedAccountType?.label} is $${minDeposit}`;
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validateForm()) {
      onUpdate(formData);
      onNext();
    }
  };

  return (
    <Box component="form" onSubmit={handleSubmit}>
      <Typography variant="h5" gutterBottom>
        Account Details
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Select your account type and set your initial deposit amount.
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12}>
          <TextField
            select
            required
            fullWidth
            label="Account Type"
            name="accountType"
            value={formData.accountType}
            onChange={handleChange}
            error={!!errors.accountType}
            helperText={errors.accountType}
          >
            {accountTypes.map((option) => (
              <MenuItem key={option.value} value={option.value}>
                {option.label}
              </MenuItem>
            ))}
          </TextField>
        </Grid>

        {selectedAccountType && (
          <Grid item xs={12}>
            <Card variant="outlined" sx={{ bgcolor: 'primary.50' }}>
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                  {selectedAccountType.icon}
                  <Typography variant="h6" sx={{ ml: 2 }}>
                    {selectedAccountType.label}
                  </Typography>
                </Box>
                <Typography variant="body2" color="text.secondary">
                  {selectedAccountType.description}
                </Typography>
                <Alert severity="info" sx={{ mt: 2 }}>
                  Minimum deposit: ${selectedAccountType.minDeposit}
                </Alert>
              </CardContent>
            </Card>
          </Grid>
        )}

        <Grid item xs={12} sm={6}>
          <TextField
            required
            fullWidth
            type="number"
            label="Initial Deposit"
            name="initialDeposit"
            value={formData.initialDeposit}
            onChange={handleChange}
            error={!!errors.initialDeposit}
            helperText={errors.initialDeposit || 'Enter the amount you wish to deposit'}
            InputProps={{
              startAdornment: <InputAdornment position="start">$</InputAdornment>,
              inputProps: { min: 0, step: 0.01 },
            }}
          />
        </Grid>

        <Grid item xs={12}>
          <Card variant="outlined">
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Account Features
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2">
                    ✓ Online and mobile banking
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2">
                    ✓ 24/7 customer support
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2">
                    ✓ Secure transactions
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2">
                    ✓ Free debit card
                  </Typography>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 3 }}>
        <Button onClick={onBack} size="large">
          Back
        </Button>
        <Button type="submit" variant="contained" size="large">
          Next
        </Button>
      </Box>
    </Box>
  );
};

export default AccountDetailsStep;
