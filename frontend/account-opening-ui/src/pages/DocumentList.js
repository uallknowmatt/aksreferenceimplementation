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
} from '@mui/material';
import { CheckCircle, Description } from '@mui/icons-material';
import { documentAPI } from '../services/api';

const DocumentList = () => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchDocuments();
  }, []);

  const fetchDocuments = async () => {
    try {
      setLoading(true);
      const response = await documentAPI.getAllDocuments();
      setDocuments(response.data);
      setError('');
    } catch (err) {
      console.error('Error fetching documents:', err);
      setError('Failed to load documents. Please try again later.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyDocument = async (documentId) => {
    try {
      await documentAPI.verifyDocument(documentId);
      fetchDocuments();
    } catch (err) {
      console.error('Error verifying document:', err);
      alert('Failed to verify document');
    }
  };

  const getVerificationColor = (verified) => {
    return verified ? 'success' : 'warning';
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
        Documents
      </Typography>
      <Typography variant="body1" color="text.secondary" paragraph>
        View all uploaded documents
      </Typography>

      {documents.length === 0 ? (
        <Alert severity="info">No documents found.</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><strong>ID</strong></TableCell>
                <TableCell><strong>Customer ID</strong></TableCell>
                <TableCell><strong>File Name</strong></TableCell>
                <TableCell><strong>Document Type</strong></TableCell>
                <TableCell><strong>File Type</strong></TableCell>
                <TableCell><strong>Status</strong></TableCell>
                <TableCell align="center"><strong>Actions</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {documents.map((document) => (
                <TableRow key={document.id} hover>
                  <TableCell>{document.id}</TableCell>
                  <TableCell>{document.customerId}</TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                      <Description sx={{ mr: 1, color: 'primary.main' }} />
                      {document.fileName}
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Chip label={document.type} size="small" variant="outlined" />
                  </TableCell>
                  <TableCell>{document.fileType}</TableCell>
                  <TableCell>
                    <Chip
                      label={document.verified ? 'VERIFIED' : 'PENDING'}
                      color={getVerificationColor(document.verified)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell align="center">
                    {!document.verified && (
                      <IconButton
                        size="small"
                        onClick={() => handleVerifyDocument(document.id)}
                        color="success"
                        title="Verify Document"
                      >
                        <CheckCircle />
                      </IconButton>
                    )}
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

export default DocumentList;
