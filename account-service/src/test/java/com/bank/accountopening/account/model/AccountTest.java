package com.bank.accountopening.account.model;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

public class AccountTest {

    private Validator validator;

    @BeforeEach
    public void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    public void testValidAccount() {
        Account account = new Account();
        account.setId(1L);
        account.setAccountNumber("ACC-123456");
        account.setAccountType("SAVINGS");
        account.setBalance(1000.00);
        account.setCustomerId(100L);
        account.setActive(true);

        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertTrue(violations.isEmpty(), "Valid account should have no violations");
    }

    @Test
    public void testInvalidAccount_BlankAccountNumber() {
        Account account = new Account();
        account.setId(1L);
        account.setAccountNumber("");
        account.setAccountType("SAVINGS");
        account.setBalance(1000.00);
        account.setCustomerId(100L);

        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertFalse(violations.isEmpty(), "Account with blank account number should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidAccount_NullAccountNumber() {
        Account account = new Account();
        account.setId(1L);
        account.setAccountNumber(null);
        account.setAccountType("SAVINGS");
        account.setBalance(1000.00);
        account.setCustomerId(100L);

        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertFalse(violations.isEmpty(), "Account with null account number should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidAccount_BlankAccountType() {
        Account account = new Account();
        account.setId(1L);
        account.setAccountNumber("ACC-123456");
        account.setAccountType("");
        account.setBalance(1000.00);
        account.setCustomerId(100L);

        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertFalse(violations.isEmpty(), "Account with blank account type should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidAccount_NullAccountType() {
        Account account = new Account();
        account.setId(1L);
        account.setAccountNumber("ACC-123456");
        account.setAccountType(null);
        account.setBalance(1000.00);
        account.setCustomerId(100L);

        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertFalse(violations.isEmpty(), "Account with null account type should have violations");
        assertEquals(1, violations.size());
    }

    @Test
    public void testInvalidAccount_MultipleMissingFields() {
        Account account = new Account();
        account.setId(1L);
        account.setAccountNumber(null);
        account.setAccountType(null);

        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertFalse(violations.isEmpty(), "Account with multiple missing fields should have violations");
        assertEquals(2, violations.size());
    }

    @Test
    public void testGettersAndSetters() {
        Account account = new Account();
        
        account.setId(5L);
        assertEquals(5L, account.getId());
        
        account.setAccountNumber("ACC-999999");
        assertEquals("ACC-999999", account.getAccountNumber());
        
        account.setAccountType("CHECKING");
        assertEquals("CHECKING", account.getAccountType());
        
        account.setBalance(2500.50);
        assertEquals(2500.50, account.getBalance());
        
        account.setCustomerId(200L);
        assertEquals(200L, account.getCustomerId());
        
        account.setActive(true);
        assertTrue(account.isActive());
        
        account.setActive(false);
        assertFalse(account.isActive());
    }

    @Test
    public void testEqualsAndHashCode() {
        Account account1 = new Account();
        account1.setId(1L);
        account1.setAccountNumber("ACC-123456");
        account1.setAccountType("SAVINGS");
        account1.setBalance(1000.00);
        account1.setCustomerId(100L);
        account1.setActive(true);

        Account account2 = new Account();
        account2.setId(1L);
        account2.setAccountNumber("ACC-123456");
        account2.setAccountType("SAVINGS");
        account2.setBalance(1000.00);
        account2.setCustomerId(100L);
        account2.setActive(true);

        Account account3 = new Account();
        account3.setId(2L);
        account3.setAccountNumber("ACC-789012");
        account3.setAccountType("CHECKING");
        account3.setBalance(500.00);
        account3.setCustomerId(200L);
        account3.setActive(false);

        assertEquals(account1, account2);
        assertEquals(account1.hashCode(), account2.hashCode());
        assertNotEquals(account1, account3);
        assertNotEquals(account1.hashCode(), account3.hashCode());
    }

    @Test
    public void testToString() {
        Account account = new Account();
        account.setId(1L);
        account.setAccountNumber("ACC-123456");
        account.setAccountType("SAVINGS");
        account.setBalance(1000.00);
        account.setCustomerId(100L);
        account.setActive(true);

        String toString = account.toString();
        assertNotNull(toString);
        assertTrue(toString.contains("ACC-123456"));
        assertTrue(toString.contains("SAVINGS"));
        assertTrue(toString.contains("100"));
    }

    @Test
    public void testActiveToggle() {
        Account account = new Account();
        assertFalse(account.isActive());
        
        account.setActive(true);
        assertTrue(account.isActive());
        
        account.setActive(false);
        assertFalse(account.isActive());
    }

    @Test
    public void testNullableFields() {
        Account account = new Account();
        account.setAccountNumber("ACC-123456");
        account.setAccountType("SAVINGS");
        
        // Balance can be null
        account.setBalance(null);
        assertNull(account.getBalance());
        
        // CustomerId can be null
        account.setCustomerId(null);
        assertNull(account.getCustomerId());
        
        // Validation should still pass for required fields
        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertTrue(violations.isEmpty());
    }

    @Test
    public void testZeroBalance() {
        Account account = new Account();
        account.setAccountNumber("ACC-123456");
        account.setAccountType("SAVINGS");
        account.setBalance(0.0);
        
        assertEquals(0.0, account.getBalance());
        
        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertTrue(violations.isEmpty());
    }

    @Test
    public void testNegativeBalance() {
        Account account = new Account();
        account.setAccountNumber("ACC-123456");
        account.setAccountType("CHECKING");
        account.setBalance(-100.00);
        
        assertEquals(-100.00, account.getBalance());
        
        // Note: No validation constraint on balance being positive
        Set<ConstraintViolation<Account>> violations = validator.validate(account);
        assertTrue(violations.isEmpty());
    }

    @Test
    public void testDifferentAccountTypes() {
        Account savingsAccount = new Account();
        savingsAccount.setAccountNumber("ACC-001");
        savingsAccount.setAccountType("SAVINGS");
        
        Account checkingAccount = new Account();
        checkingAccount.setAccountNumber("ACC-002");
        checkingAccount.setAccountType("CHECKING");
        
        Account fixedDepositAccount = new Account();
        fixedDepositAccount.setAccountNumber("ACC-003");
        fixedDepositAccount.setAccountType("FIXED_DEPOSIT");
        
        Set<ConstraintViolation<Account>> violations1 = validator.validate(savingsAccount);
        Set<ConstraintViolation<Account>> violations2 = validator.validate(checkingAccount);
        Set<ConstraintViolation<Account>> violations3 = validator.validate(fixedDepositAccount);
        
        assertTrue(violations1.isEmpty());
        assertTrue(violations2.isEmpty());
        assertTrue(violations3.isEmpty());
    }
}
