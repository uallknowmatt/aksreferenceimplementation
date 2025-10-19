import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import AccountBalanceIcon from '@mui/icons-material/AccountBalance';

const Navigation = () => {
  return (
    <AppBar position="static">
      <Toolbar>
        <AccountBalanceIcon sx={{ mr: 2 }} />
        <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
          Bank Account Opening
        </Typography>
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Button color="inherit" component={RouterLink} to="/">
            Home
          </Button>
          <Button color="inherit" component={RouterLink} to="/open-account">
            Open Account
          </Button>
          <Button color="inherit" component={RouterLink} to="/customers">
            Customers
          </Button>
          <Button color="inherit" component={RouterLink} to="/accounts">
            Accounts
          </Button>
          <Button color="inherit" component={RouterLink} to="/documents">
            Documents
          </Button>
          <Button color="inherit" component={RouterLink} to="/notifications">
            Notifications
          </Button>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Navigation;
