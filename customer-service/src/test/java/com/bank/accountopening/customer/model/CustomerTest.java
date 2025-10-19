package com.bank.accountopening.customer.model;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class CustomerTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void validCustomer() {
        Customer customer = new Customer();
        customer.setFirstName("John");
        customer.setLastName("Doe");
        customer.setEmail("john.doe@example.com");
        customer.setPhoneNumber("+1234567890");
        customer.setAddress("123 Main St");
        customer.setIdentificationNumber("ID123456");
        customer.setIdentificationType("Passport");
        customer.setKycVerified(false);

        Set<ConstraintViolation<Customer>> violations = validator.validate(customer);
        assertTrue(violations.isEmpty());
    }

    @Test
    void invalidEmail() {
        Customer customer = new Customer();
        customer.setFirstName("John");
        customer.setLastName("Doe");
        customer.setEmail("invalid-email");

        Set<ConstraintViolation<Customer>> violations = validator.validate(customer);
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getPropertyPath().toString().equals("email")));
    }

    @Test
    void blankFirstName() {
        Customer customer = new Customer();
        customer.setFirstName("");
        customer.setLastName("Doe");
        customer.setEmail("john.doe@example.com");

        Set<ConstraintViolation<Customer>> violations = validator.validate(customer);
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getPropertyPath().toString().equals("firstName")));
    }

    @Test
    void blankLastName() {
        Customer customer = new Customer();
        customer.setFirstName("John");
        customer.setLastName("");
        customer.setEmail("john.doe@example.com");

        Set<ConstraintViolation<Customer>> violations = validator.validate(customer);
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getPropertyPath().toString().equals("lastName")));
    }

    @Test
    void blankEmail() {
        Customer customer = new Customer();
        customer.setFirstName("John");
        customer.setLastName("Doe");
        customer.setEmail("");

        Set<ConstraintViolation<Customer>> violations = validator.validate(customer);
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getPropertyPath().toString().equals("email")));
    }

    @Test
    void gettersAndSetters() {
        Customer customer = new Customer();
        
        customer.setId(1L);
        customer.setFirstName("John");
        customer.setLastName("Doe");
        customer.setEmail("john@example.com");
        customer.setPhoneNumber("123456");
        customer.setAddress("Address");
        customer.setIdentificationNumber("ID123");
        customer.setIdentificationType("Passport");
        customer.setKycVerified(true);

        assertEquals(1L, customer.getId());
        assertEquals("John", customer.getFirstName());
        assertEquals("Doe", customer.getLastName());
        assertEquals("john@example.com", customer.getEmail());
        assertEquals("123456", customer.getPhoneNumber());
        assertEquals("Address", customer.getAddress());
        assertEquals("ID123", customer.getIdentificationNumber());
        assertEquals("Passport", customer.getIdentificationType());
        assertTrue(customer.isKycVerified());
    }

    @Test
    void testEquals() {
        Customer customer1 = new Customer();
        customer1.setId(1L);
        customer1.setEmail("john@example.com");

        Customer customer2 = new Customer();
        customer2.setId(1L);
        customer2.setEmail("john@example.com");

        assertEquals(customer1, customer2);
    }

    @Test
    void testHashCode() {
        Customer customer1 = new Customer();
        customer1.setId(1L);
        customer1.setEmail("john@example.com");

        Customer customer2 = new Customer();
        customer2.setId(1L);
        customer2.setEmail("john@example.com");

        assertEquals(customer1.hashCode(), customer2.hashCode());
    }

    @Test
    void testToString() {
        Customer customer = new Customer();
        customer.setId(1L);
        customer.setFirstName("John");
        customer.setEmail("john@example.com");

        String toString = customer.toString();
        assertNotNull(toString);
        assertTrue(toString.contains("John"));
        assertTrue(toString.contains("john@example.com"));
    }
}
