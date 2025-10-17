package com.bank.accountopening.document.controller;

import com.bank.accountopening.document.model.Document;
import com.bank.accountopening.document.service.DocumentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {
    private final DocumentService documentService;

    @Autowired
    public DocumentController(DocumentService documentService) {
        this.documentService = documentService;
    }

    @PostMapping
    public ResponseEntity<Document> uploadDocument(@Valid @RequestBody Document document) {
        return ResponseEntity.ok(documentService.uploadDocument(document));
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Document>> getDocumentsByCustomer(@PathVariable Long customerId) {
        return ResponseEntity.ok(documentService.getDocumentsByCustomer(customerId));
    }

    @PutMapping("/{id}/verify")
    public ResponseEntity<Document> verifyDocument(@PathVariable Long id, @RequestParam boolean verified) {
        return ResponseEntity.ok(documentService.verifyDocument(id, verified));
    }
}
