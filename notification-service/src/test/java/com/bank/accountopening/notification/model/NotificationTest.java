package com.bank.accountopening.notification.model;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

public class NotificationTest {

    private Validator validator;

    @BeforeEach
    public void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    public void testValidNotification() {
        Notification notification = new Notification();
        notification.setId(1L);
        notification.setRecipient("test@example.com");
        notification.setMessage("Welcome to our bank!");
        notification.setType("EMAIL");
        notification.setSent(true);

        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertTrue(violations.isEmpty(), "Valid notification should have no violations");
    }

    @Test
    public void testInvalidNotification_BlankRecipient() {
        Notification notification = new Notification();
        notification.setId(1L);
        notification.setRecipient("");
        notification.setMessage("Welcome to our bank!");
        notification.setType("EMAIL");

        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertFalse(violations.isEmpty(), "Notification with blank recipient should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidNotification_NullRecipient() {
        Notification notification = new Notification();
        notification.setId(1L);
        notification.setRecipient(null);
        notification.setMessage("Welcome to our bank!");
        notification.setType("EMAIL");

        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertFalse(violations.isEmpty(), "Notification with null recipient should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidNotification_BlankMessage() {
        Notification notification = new Notification();
        notification.setId(1L);
        notification.setRecipient("test@example.com");
        notification.setMessage("");
        notification.setType("EMAIL");

        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertFalse(violations.isEmpty(), "Notification with blank message should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidNotification_NullMessage() {
        Notification notification = new Notification();
        notification.setId(1L);
        notification.setRecipient("test@example.com");
        notification.setMessage(null);
        notification.setType("EMAIL");

        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertFalse(violations.isEmpty(), "Notification with null message should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidNotification_MultipleMissingFields() {
        Notification notification = new Notification();
        notification.setId(1L);
        notification.setRecipient(null);
        notification.setMessage(null);

        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertFalse(violations.isEmpty(), "Notification with multiple missing fields should have violations");
        assertEquals(2, violations.size());
    }

    @Test
    public void testGettersAndSetters() {
        Notification notification = new Notification();
        
        notification.setId(5L);
        assertEquals(5L, notification.getId());
        
        notification.setRecipient("user@example.com");
        assertEquals("user@example.com", notification.getRecipient());
        
        notification.setMessage("Test message");
        assertEquals("Test message", notification.getMessage());
        
        notification.setType("SMS");
        assertEquals("SMS", notification.getType());
        
        notification.setSent(true);
        assertTrue(notification.isSent());
        
        notification.setSent(false);
        assertFalse(notification.isSent());
    }

    @Test
    public void testEqualsAndHashCode() {
        Notification notification1 = new Notification();
        notification1.setId(1L);
        notification1.setRecipient("test@example.com");
        notification1.setMessage("Welcome to our bank!");
        notification1.setType("EMAIL");
        notification1.setSent(true);

        Notification notification2 = new Notification();
        notification2.setId(1L);
        notification2.setRecipient("test@example.com");
        notification2.setMessage("Welcome to our bank!");
        notification2.setType("EMAIL");
        notification2.setSent(true);

        Notification notification3 = new Notification();
        notification3.setId(2L);
        notification3.setRecipient("other@example.com");
        notification3.setMessage("Different message");
        notification3.setType("SMS");
        notification3.setSent(false);

        assertEquals(notification1, notification2);
        assertEquals(notification1.hashCode(), notification2.hashCode());
        assertNotEquals(notification1, notification3);
        assertNotEquals(notification1.hashCode(), notification3.hashCode());
    }

    @Test
    public void testToString() {
        Notification notification = new Notification();
        notification.setId(1L);
        notification.setRecipient("test@example.com");
        notification.setMessage("Welcome to our bank!");
        notification.setType("EMAIL");
        notification.setSent(true);

        String toString = notification.toString();
        assertNotNull(toString);
        assertTrue(toString.contains("test@example.com"));
        assertTrue(toString.contains("Welcome to our bank!"));
        assertTrue(toString.contains("EMAIL"));
    }

    @Test
    public void testSentToggle() {
        Notification notification = new Notification();
        assertFalse(notification.isSent());
        
        notification.setSent(true);
        assertTrue(notification.isSent());
        
        notification.setSent(false);
        assertFalse(notification.isSent());
    }

    @Test
    public void testNullableFields() {
        Notification notification = new Notification();
        notification.setRecipient("test@example.com");
        notification.setMessage("Test message");
        
        // Type can be null
        notification.setType(null);
        assertNull(notification.getType());
        
        // Validation should still pass for required fields
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertTrue(violations.isEmpty());
    }

    @Test
    public void testEmailNotification() {
        Notification notification = new Notification();
        notification.setRecipient("user@example.com");
        notification.setMessage("Your account is ready");
        notification.setType("EMAIL");
        
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertTrue(violations.isEmpty());
        assertEquals("EMAIL", notification.getType());
    }

    @Test
    public void testSMSNotification() {
        Notification notification = new Notification();
        notification.setRecipient("+1234567890");
        notification.setMessage("Your OTP is 123456");
        notification.setType("SMS");
        
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertTrue(violations.isEmpty());
        assertEquals("SMS", notification.getType());
    }

    @Test
    public void testPushNotification() {
        Notification notification = new Notification();
        notification.setRecipient("device-token-12345");
        notification.setMessage("New transaction alert");
        notification.setType("PUSH");
        
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertTrue(violations.isEmpty());
        assertEquals("PUSH", notification.getType());
    }

    @Test
    public void testLongMessage() {
        String longMessage = "This is a very long message that contains a lot of text. ".repeat(50);
        Notification notification = new Notification();
        notification.setRecipient("test@example.com");
        notification.setMessage(longMessage);
        notification.setType("EMAIL");
        
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertTrue(violations.isEmpty());
        assertEquals(longMessage, notification.getMessage());
    }

    @Test
    public void testSpecialCharactersInMessage() {
        Notification notification = new Notification();
        notification.setRecipient("test@example.com");
        notification.setMessage("Hello! @#$%^&*() 你好 مرحبا");
        notification.setType("EMAIL");
        
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertTrue(violations.isEmpty());
        assertTrue(notification.getMessage().contains("@#$%^&*()"));
    }

    @Test
    public void testWhitespaceInRecipient() {
        Notification notification = new Notification();
        notification.setRecipient("   ");
        notification.setMessage("Test message");
        
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertFalse(violations.isEmpty(), "Whitespace-only recipient should have violations");
    }

    @Test
    public void testWhitespaceInMessage() {
        Notification notification = new Notification();
        notification.setRecipient("test@example.com");
        notification.setMessage("   ");
        
        Set<ConstraintViolation<Notification>> violations = validator.validate(notification);
        assertFalse(violations.isEmpty(), "Whitespace-only message should have violations");
    }
}
