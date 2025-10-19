package com.bank.accountopening.document.service;

import com.bank.accountopening.document.model.Document;
import com.bank.accountopening.document.repository.DocumentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DocumentService {
    private final DocumentRepository documentRepository;

    @Autowired
    public DocumentService(DocumentRepository documentRepository) {
        this.documentRepository = documentRepository;
    }

    @Transactional
    public Document uploadDocument(Document document) {
        return documentRepository.save(document);
    }

    public List<Document> getDocumentsByCustomer(Long customerId) {
        return documentRepository.findByCustomerId(customerId);
    }

    public List<Document> getAllDocuments() {
        return documentRepository.findAll();
    }

    @Transactional
    public Document verifyDocument(Long documentId, boolean verified) {
        Document document = documentRepository.findById(documentId)
                .orElseThrow(() -> new RuntimeException("Document not found"));
        document.setVerified(verified);
        return documentRepository.save(document);
    }
}
