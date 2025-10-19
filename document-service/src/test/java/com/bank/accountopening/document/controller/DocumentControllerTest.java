package com.bank.accountopening.document.controller;

import com.bank.accountopening.document.model.Document;
import com.bank.accountopening.document.service.DocumentService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DocumentController.class)
public class DocumentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
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
    public void testUploadDocument_Success() throws Exception {
        when(documentService.uploadDocument(any(Document.class))).thenReturn(testDocument);

        Document requestDoc = new Document();
        requestDoc.setType("passport");
        requestDoc.setFileName("passport.pdf");
        requestDoc.setFileUrl("https://storage.example.com/passport.pdf");
        requestDoc.setCustomerId(100L);

        mockMvc.perform(post("/api/documents")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDoc)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.type").value("passport"))
                .andExpect(jsonPath("$.fileName").value("passport.pdf"))
                .andExpect(jsonPath("$.fileUrl").value("https://storage.example.com/passport.pdf"))
                .andExpect(jsonPath("$.verified").value(false))
                .andExpect(jsonPath("$.customerId").value(100));
    }

    @Test
    public void testUploadDocument_InvalidType() throws Exception {
        Document requestDoc = new Document();
        requestDoc.setType("");
        requestDoc.setFileName("passport.pdf");
        requestDoc.setFileUrl("https://storage.example.com/passport.pdf");
        requestDoc.setCustomerId(100L);

        mockMvc.perform(post("/api/documents")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDoc)))
                .andExpect(status().isBadRequest());
    }

    @Test
    public void testUploadDocument_InvalidFileName() throws Exception {
        Document requestDoc = new Document();
        requestDoc.setType("passport");
        requestDoc.setFileName("");
        requestDoc.setFileUrl("https://storage.example.com/passport.pdf");
        requestDoc.setCustomerId(100L);

        mockMvc.perform(post("/api/documents")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDoc)))
                .andExpect(status().isBadRequest());
    }

    @Test
    public void testGetDocumentsByCustomer_Success() throws Exception {
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
        when(documentService.getDocumentsByCustomer(100L)).thenReturn(documents);

        mockMvc.perform(get("/api/documents/customer/100")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].type").value("passport"))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].type").value("address_proof"));
    }

    @Test
    public void testGetDocumentsByCustomer_EmptyList() throws Exception {
        when(documentService.getDocumentsByCustomer(anyLong())).thenReturn(Arrays.asList());

        mockMvc.perform(get("/api/documents/customer/999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    public void testVerifyDocument_SetToTrue() throws Exception {
        testDocument.setVerified(true);
        when(documentService.verifyDocument(1L, true)).thenReturn(testDocument);

        mockMvc.perform(put("/api/documents/1/verify")
                .param("verified", "true")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.verified").value(true));
    }

    @Test
    public void testVerifyDocument_SetToFalse() throws Exception {
        testDocument.setVerified(false);
        when(documentService.verifyDocument(1L, false)).thenReturn(testDocument);

        mockMvc.perform(put("/api/documents/1/verify")
                .param("verified", "false")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.verified").value(false));
    }

    @Test
    public void testVerifyDocument_ServiceThrowsException() throws Exception {
        when(documentService.verifyDocument(anyLong(), anyBoolean()))
                .thenThrow(new RuntimeException("Document not found"));

        mockMvc.perform(put("/api/documents/999/verify")
                .param("verified", "true")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isInternalServerError());
    }
}
