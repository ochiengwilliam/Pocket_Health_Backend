package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Notification;
import com.Pocket_Health.Pocket_Health.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping
    public ResponseEntity<ApiResponse<Notification>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Notification created", notificationService.create(body)));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<Notification>>> getByUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Notifications fetched", notificationService.getByUser(userId)));
    }

    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<ApiResponse<List<Notification>>> getUnread(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Unread notifications", notificationService.getUnread(userId)));
    }

    @GetMapping("/user/{userId}/unread/count")
    public ResponseEntity<ApiResponse<Long>> countUnread(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Unread count", notificationService.countUnread(userId)));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Notification>> markRead(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Notification marked read", notificationService.markRead(id)));
    }

    @PatchMapping("/user/{userId}/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllRead(@PathVariable UUID userId) {
        notificationService.markAllRead(userId);
        return ResponseEntity.ok(ApiResponse.ok("All notifications marked read", null));
    }
}
