import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  Button,
  Grid,
  Card,
  CardContent,
  CardActions,
  Container,
} from '@mui/material';
import {
  AccountBalance,
  Description,
  People,
  Notifications,
} from '@mui/icons-material';

const Home = () => {
  const navigate = useNavigate();

  const features = [
    {
      title: 'Customer Management',
      description: 'Register and manage customer information with comprehensive KYC processes.',
      icon: <People sx={{ fontSize: 60, color: 'primary.main' }} />,
      action: () => navigate('/customers'),
    },
    {
      title: 'Document Upload',
      description: 'Upload and verify identity documents, proof of address, and other required paperwork.',
      icon: <Description sx={{ fontSize: 60, color: 'primary.main' }} />,
      action: () => navigate('/documents'),
    },
    {
      title: 'Account Opening',
      description: 'Complete end-to-end account opening with multiple account types and instant verification.',
      icon: <AccountBalance sx={{ fontSize: 60, color: 'primary.main' }} />,
      action: () => navigate('/accounts'),
    },
    {
      title: 'Notifications',
      description: 'Track all customer notifications including email and SMS communications.',
      icon: <Notifications sx={{ fontSize: 60, color: 'primary.main' }} />,
      action: () => navigate('/notifications'),
    },
  ];

  return (
    <Container maxWidth="lg">
      <Box sx={{ mt: 4, mb: 8, textAlign: 'center' }}>
        <Typography variant="h1" component="h1" gutterBottom>
          Welcome to Bank Account Opening
        </Typography>
        <Typography variant="h5" color="text.secondary" paragraph>
          Complete digital banking experience with seamless account opening process
        </Typography>
        <Box sx={{ mt: 4 }}>
          <Button
            variant="contained"
            size="large"
            onClick={() => navigate('/open-account')}
            sx={{ mr: 2 }}
          >
            Open New Account
          </Button>
          <Button
            variant="outlined"
            size="large"
            onClick={() => navigate('/customers')}
          >
            View Customers
          </Button>
        </Box>
      </Box>

      <Grid container spacing={4}>
        {features.map((feature, index) => (
          <Grid item xs={12} sm={6} md={3} key={index}>
            <Card
              sx={{
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
                transition: 'transform 0.2s',
                '&:hover': {
                  transform: 'scale(1.05)',
                  boxShadow: 6,
                },
              }}
            >
              <CardContent sx={{ flexGrow: 1, textAlign: 'center' }}>
                <Box sx={{ mb: 2 }}>{feature.icon}</Box>
                <Typography gutterBottom variant="h5" component="h2">
                  {feature.title}
                </Typography>
                <Typography color="text.secondary">
                  {feature.description}
                </Typography>
              </CardContent>
              <CardActions sx={{ justifyContent: 'center', pb: 2 }}>
                <Button size="small" onClick={feature.action}>
                  Learn More
                </Button>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Box sx={{ mt: 8, p: 4, bgcolor: 'primary.main', color: 'white', borderRadius: 2 }}>
        <Typography variant="h4" gutterBottom align="center">
          Why Choose Us?
        </Typography>
        <Grid container spacing={3} sx={{ mt: 2 }}>
          <Grid item xs={12} md={4}>
            <Typography variant="h6" gutterBottom>
              🚀 Fast Processing
            </Typography>
            <Typography>
              Open your account in minutes with our streamlined digital process
            </Typography>
          </Grid>
          <Grid item xs={12} md={4}>
            <Typography variant="h6" gutterBottom>
              🔒 Secure & Compliant
            </Typography>
            <Typography>
              Bank-grade security with full KYC compliance and document verification
            </Typography>
          </Grid>
          <Grid item xs={12} md={4}>
            <Typography variant="h6" gutterBottom>
              📱 24/7 Access
            </Typography>
            <Typography>
              Manage your accounts anytime, anywhere with our modern platform
            </Typography>
          </Grid>
        </Grid>
      </Box>
    </Container>
  );
};

export default Home;
