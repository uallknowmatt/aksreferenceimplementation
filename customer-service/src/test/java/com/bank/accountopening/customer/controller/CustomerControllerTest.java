package com.bank.accountopening.customer.controller;

import com.bank.accountopening.customer.model.Customer;
import com.bank.accountopening.customer.service.CustomerService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CustomerController.class)
class CustomerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
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
    void createCustomer_Success() throws Exception {
        when(customerService.createCustomer(any(Customer.class))).thenReturn(testCustomer);

        mockMvc.perform(post("/api/customers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(testCustomer)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.lastName").value("Doe"))
                .andExpect(jsonPath("$.email").value("john.doe@example.com"))
                .andExpect(jsonPath("$.kycVerified").value(false));
    }

    @Test
    void createCustomer_InvalidEmail() throws Exception {
        Customer invalidCustomer = new Customer();
        invalidCustomer.setFirstName("John");
        invalidCustomer.setLastName("Doe");
        invalidCustomer.setEmail("invalid-email");

        mockMvc.perform(post("/api/customers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidCustomer)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createCustomer_MissingRequiredFields() throws Exception {
        Customer invalidCustomer = new Customer();
        invalidCustomer.setEmail("john@example.com");

        mockMvc.perform(post("/api/customers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidCustomer)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void getCustomer_Success() throws Exception {
        when(customerService.getCustomer(1L)).thenReturn(testCustomer);

        mockMvc.perform(get("/api/customers/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.email").value("john.doe@example.com"));
    }

    @Test
    void getCustomer_NotFound() throws Exception {
        when(customerService.getCustomer(999L)).thenThrow(new RuntimeException("Customer not found"));

        mockMvc.perform(get("/api/customers/999"))
                .andExpect(status().isInternalServerError());
    }

    @Test
    void updateKycStatus_ToVerified() throws Exception {
        testCustomer.setKycVerified(true);
        when(customerService.updateKycStatus(1L, true)).thenReturn(testCustomer);

        mockMvc.perform(put("/api/customers/1/kyc")
                        .param("verified", "true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.kycVerified").value(true));
    }

    @Test
    void updateKycStatus_ToUnverified() throws Exception {
        testCustomer.setKycVerified(false);
        when(customerService.updateKycStatus(1L, false)).thenReturn(testCustomer);

        mockMvc.perform(put("/api/customers/1/kyc")
                        .param("verified", "false"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.kycVerified").value(false));
    }

    @Test
    void updateKycStatus_CustomerNotFound() throws Exception {
        when(customerService.updateKycStatus(eq(999L), eq(true)))
                .thenThrow(new RuntimeException("Customer not found"));

        mockMvc.perform(put("/api/customers/999/kyc")
                        .param("verified", "true"))
                .andExpect(status().isInternalServerError());
    }
}
