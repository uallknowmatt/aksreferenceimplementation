package com.bank.accountopening.document.service;

import com.bank.accountopening.document.model.Document;
import com.bank.accountopening.document.repository.DocumentRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class DocumentServiceTest {

    @Mock
    private DocumentRepository documentRepository;

    @InjectMocks
    private DocumentService documentService;

    private Document testDocument;

    @BeforeEach
    public void setUp() {
        testDocument = new Document();
        testDocument.setId(1L);
        testDocument.setType("passport");
        testDocument.setFileName("passport.pdf");
        testDocument.setFileUrl("https://storage.example.com/passport.pdf");
        testDocument.setVerified(false);
        testDocument.setCustomerId(100L);
    }

    @Test
    public void testUploadDocument_Success() {
        when(documentRepository.save(any(Document.class))).thenReturn(testDocument);

        Document requestDoc = new Document();
        requestDoc.setType("passport");
        requestDoc.setFileName("passport.pdf");
        requestDoc.setFileUrl("https://storage.example.com/passport.pdf");
        requestDoc.setCustomerId(100L);

        Document result = documentService.uploadDocument(requestDoc);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("passport", result.getType());
        assertEquals("passport.pdf", result.getFileName());
        assertEquals("https://storage.example.com/passport.pdf", result.getFileUrl());
        assertFalse(result.isVerified());
        assertEquals(100L, result.getCustomerId());

        verify(documentRepository, times(1)).save(any(Document.class));
    }

    @Test
    public void testUploadDocument_NullDocument() {
        when(documentRepository.save(null)).thenThrow(new IllegalArgumentException("Document cannot be null"));

        assertThrows(IllegalArgumentException.class, () -> {
            documentService.uploadDocument(null);
        });

        verify(documentRepository, times(1)).save(null);
    }

    @Test
    public void testGetDocumentsByCustomer_Success() {
        Document doc1 = new Document();
        doc1.setId(1L);
        doc1.setType("passport");
        doc1.setFileName("passport.pdf");
        doc1.setCustomerId(100L);

        Document doc2 = new Document();
        doc2.setId(2L);
        doc2.setType("address_proof");
        doc2.setFileName("utility_bill.pdf");
        doc2.setCustomerId(100L);

        List<Document> documents = Arrays.asList(doc1, doc2);
        when(documentRepository.findByCustomerId(100L)).thenReturn(documents);

        List<Document> result = documentService.getDocumentsByCustomer(100L);

        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("passport", result.get(0).getType());
        assertEquals("address_proof", result.get(1).getType());

        verify(documentRepository, times(1)).findByCustomerId(100L);
    }

    @Test
    public void testGetDocumentsByCustomer_EmptyList() {
        when(documentRepository.findByCustomerId(anyLong())).thenReturn(Arrays.asList());

        List<Document> result = documentService.getDocumentsByCustomer(999L);

        assertNotNull(result);
        assertTrue(result.isEmpty());

        verify(documentRepository, times(1)).findByCustomerId(999L);
    }

    @Test
    public void testGetDocumentsByCustomer_NullCustomerId() {
        when(documentRepository.findByCustomerId(null)).thenReturn(Arrays.asList());

        List<Document> result = documentService.getDocumentsByCustomer(null);

        assertNotNull(result);
        assertTrue(result.isEmpty());

        verify(documentRepository, times(1)).findByCustomerId(null);
    }

    @Test
    public void testVerifyDocument_SetToTrue() {
        when(documentRepository.findById(1L)).thenReturn(Optional.of(testDocument));
        testDocument.setVerified(true);
        when(documentRepository.save(any(Document.class))).thenReturn(testDocument);

        Document result = documentService.verifyDocument(1L, true);

        assertNotNull(result);
        assertTrue(result.isVerified());

        verify(documentRepository, times(1)).findById(1L);
        verify(documentRepository, times(1)).save(any(Document.class));
    }

    @Test
    public void testVerifyDocument_SetToFalse() {
        testDocument.setVerified(true);
        when(documentRepository.findById(1L)).thenReturn(Optional.of(testDocument));
        testDocument.setVerified(false);
        when(documentRepository.save(any(Document.class))).thenReturn(testDocument);

        Document result = documentService.verifyDocument(1L, false);

        assertNotNull(result);
        assertFalse(result.isVerified());

        verify(documentRepository, times(1)).findById(1L);
        verify(documentRepository, times(1)).save(any(Document.class));
    }

    @Test
    public void testVerifyDocument_DocumentNotFound() {
        when(documentRepository.findById(anyLong())).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            documentService.verifyDocument(999L, true);
        });

        assertEquals("Document not found", exception.getMessage());

        verify(documentRepository, times(1)).findById(999L);
        verify(documentRepository, never()).save(any(Document.class));
    }

    @Test
    public void testVerifyDocument_MultipleVerifications() {
        when(documentRepository.findById(1L)).thenReturn(Optional.of(testDocument));
        when(documentRepository.save(any(Document.class))).thenReturn(testDocument);

        // First verification
        testDocument.setVerified(true);
        Document result1 = documentService.verifyDocument(1L, true);
        assertTrue(result1.isVerified());

        // Second verification (toggle back)
        testDocument.setVerified(false);
        Document result2 = documentService.verifyDocument(1L, false);
        assertFalse(result2.isVerified());

        verify(documentRepository, times(2)).findById(1L);
        verify(documentRepository, times(2)).save(any(Document.class));
    }
}
