package com.bank.accountopening.account.repository;

import com.bank.accountopening.account.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AccountRepository extends JpaRepository<Account, Long> {
    List<Account> findByCustomerId(Long customerId);
    boolean existsByAccountNumber(String accountNumber);
}
