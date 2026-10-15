package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.HealthInfo;
import com.Pocket_Health.Pocket_Health.service.HealthInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/health-info")
@RequiredArgsConstructor
public class HealthInfoController {

    private final HealthInfoService healthInfoService;

    @PostMapping
    public ResponseEntity<ApiResponse<HealthInfo>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Health info created", healthInfoService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<HealthInfo>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Health info fetched", healthInfoService.getByProfileId(profileId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<HealthInfo>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Health info updated", healthInfoService.update(id, body)));
    }
}
