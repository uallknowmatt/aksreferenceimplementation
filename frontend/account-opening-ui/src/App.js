import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';

import Navigation from './components/Navigation';
import Home from './pages/Home';
import AccountOpeningWizard from './pages/AccountOpeningWizard';
import CustomerList from './pages/CustomerList';
import AccountList from './pages/AccountList';
import DocumentList from './pages/DocumentList';
import NotificationList from './pages/NotificationList';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
    background: {
      default: '#f5f5f5',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontSize: '2.5rem',
      fontWeight: 600,
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 500,
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
          <Navigation />
          <Container maxWidth="lg" sx={{ mt: 4, mb: 4, flex: 1 }}>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/open-account" element={<AccountOpeningWizard />} />
              <Route path="/customers" element={<CustomerList />} />
              <Route path="/accounts" element={<AccountList />} />
              <Route path="/documents" element={<DocumentList />} />
              <Route path="/notifications" element={<NotificationList />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </Container>
          <Box
            component="footer"
            sx={{
              py: 3,
              px: 2,
              mt: 'auto',
              backgroundColor: (theme) =>
                theme.palette.mode === 'light'
                  ? theme.palette.grey[200]
                  : theme.palette.grey[800],
              textAlign: 'center',
            }}
          >
            © 2025 Bank Account Opening System. All rights reserved.
          </Box>
        </Box>
      </Router>
    </ThemeProvider>
  );
}

export default App;
