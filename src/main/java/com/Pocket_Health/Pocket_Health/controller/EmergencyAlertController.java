package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.EmergencyAlert;
import com.Pocket_Health.Pocket_Health.service.EmergencyAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/emergency-alerts")
@RequiredArgsConstructor
public class EmergencyAlertController {

    private final EmergencyAlertService emergencyAlertService;

    @PostMapping
    public ResponseEntity<ApiResponse<EmergencyAlert>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Emergency alert logged", emergencyAlertService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<EmergencyAlert>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Alerts fetched", emergencyAlertService.getByProfile(profileId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<EmergencyAlert>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Alert updated", emergencyAlertService.update(id, body)));
    }
}
