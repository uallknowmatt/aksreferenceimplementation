package com.bank.accountopening.customer.service;

import com.bank.accountopening.customer.model.Customer;
import com.bank.accountopening.customer.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CustomerService {

    private final CustomerRepository customerRepository;

    @Autowired
    public CustomerService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    @Transactional
    public Customer createCustomer(Customer customer) {
        if (customerRepository.existsByEmail(customer.getEmail())) {
            throw new RuntimeException("Customer with this email already exists");
        }
        return customerRepository.save(customer);
    }

    public Customer getCustomer(Long id) {
        return customerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
    }

    @Transactional
    public Customer updateKycStatus(Long customerId, boolean kycStatus) {
        Customer customer = getCustomer(customerId);
        customer.setKycVerified(kycStatus);
        return customerRepository.save(customer);
    }
}
