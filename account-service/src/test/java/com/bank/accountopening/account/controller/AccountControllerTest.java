package com.bank.accountopening.account.controller;

import com.bank.accountopening.account.model.Account;
import com.bank.accountopening.account.service.AccountService;
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
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AccountController.class)
public class AccountControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AccountService accountService;

    private Account testAccount;

    @BeforeEach
    public void setUp() {
        testAccount = new Account();
        testAccount.setId(1L);
        testAccount.setAccountNumber("ACC-123456");
        testAccount.setAccountType("SAVINGS");
        testAccount.setBalance(1000.00);
        testAccount.setCustomerId(100L);
        testAccount.setActive(true);
    }

    @Test
    public void testCreateAccount_Success() throws Exception {
        when(accountService.createAccount(any(Account.class))).thenReturn(testAccount);

        Account requestAccount = new Account();
        requestAccount.setAccountNumber("ACC-123456");
        requestAccount.setAccountType("SAVINGS");
        requestAccount.setBalance(1000.00);
        requestAccount.setCustomerId(100L);

        mockMvc.perform(post("/api/accounts")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestAccount)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.accountNumber").value("ACC-123456"))
                .andExpect(jsonPath("$.accountType").value("SAVINGS"))
                .andExpect(jsonPath("$.balance").value(1000.00))
                .andExpect(jsonPath("$.customerId").value(100))
                .andExpect(jsonPath("$.active").value(true));
    }

    @Test
    public void testCreateAccount_InvalidAccountNumber() throws Exception {
        Account requestAccount = new Account();
        requestAccount.setAccountNumber("");
        requestAccount.setAccountType("SAVINGS");
        requestAccount.setBalance(1000.00);
        requestAccount.setCustomerId(100L);

        mockMvc.perform(post("/api/accounts")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestAccount)))
                .andExpect(status().isBadRequest());
    }

    @Test
    public void testCreateAccount_InvalidAccountType() throws Exception {
        Account requestAccount = new Account();
        requestAccount.setAccountNumber("ACC-123456");
        requestAccount.setAccountType("");
        requestAccount.setBalance(1000.00);
        requestAccount.setCustomerId(100L);

        mockMvc.perform(post("/api/accounts")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestAccount)))
                .andExpect(status().isBadRequest());
    }

    @Test
    public void testCreateAccount_DuplicateAccountNumber() throws Exception {
        when(accountService.createAccount(any(Account.class)))
                .thenThrow(new RuntimeException("Account number already exists"));

        Account requestAccount = new Account();
        requestAccount.setAccountNumber("ACC-123456");
        requestAccount.setAccountType("SAVINGS");
        requestAccount.setBalance(1000.00);
        requestAccount.setCustomerId(100L);

        mockMvc.perform(post("/api/accounts")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestAccount)))
                .andExpect(status().isInternalServerError());
    }

    @Test
    public void testGetAccountsByCustomer_Success() throws Exception {
        Account account1 = new Account();
        account1.setId(1L);
        account1.setAccountNumber("ACC-123456");
        account1.setAccountType("SAVINGS");
        account1.setCustomerId(100L);

        Account account2 = new Account();
        account2.setId(2L);
        account2.setAccountNumber("ACC-789012");
        account2.setAccountType("CHECKING");
        account2.setCustomerId(100L);

        List<Account> accounts = Arrays.asList(account1, account2);
        when(accountService.getAccountsByCustomer(100L)).thenReturn(accounts);

        mockMvc.perform(get("/api/accounts/customer/100")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].accountNumber").value("ACC-123456"))
                .andExpect(jsonPath("$[0].accountType").value("SAVINGS"))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].accountNumber").value("ACC-789012"))
                .andExpect(jsonPath("$[1].accountType").value("CHECKING"));
    }

    @Test
    public void testGetAccountsByCustomer_EmptyList() throws Exception {
        when(accountService.getAccountsByCustomer(anyLong())).thenReturn(Arrays.asList());

        mockMvc.perform(get("/api/accounts/customer/999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    public void testGetAccount_Success() throws Exception {
        when(accountService.getAccount(1L)).thenReturn(testAccount);

        mockMvc.perform(get("/api/accounts/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.accountNumber").value("ACC-123456"))
                .andExpect(jsonPath("$.accountType").value("SAVINGS"))
                .andExpect(jsonPath("$.balance").value(1000.00))
                .andExpect(jsonPath("$.active").value(true));
    }

    @Test
    public void testGetAccount_NotFound() throws Exception {
        when(accountService.getAccount(anyLong()))
                .thenThrow(new RuntimeException("Account not found"));

        mockMvc.perform(get("/api/accounts/999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isInternalServerError());
    }

    @Test
    public void testCloseAccount_Success() throws Exception {
        testAccount.setActive(false);
        when(accountService.closeAccount(1L)).thenReturn(testAccount);

        mockMvc.perform(put("/api/accounts/1/close")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.active").value(false));
    }

    @Test
    public void testCloseAccount_AccountNotFound() throws Exception {
        when(accountService.closeAccount(anyLong()))
                .thenThrow(new RuntimeException("Account not found"));

        mockMvc.perform(put("/api/accounts/999/close")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isInternalServerError());
    }
}
