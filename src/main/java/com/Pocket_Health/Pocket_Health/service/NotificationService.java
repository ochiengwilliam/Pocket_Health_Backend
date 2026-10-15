package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Notification;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.NotificationRepository;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public Notification create(Map<String, Object> body) {
        User user = userRepository.findById(UUID.fromString((String) body.get("userId")))
                .orElseThrow(() -> new RuntimeException("User not found"));

        Notification n = Notification.builder()
                .user(user)
                .title((String) body.get("title"))
                .body((String) body.get("body"))
                .notifType((String) body.get("notifType"))
                .isRead(false)
                .build();
        return notificationRepository.save(n);
    }

    public List<Notification> getByUser(UUID userId) {
        return notificationRepository.findByUser_UserIdOrderByCreatedAtDesc(userId);
    }

    public List<Notification> getUnread(UUID userId) {
        return notificationRepository.findByUser_UserIdAndIsReadFalse(userId);
    }

    public long countUnread(UUID userId) {
        return notificationRepository.countByUser_UserIdAndIsReadFalse(userId);
    }

    public Notification markRead(UUID id) {
        Notification n = notificationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        n.setIsRead(true);
        return notificationRepository.save(n);
    }

    public void markAllRead(UUID userId) {
        List<Notification> unread = notificationRepository.findByUser_UserIdAndIsReadFalse(userId);
        unread.forEach(n -> n.setIsRead(true));
        notificationRepository.saveAll(unread);
    }
}
