package com.bank.accountopening.customer.service;

import com.bank.accountopening.customer.model.Customer;
import com.bank.accountopening.customer.repository.CustomerRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CustomerServiceTest {

    @Mock
    private CustomerRepository customerRepository;

    @InjectMocks
    private CustomerService customerService;

    private Customer testCustomer;

    @BeforeEach
    void setUp() {
        testCustomer = new Customer();
        testCustomer.setId(1L);
        testCustomer.setFirstName("John");
        testCustomer.setLastName("Doe");
        testCustomer.setEmail("john.doe@example.com");
        testCustomer.setPhoneNumber("+1234567890");
        testCustomer.setAddress("123 Main St");
        testCustomer.setIdentificationNumber("ID123456");
        testCustomer.setIdentificationType("Passport");
        testCustomer.setKycVerified(false);
    }

    @Test
    void createCustomer_Success() {
        when(customerRepository.existsByEmail(testCustomer.getEmail())).thenReturn(false);
        when(customerRepository.save(any(Customer.class))).thenReturn(testCustomer);

        Customer result = customerService.createCustomer(testCustomer);

        assertNotNull(result);
        assertEquals(testCustomer.getId(), result.getId());
        assertEquals(testCustomer.getEmail(), result.getEmail());
        assertEquals(testCustomer.getFirstName(), result.getFirstName());
        assertEquals(testCustomer.getLastName(), result.getLastName());
        
        verify(customerRepository).existsByEmail(testCustomer.getEmail());
        verify(customerRepository).save(testCustomer);
    }

    @Test
    void createCustomer_DuplicateEmail() {
        when(customerRepository.existsByEmail(testCustomer.getEmail())).thenReturn(true);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            customerService.createCustomer(testCustomer);
        });

        assertEquals("Customer with this email already exists", exception.getMessage());
        verify(customerRepository).existsByEmail(testCustomer.getEmail());
        verify(customerRepository, never()).save(any(Customer.class));
    }

    @Test
    void getCustomer_Success() {
        when(customerRepository.findById(1L)).thenReturn(Optional.of(testCustomer));

        Customer result = customerService.getCustomer(1L);

        assertNotNull(result);
        assertEquals(testCustomer.getId(), result.getId());
        assertEquals(testCustomer.getEmail(), result.getEmail());
        verify(customerRepository).findById(1L);
    }

    @Test
    void getCustomer_NotFound() {
        when(customerRepository.findById(999L)).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            customerService.getCustomer(999L);
        });

        assertEquals("Customer not found", exception.getMessage());
        verify(customerRepository).findById(999L);
    }

    @Test
    void updateKycStatus_VerifyTrue() {
        when(customerRepository.findById(1L)).thenReturn(Optional.of(testCustomer));
        when(customerRepository.save(any(Customer.class))).thenReturn(testCustomer);

        Customer result = customerService.updateKycStatus(1L, true);

        assertNotNull(result);
        assertTrue(result.isKycVerified());
        verify(customerRepository).findById(1L);
        verify(customerRepository).save(testCustomer);
    }

    @Test
    void updateKycStatus_VerifyFalse() {
        testCustomer.setKycVerified(true);
        when(customerRepository.findById(1L)).thenReturn(Optional.of(testCustomer));
        when(customerRepository.save(any(Customer.class))).thenReturn(testCustomer);

        Customer result = customerService.updateKycStatus(1L, false);

        assertNotNull(result);
        assertFalse(result.isKycVerified());
        verify(customerRepository).findById(1L);
        verify(customerRepository).save(testCustomer);
    }

    @Test
    void updateKycStatus_CustomerNotFound() {
        when(customerRepository.findById(999L)).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            customerService.updateKycStatus(999L, true);
        });

        assertEquals("Customer not found", exception.getMessage());
        verify(customerRepository).findById(999L);
        verify(customerRepository, never()).save(any(Customer.class));
    }
}
