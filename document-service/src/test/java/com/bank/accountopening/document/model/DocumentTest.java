package com.bank.accountopening.document.model;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

public class DocumentTest {

    private Validator validator;

    @BeforeEach
    public void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    public void testValidDocument() {
        Document document = new Document();
        document.setId(1L);
        document.setType("passport");
        document.setFileName("passport.pdf");
        document.setFileUrl("https://storage.example.com/passport.pdf");
        document.setVerified(false);
        document.setCustomerId(100L);

        Set<ConstraintViolation<Document>> violations = validator.validate(document);
        assertTrue(violations.isEmpty(), "Valid document should have no violations");
    }

    @Test
    public void testInvalidDocument_BlankType() {
        Document document = new Document();
        document.setId(1L);
        document.setType("");
        document.setFileName("passport.pdf");
        document.setFileUrl("https://storage.example.com/passport.pdf");
        document.setCustomerId(100L);

        Set<ConstraintViolation<Document>> violations = validator.validate(document);
        assertFalse(violations.isEmpty(), "Document with blank type should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidDocument_NullType() {
        Document document = new Document();
        document.setId(1L);
        document.setType(null);
        document.setFileName("passport.pdf");
        document.setFileUrl("https://storage.example.com/passport.pdf");
        document.setCustomerId(100L);

        Set<ConstraintViolation<Document>> violations = validator.validate(document);
        assertFalse(violations.isEmpty(), "Document with null type should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidDocument_BlankFileName() {
        Document document = new Document();
        document.setId(1L);
        document.setType("passport");
        document.setFileName("");
        document.setFileUrl("https://storage.example.com/passport.pdf");
        document.setCustomerId(100L);

        Set<ConstraintViolation<Document>> violations = validator.validate(document);
        assertFalse(violations.isEmpty(), "Document with blank fileName should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidDocument_NullFileName() {
        Document document = new Document();
        document.setId(1L);
        document.setType("passport");
        document.setFileName(null);
        document.setFileUrl("https://storage.example.com/passport.pdf");
        document.setCustomerId(100L);

        Set<ConstraintViolation<Document>> violations = validator.validate(document);
        assertFalse(violations.isEmpty(), "Document with null fileName should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidDocument_MultipleMissingFields() {
        Document document = new Document();
        document.setId(1L);
        document.setType(null);
        document.setFileName(null);

        Set<ConstraintViolation<Document>> violations = validator.validate(document);
        assertFalse(violations.isEmpty(), "Document with multiple missing fields should have violations");
        assertEquals(2, violations.size());
    }

    @Test
    public void testGettersAndSetters() {
        Document document = new Document();
        
        document.setId(5L);
        assertEquals(5L, document.getId());
        
        document.setType("driver_license");
        assertEquals("driver_license", document.getType());
        
        document.setFileName("license.pdf");
        assertEquals("license.pdf", document.getFileName());
        
        document.setFileUrl("https://storage.example.com/license.pdf");
        assertEquals("https://storage.example.com/license.pdf", document.getFileUrl());
        
        document.setVerified(true);
        assertTrue(document.isVerified());
        
        document.setVerified(false);
        assertFalse(document.isVerified());
        
        document.setCustomerId(200L);
        assertEquals(200L, document.getCustomerId());
    }

    @Test
    public void testEqualsAndHashCode() {
        Document doc1 = new Document();
        doc1.setId(1L);
        doc1.setType("passport");
        doc1.setFileName("passport.pdf");
        doc1.setFileUrl("https://storage.example.com/passport.pdf");
        doc1.setVerified(false);
        doc1.setCustomerId(100L);

        Document doc2 = new Document();
        doc2.setId(1L);
        doc2.setType("passport");
        doc2.setFileName("passport.pdf");
        doc2.setFileUrl("https://storage.example.com/passport.pdf");
        doc2.setVerified(false);
        doc2.setCustomerId(100L);

        Document doc3 = new Document();
        doc3.setId(2L);
        doc3.setType("driver_license");
        doc3.setFileName("license.pdf");
        doc3.setFileUrl("https://storage.example.com/license.pdf");
        doc3.setVerified(true);
        doc3.setCustomerId(200L);

        assertEquals(doc1, doc2);
        assertEquals(doc1.hashCode(), doc2.hashCode());
        assertNotEquals(doc1, doc3);
        assertNotEquals(doc1.hashCode(), doc3.hashCode());
    }

    @Test
    public void testToString() {
        Document document = new Document();
        document.setId(1L);
        document.setType("passport");
        document.setFileName("passport.pdf");
        document.setFileUrl("https://storage.example.com/passport.pdf");
        document.setVerified(false);
        document.setCustomerId(100L);

        String toString = document.toString();
        assertNotNull(toString);
        assertTrue(toString.contains("passport"));
        assertTrue(toString.contains("passport.pdf"));
        assertTrue(toString.contains("100"));
    }

    @Test
    public void testVerifiedToggle() {
        Document document = new Document();
        assertFalse(document.isVerified());
        
        document.setVerified(true);
        assertTrue(document.isVerified());
        
        document.setVerified(false);
        assertFalse(document.isVerified());
    }

    @Test
    public void testNullableFields() {
        Document document = new Document();
        document.setType("passport");
        document.setFileName("passport.pdf");
        
        // FileUrl can be null
        document.setFileUrl(null);
        assertNull(document.getFileUrl());
        
        // CustomerId can be null
        document.setCustomerId(null);
        assertNull(document.getCustomerId());
        
        // Validation should still pass for required fields
        Set<ConstraintViolation<Document>> violations = validator.validate(document);
        assertTrue(violations.isEmpty());
    }
}
