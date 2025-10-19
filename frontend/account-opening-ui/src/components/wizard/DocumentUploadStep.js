import React, { useState, useEffect } from 'react';
import {
  Box,
  Button,
  Grid,
  Typography,
  Card,
  CardContent,
  IconButton,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  TextField,
  MenuItem,
  Alert,
} from '@mui/material';
import { Delete, Upload, Description } from '@mui/icons-material';

const documentTypes = [
  { value: 'ID', label: 'Government ID' },
  { value: 'PASSPORT', label: 'Passport' },
  { value: 'DRIVERS_LICENSE', label: 'Driver\'s License' },
  { value: 'PROOF_OF_ADDRESS', label: 'Proof of Address' },
  { value: 'OTHER', label: 'Other' },
];

const DocumentUploadStep = ({ data, onUpdate, onNext, onBack }) => {
  const [documents, setDocuments] = useState(data || []);
  const [currentDoc, setCurrentDoc] = useState({
    fileName: '',
    fileType: '',
    type: 'ID',
    content: '',
  });
  const [error, setError] = useState('');

  // Sync local state with parent data when it changes
  useEffect(() => {
    if (data && Array.isArray(data)) {
      setDocuments(data);
    }
  }, [data]);

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        setError('File size must be less than 5MB');
        return;
      }

      const reader = new FileReader();
      reader.onload = (event) => {
        setCurrentDoc({
          ...currentDoc,
          fileName: file.name,
          fileType: file.type,
          content: event.target.result,
        });
        setError('');
      };
      reader.readAsDataURL(file);
    }
  };

  const handleAddDocument = () => {
    if (!currentDoc.fileName) {
      setError('Please select a file to upload');
      return;
    }

    const newDoc = {
      ...currentDoc,
      id: Date.now(), // Temporary ID for UI purposes
    };

    const updatedDocuments = [...documents, newDoc];
    setDocuments(updatedDocuments);
    onUpdate(updatedDocuments); // Sync with parent immediately
    setCurrentDoc({
      fileName: '',
      fileType: '',
      type: 'ID',
      content: '',
    });
    setError('');
  };

  const handleRemoveDocument = (id) => {
    const updatedDocuments = documents.filter((doc) => doc.id !== id);
    setDocuments(updatedDocuments);
    onUpdate(updatedDocuments); // Sync with parent immediately
  };

  const handleNext = () => {
    if (documents.length === 0) {
      setError('Please upload at least one document');
      return;
    }
    onUpdate(documents);
    onNext();
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom>
        Upload Documents
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Please upload required identification and verification documents.
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      <Card variant="outlined" sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Add New Document
          </Typography>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} sm={6}>
              <TextField
                select
                fullWidth
                label="Document Type"
                value={currentDoc.type}
                onChange={(e) =>
                  setCurrentDoc({ ...currentDoc, type: e.target.value })
                }
              >
                {documentTypes.map((option) => (
                  <MenuItem key={option.value} value={option.value}>
                    {option.label}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Button
                variant="outlined"
                component="label"
                fullWidth
                startIcon={<Upload />}
              >
                Choose File
                <input
                  type="file"
                  hidden
                  accept="image/*,.pdf"
                  onChange={handleFileChange}
                />
              </Button>
            </Grid>
            {currentDoc.fileName && (
              <Grid item xs={12}>
                <Alert severity="info">
                  Selected: {currentDoc.fileName}
                </Alert>
              </Grid>
            )}
            <Grid item xs={12}>
              <Button
                variant="contained"
                fullWidth
                onClick={handleAddDocument}
                disabled={!currentDoc.fileName}
              >
                Add Document
              </Button>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {documents.length > 0 && (
        <Card variant="outlined">
          <CardContent>
            <Typography variant="h6" gutterBottom>
              Uploaded Documents ({documents.length})
            </Typography>
            <List>
              {documents.map((doc) => (
                <ListItem key={doc.id} divider>
                  <Description sx={{ mr: 2, color: 'primary.main' }} />
                  <ListItemText
                    primary={doc.fileName}
                    secondary={
                      documentTypes.find((t) => t.value === doc.type)?.label ||
                      doc.type
                    }
                  />
                  <ListItemSecondaryAction>
                    <IconButton
                      edge="end"
                      onClick={() => handleRemoveDocument(doc.id)}
                      color="error"
                    >
                      <Delete />
                    </IconButton>
                  </ListItemSecondaryAction>
                </ListItem>
              ))}
            </List>
          </CardContent>
        </Card>
      )}

      <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 3 }}>
        <Button onClick={onBack} size="large">
          Back
        </Button>
        <Button variant="contained" onClick={handleNext} size="large">
          Next
        </Button>
      </Box>
    </Box>
  );
};

export default DocumentUploadStep;
