package com.bank.accountopening.notification.controller;

import com.bank.accountopening.notification.model.Notification;
import com.bank.accountopening.notification.service.NotificationService;
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
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(NotificationController.class)
public class NotificationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
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
    public void testSendNotification_Success() throws Exception {
        when(notificationService.sendNotification(any(Notification.class))).thenReturn(testNotification);

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage("Welcome to our bank!");
        requestNotification.setType("EMAIL");

        mockMvc.perform(post("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestNotification)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.recipient").value("test@example.com"))
                .andExpect(jsonPath("$.message").value("Welcome to our bank!"))
                .andExpect(jsonPath("$.type").value("EMAIL"))
                .andExpect(jsonPath("$.sent").value(true));
    }

    @Test
    public void testSendNotification_InvalidRecipient() throws Exception {
        Notification requestNotification = new Notification();
        requestNotification.setRecipient("");
        requestNotification.setMessage("Welcome to our bank!");
        requestNotification.setType("EMAIL");

        mockMvc.perform(post("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestNotification)))
                .andExpect(status().isBadRequest());
    }

    @Test
    public void testSendNotification_InvalidMessage() throws Exception {
        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage("");
        requestNotification.setType("EMAIL");

        mockMvc.perform(post("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestNotification)))
                .andExpect(status().isBadRequest());
    }

    @Test
    public void testSendNotification_SMS() throws Exception {
        Notification smsNotification = new Notification();
        smsNotification.setId(2L);
        smsNotification.setRecipient("+1234567890");
        smsNotification.setMessage("Your account has been created");
        smsNotification.setType("SMS");
        smsNotification.setSent(true);

        when(notificationService.sendNotification(any(Notification.class))).thenReturn(smsNotification);

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("+1234567890");
        requestNotification.setMessage("Your account has been created");
        requestNotification.setType("SMS");

        mockMvc.perform(post("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestNotification)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(2))
                .andExpect(jsonPath("$.recipient").value("+1234567890"))
                .andExpect(jsonPath("$.type").value("SMS"))
                .andExpect(jsonPath("$.sent").value(true));
    }

    @Test
    public void testGetAllNotifications_Success() throws Exception {
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
        when(notificationService.getAllNotifications()).thenReturn(notifications);

        mockMvc.perform(get("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].recipient").value("user1@example.com"))
                .andExpect(jsonPath("$[0].message").value("Message 1"))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].recipient").value("user2@example.com"))
                .andExpect(jsonPath("$[1].message").value("Message 2"));
    }

    @Test
    public void testGetAllNotifications_EmptyList() throws Exception {
        when(notificationService.getAllNotifications()).thenReturn(Arrays.asList());

        mockMvc.perform(get("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    public void testSendNotification_ServiceThrowsException() throws Exception {
        when(notificationService.sendNotification(any(Notification.class)))
                .thenThrow(new RuntimeException("Failed to send notification"));

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage("Welcome to our bank!");
        requestNotification.setType("EMAIL");

        mockMvc.perform(post("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestNotification)))
                .andExpect(status().isInternalServerError());
    }

    @Test
    public void testSendNotification_WithoutType() throws Exception {
        Notification notificationWithoutType = new Notification();
        notificationWithoutType.setId(3L);
        notificationWithoutType.setRecipient("test@example.com");
        notificationWithoutType.setMessage("Test message");
        notificationWithoutType.setSent(true);

        when(notificationService.sendNotification(any(Notification.class))).thenReturn(notificationWithoutType);

        Notification requestNotification = new Notification();
        requestNotification.setRecipient("test@example.com");
        requestNotification.setMessage("Test message");

        mockMvc.perform(post("/api/notifications")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestNotification)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sent").value(true));
    }
}
