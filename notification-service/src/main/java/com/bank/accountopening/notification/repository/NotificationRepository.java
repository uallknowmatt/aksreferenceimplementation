package com.bank.accountopening.notification.repository;

import com.bank.accountopening.notification.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
}
