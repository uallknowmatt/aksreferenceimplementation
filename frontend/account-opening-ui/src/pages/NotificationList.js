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
import { Email, Sms } from '@mui/icons-material';
import { notificationAPI } from '../services/api';

const NotificationList = () => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    try {
      setLoading(true);
      const response = await notificationAPI.getAllNotifications();
      setNotifications(response.data);
      setError('');
    } catch (err) {
      console.error('Error fetching notifications:', err);
      setError('Failed to load notifications. Please try again later.');
    } finally {
      setLoading(false);
    }
  };

  const getTypeIcon = (type) => {
    switch (type) {
      case 'EMAIL':
        return <Email sx={{ mr: 1, color: 'primary.main' }} />;
      case 'SMS':
        return <Sms sx={{ mr: 1, color: 'secondary.main' }} />;
      default:
        return null;
    }
  };

  const getStatusColor = (sent) => {
    return sent ? 'success' : 'warning';
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
        Notifications
      </Typography>
      <Typography variant="body1" color="text.secondary" paragraph>
        View all sent notifications
      </Typography>

      {notifications.length === 0 ? (
        <Alert severity="info">No notifications found.</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><strong>ID</strong></TableCell>
                <TableCell><strong>Type</strong></TableCell>
                <TableCell><strong>Recipient</strong></TableCell>
                <TableCell><strong>Message</strong></TableCell>
                <TableCell><strong>Status</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {notifications.map((notification) => (
                <TableRow key={notification.id} hover>
                  <TableCell>{notification.id}</TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                      {getTypeIcon(notification.type)}
                      <Chip
                        label={notification.type}
                        size="small"
                        variant="outlined"
                        color={notification.type === 'EMAIL' ? 'primary' : 'secondary'}
                      />
                    </Box>
                  </TableCell>
                  <TableCell>{notification.recipient}</TableCell>
                  <TableCell>
                    <Typography
                      variant="body2"
                      sx={{
                        maxWidth: 400,
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {notification.message}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={notification.sent ? 'SENT' : 'PENDING'}
                      color={getStatusColor(notification.sent)}
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

export default NotificationList;
