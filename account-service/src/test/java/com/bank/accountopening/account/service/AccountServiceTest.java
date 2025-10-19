package com.bank.accountopening.account.service;

import com.bank.accountopening.account.model.Account;
import com.bank.accountopening.account.repository.AccountRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AccountServiceTest {

    @Mock
    private AccountRepository accountRepository;

    @InjectMocks
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
    public void testCreateAccount_Success() {
        when(accountRepository.existsByAccountNumber("ACC-123456")).thenReturn(false);
        when(accountRepository.save(any(Account.class))).thenReturn(testAccount);

        Account requestAccount = new Account();
        requestAccount.setAccountNumber("ACC-123456");
        requestAccount.setAccountType("SAVINGS");
        requestAccount.setBalance(1000.00);
        requestAccount.setCustomerId(100L);

        Account result = accountService.createAccount(requestAccount);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("ACC-123456", result.getAccountNumber());
        assertEquals("SAVINGS", result.getAccountType());
        assertEquals(1000.00, result.getBalance());
        assertEquals(100L, result.getCustomerId());
        assertTrue(result.isActive());

        verify(accountRepository, times(1)).existsByAccountNumber("ACC-123456");
        verify(accountRepository, times(1)).save(any(Account.class));
    }

    @Test
    public void testCreateAccount_DuplicateAccountNumber() {
        when(accountRepository.existsByAccountNumber("ACC-123456")).thenReturn(true);

        Account requestAccount = new Account();
        requestAccount.setAccountNumber("ACC-123456");
        requestAccount.setAccountType("SAVINGS");
        requestAccount.setBalance(1000.00);
        requestAccount.setCustomerId(100L);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            accountService.createAccount(requestAccount);
        });

        assertEquals("Account number already exists", exception.getMessage());

        verify(accountRepository, times(1)).existsByAccountNumber("ACC-123456");
        verify(accountRepository, never()).save(any(Account.class));
    }

    @Test
    public void testCreateAccount_CheckingAccount() {
        Account checkingAccount = new Account();
        checkingAccount.setId(2L);
        checkingAccount.setAccountNumber("ACC-789012");
        checkingAccount.setAccountType("CHECKING");
        checkingAccount.setBalance(500.00);
        checkingAccount.setCustomerId(200L);
        checkingAccount.setActive(true);

        when(accountRepository.existsByAccountNumber("ACC-789012")).thenReturn(false);
        when(accountRepository.save(any(Account.class))).thenReturn(checkingAccount);

        Account requestAccount = new Account();
        requestAccount.setAccountNumber("ACC-789012");
        requestAccount.setAccountType("CHECKING");
        requestAccount.setBalance(500.00);
        requestAccount.setCustomerId(200L);

        Account result = accountService.createAccount(requestAccount);

        assertNotNull(result);
        assertEquals("CHECKING", result.getAccountType());
        assertTrue(result.isActive());

        verify(accountRepository, times(1)).existsByAccountNumber("ACC-789012");
        verify(accountRepository, times(1)).save(any(Account.class));
    }

    @Test
    public void testGetAccountsByCustomer_Success() {
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
        when(accountRepository.findByCustomerId(100L)).thenReturn(accounts);

        List<Account> result = accountService.getAccountsByCustomer(100L);

        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("SAVINGS", result.get(0).getAccountType());
        assertEquals("CHECKING", result.get(1).getAccountType());

        verify(accountRepository, times(1)).findByCustomerId(100L);
    }

    @Test
    public void testGetAccountsByCustomer_EmptyList() {
        when(accountRepository.findByCustomerId(anyLong())).thenReturn(Arrays.asList());

        List<Account> result = accountService.getAccountsByCustomer(999L);

        assertNotNull(result);
        assertTrue(result.isEmpty());

        verify(accountRepository, times(1)).findByCustomerId(999L);
    }

    @Test
    public void testGetAccountsByCustomer_NullCustomerId() {
        when(accountRepository.findByCustomerId(null)).thenReturn(Arrays.asList());

        List<Account> result = accountService.getAccountsByCustomer(null);

        assertNotNull(result);
        assertTrue(result.isEmpty());

        verify(accountRepository, times(1)).findByCustomerId(null);
    }

    @Test
    public void testGetAccount_Success() {
        when(accountRepository.findById(1L)).thenReturn(Optional.of(testAccount));

        Account result = accountService.getAccount(1L);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("ACC-123456", result.getAccountNumber());
        assertEquals("SAVINGS", result.getAccountType());

        verify(accountRepository, times(1)).findById(1L);
    }

    @Test
    public void testGetAccount_NotFound() {
        when(accountRepository.findById(anyLong())).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            accountService.getAccount(999L);
        });

        assertEquals("Account not found", exception.getMessage());

        verify(accountRepository, times(1)).findById(999L);
    }

    @Test
    public void testCloseAccount_Success() {
        when(accountRepository.findById(1L)).thenReturn(Optional.of(testAccount));
        testAccount.setActive(false);
        when(accountRepository.save(any(Account.class))).thenReturn(testAccount);

        Account result = accountService.closeAccount(1L);

        assertNotNull(result);
        assertFalse(result.isActive());

        verify(accountRepository, times(1)).findById(1L);
        verify(accountRepository, times(1)).save(any(Account.class));
    }

    @Test
    public void testCloseAccount_AccountNotFound() {
        when(accountRepository.findById(anyLong())).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            accountService.closeAccount(999L);
        });

        assertEquals("Account not found", exception.getMessage());

        verify(accountRepository, times(1)).findById(999L);
        verify(accountRepository, never()).save(any(Account.class));
    }

    @Test
    public void testCloseAccount_AlreadyClosed() {
        testAccount.setActive(false);
        when(accountRepository.findById(1L)).thenReturn(Optional.of(testAccount));
        when(accountRepository.save(any(Account.class))).thenReturn(testAccount);

        Account result = accountService.closeAccount(1L);

        assertNotNull(result);
        assertFalse(result.isActive());

        verify(accountRepository, times(1)).findById(1L);
        verify(accountRepository, times(1)).save(any(Account.class));
    }

    @Test
    public void testCreateAccount_WithZeroBalance() {
        Account zeroBalanceAccount = new Account();
        zeroBalanceAccount.setId(3L);
        zeroBalanceAccount.setAccountNumber("ACC-000000");
        zeroBalanceAccount.setAccountType("SAVINGS");
        zeroBalanceAccount.setBalance(0.0);
        zeroBalanceAccount.setCustomerId(300L);
        zeroBalanceAccount.setActive(true);

        when(accountRepository.existsByAccountNumber("ACC-000000")).thenReturn(false);
        when(accountRepository.save(any(Account.class))).thenReturn(zeroBalanceAccount);

        Account requestAccount = new Account();
        requestAccount.setAccountNumber("ACC-000000");
        requestAccount.setAccountType("SAVINGS");
        requestAccount.setBalance(0.0);
        requestAccount.setCustomerId(300L);

        Account result = accountService.createAccount(requestAccount);

        assertNotNull(result);
        assertEquals(0.0, result.getBalance());
        assertTrue(result.isActive());

        verify(accountRepository, times(1)).existsByAccountNumber("ACC-000000");
        verify(accountRepository, times(1)).save(any(Account.class));
    }
}
