package com.bank.accountopening.notification.service;

import com.bank.accountopening.notification.model.Notification;
import com.bank.accountopening.notification.repository.NotificationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationService notificationService;

    private Notification testNotification;

    @BeforeEach
    public void setUp() {
        testNotification = new Notification();
        testNotification.setId(1L);
        testNotification.setRecipient("test@example.com");
        testNotification.setMessage("Welcome to our bank!");
        testNotification.setType("EMAIL");
        testNotification.setSent(true);
    }

    @Test
    public void testSendNotification_Success() {
        when(notificationRepository.save(any(Notification.class))).thenReturn(testNotification);

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage("Welcome to our bank!");
        requestNotification.setType("EMAIL");

        Notification result = notificationService.sendNotification(requestNotification);

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("test@example.com", result.getRecipient());
        assertEquals("Welcome to our bank!", result.getMessage());
        assertEquals("EMAIL", result.getType());
        assertTrue(result.isSent());

        verify(notificationRepository, times(1)).save(any(Notification.class));
    }

    @Test
    public void testSendNotification_SetsSentFlag() {
        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage("Welcome to our bank!");
        requestNotification.setType("EMAIL");
        requestNotification.setSent(false);

        testNotification.setSent(true);
        when(notificationRepository.save(any(Notification.class))).thenReturn(testNotification);

        Notification result = notificationService.sendNotification(requestNotification);

        assertNotNull(result);
        assertTrue(result.isSent());

        verify(notificationRepository, times(1)).save(any(Notification.class));
    }

    @Test
    public void testSendNotification_SMS() {
        Notification smsNotification = new Notification();
        smsNotification.setId(2L);
        smsNotification.setRecipient("+1234567890");
        smsNotification.setMessage("Your account has been created");
        smsNotification.setType("SMS");
        smsNotification.setSent(true);

        when(notificationRepository.save(any(Notification.class))).thenReturn(smsNotification);

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("+1234567890");
        requestNotification.setMessage("Your account has been created");
        requestNotification.setType("SMS");

        Notification result = notificationService.sendNotification(requestNotification);

        assertNotNull(result);
        assertEquals("+1234567890", result.getRecipient());
        assertEquals("SMS", result.getType());
        assertTrue(result.isSent());

        verify(notificationRepository, times(1)).save(any(Notification.class));
    }

    @Test
    public void testSendNotification_NullNotification() {
        assertThrows(IllegalArgumentException.class, () -> {
            notificationService.sendNotification(null);
        });

        verify(notificationRepository, never()).save(any());
    }

    @Test
    public void testGetAllNotifications_Success() {
        Notification notification1 = new Notification();
        notification1.setId(1L);
        notification1.setRecipient("user1@example.com");
        notification1.setMessage("Message 1");
        notification1.setType("EMAIL");
        notification1.setSent(true);

        Notification notification2 = new Notification();
        notification2.setId(2L);
        notification2.setRecipient("user2@example.com");
        notification2.setMessage("Message 2");
        notification2.setType("EMAIL");
        notification2.setSent(true);

        List<Notification> notifications = Arrays.asList(notification1, notification2);
        when(notificationRepository.findAll()).thenReturn(notifications);

        List<Notification> result = notificationService.getAllNotifications();

        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("user1@example.com", result.get(0).getRecipient());
        assertEquals("user2@example.com", result.get(1).getRecipient());

        verify(notificationRepository, times(1)).findAll();
    }

    @Test
    public void testGetAllNotifications_EmptyList() {
        when(notificationRepository.findAll()).thenReturn(Arrays.asList());

        List<Notification> result = notificationService.getAllNotifications();

        assertNotNull(result);
        assertTrue(result.isEmpty());

        verify(notificationRepository, times(1)).findAll();
    }

    @Test
    public void testSendNotification_WithoutType() {
        Notification notificationWithoutType = new Notification();
        notificationWithoutType.setId(3L);
        notificationWithoutType.setRecipient("test@example.com");
        notificationWithoutType.setMessage("Test message");
        notificationWithoutType.setSent(true);

        when(notificationRepository.save(any(Notification.class))).thenReturn(notificationWithoutType);

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage("Test message");

        Notification result = notificationService.sendNotification(requestNotification);

        assertNotNull(result);
        assertTrue(result.isSent());

        verify(notificationRepository, times(1)).save(any(Notification.class));
    }

    @Test
    public void testSendNotification_MultipleNotifications() {
        Notification notification1 = new Notification();
        notification1.setId(1L);
        notification1.setRecipient("user1@example.com");
        notification1.setMessage("Message 1");
        notification1.setType("EMAIL");
        notification1.setSent(true);

        Notification notification2 = new Notification();
        notification2.setId(2L);
        notification2.setRecipient("user2@example.com");
        notification2.setMessage("Message 2");
        notification2.setType("SMS");
        notification2.setSent(true);

        when(notificationRepository.save(any(Notification.class)))
                .thenReturn(notification1)
                .thenReturn(notification2);

        Notification request1 = new Notification();
        request1.setRecipient("user1@example.com");
        request1.setMessage("Message 1");
        request1.setType("EMAIL");

        Notification request2 = new Notification();
        request2.setRecipient("user2@example.com");
        request2.setMessage("Message 2");
        request2.setType("SMS");

        Notification result1 = notificationService.sendNotification(request1);
        Notification result2 = notificationService.sendNotification(request2);

        assertNotNull(result1);
        assertNotNull(result2);
        assertTrue(result1.isSent());
        assertTrue(result2.isSent());

        verify(notificationRepository, times(2)).save(any(Notification.class));
    }

    @Test
    public void testSendNotification_LongMessage() {
        String longMessage = "This is a very long message that exceeds the normal length. ".repeat(10);
        Notification longNotification = new Notification();
        longNotification.setId(4L);
        longNotification.setRecipient("test@example.com");
        longNotification.setMessage(longMessage);
        longNotification.setType("EMAIL");
        longNotification.setSent(true);

        when(notificationRepository.save(any(Notification.class))).thenReturn(longNotification);

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage(longMessage);
        requestNotification.setType("EMAIL");

        Notification result = notificationService.sendNotification(requestNotification);

        assertNotNull(result);
        assertEquals(longMessage, result.getMessage());
        assertTrue(result.isSent());

        verify(notificationRepository, times(1)).save(any(Notification.class));
    }
}
