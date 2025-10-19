import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Stepper,
  Step,
  StepLabel,
  Button,
  Typography,
  Paper,
  Alert,
  CircularProgress,
} from '@mui/material';

import CustomerInfoStep from '../components/wizard/CustomerInfoStep';
import DocumentUploadStep from '../components/wizard/DocumentUploadStep';
import AccountDetailsStep from '../components/wizard/AccountDetailsStep';
import ReviewStep from '../components/wizard/ReviewStep';
import CompletionStep from '../components/wizard/CompletionStep';

import { customerAPI, documentAPI, accountAPI, notificationAPI } from '../services/api';

const steps = ['Customer Information', 'Upload Documents', 'Account Details', 'Review & Submit'];

const AccountOpeningWizard = () => {
  const navigate = useNavigate();
  const [activeStep, setActiveStep] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const [formData, setFormData] = useState({
    customer: {
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      dateOfBirth: '',
      address: '',
    },
    documents: [],
    account: {
      accountType: 'SAVINGS',
      initialDeposit: 0,
    },
    createdCustomerId: null,
    createdDocumentIds: [],
    createdAccountId: null,
  });

  const handleNext = () => {
    setActiveStep((prevActiveStep) => prevActiveStep + 1);
    setError('');
  };

  const handleBack = () => {
    setActiveStep((prevActiveStep) => prevActiveStep - 1);
    setError('');
  };

  const handleUpdateFormData = (section, data) => {
    setFormData((prev) => ({
      ...prev,
      [section]: data,
    }));
  };

  const handleSubmit = async () => {
    setLoading(true);
    setError('');

    try {
      // Step 1: Create Customer
      const customerResponse = await customerAPI.createCustomer(formData.customer);
      const customerId = customerResponse.data.id;
      
      setFormData((prev) => ({
        ...prev,
        createdCustomerId: customerId,
      }));

      // Step 2: Upload Documents
      const documentIds = [];
      for (const doc of formData.documents) {
        const documentData = {
          customerId: customerId,
          fileName: doc.fileName,
          fileType: doc.fileType,
          type: doc.type,
          content: doc.content,
        };
        const docResponse = await documentAPI.uploadDocument(documentData);
        documentIds.push(docResponse.data.id);
      }
      
      setFormData((prev) => ({
        ...prev,
        createdDocumentIds: documentIds,
      }));

      // Step 3: Create Account
      const accountData = {
        customerId: customerId,
        accountNumber: `ACC${Date.now()}`,
        accountType: formData.account.accountType,
        balance: formData.account.initialDeposit,
        status: 'ACTIVE',
      };
      const accountResponse = await accountAPI.createAccount(accountData);
      const accountId = accountResponse.data.id;
      
      setFormData((prev) => ({
        ...prev,
        createdAccountId: accountId,
      }));

      // Step 4: Send Notification
      const notificationData = {
        recipient: formData.customer.email,
        message: `Welcome ${formData.customer.firstName}! Your account ${accountData.accountNumber} has been successfully created.`,
        type: 'EMAIL',
      };
      await notificationAPI.sendNotification(notificationData);

      // Success - move to completion step
      handleNext();
    } catch (err) {
      console.error('Error creating account:', err);
      setError(
        err.response?.data?.message || 
        'An error occurred while processing your request. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  const getStepContent = (step) => {
    switch (step) {
      case 0:
        return (
          <CustomerInfoStep
            data={formData.customer}
            onUpdate={(data) => handleUpdateFormData('customer', data)}
            onNext={handleNext}
          />
        );
      case 1:
        return (
          <DocumentUploadStep
            data={formData.documents}
            onUpdate={(data) => handleUpdateFormData('documents', data)}
            onNext={handleNext}
            onBack={handleBack}
          />
        );
      case 2:
        return (
          <AccountDetailsStep
            data={formData.account}
            onUpdate={(data) => handleUpdateFormData('account', data)}
            onNext={handleNext}
            onBack={handleBack}
          />
        );
      case 3:
        return (
          <ReviewStep
            formData={formData}
            onBack={handleBack}
            onSubmit={handleSubmit}
            loading={loading}
          />
        );
      case 4:
        return (
          <CompletionStep
            formData={formData}
            onGoHome={() => navigate('/')}
            onViewAccount={() => navigate('/accounts')}
          />
        );
      default:
        return 'Unknown step';
    }
  };

  return (
    <Box sx={{ width: '100%' }}>
      <Typography variant="h2" component="h1" gutterBottom align="center">
        Open New Account
      </Typography>
      <Typography variant="body1" color="text.secondary" paragraph align="center" sx={{ mb: 4 }}>
        Complete the following steps to open your new bank account
      </Typography>

      <Paper elevation={3} sx={{ p: 4, mb: 4 }}>
        {activeStep < 4 && (
          <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
            {steps.map((label) => (
              <Step key={label}>
                <StepLabel>{label}</StepLabel>
              </Step>
            ))}
          </Stepper>
        )}

        {error && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {error}
          </Alert>
        )}

        {loading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}>
            <CircularProgress />
          </Box>
        )}

        {!loading && getStepContent(activeStep)}
      </Paper>
    </Box>
  );
};

export default AccountOpeningWizard;
