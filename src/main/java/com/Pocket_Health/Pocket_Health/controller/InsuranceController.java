package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Insurance;
import com.Pocket_Health.Pocket_Health.service.InsuranceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/insurance")
@RequiredArgsConstructor
public class InsuranceController {

    private final InsuranceService insuranceService;

    @PostMapping
    public ResponseEntity<ApiResponse<Insurance>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance created", insuranceService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<Insurance>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance fetched", insuranceService.getByProfile(profileId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Insurance>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance fetched", insuranceService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Insurance>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance updated", insuranceService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        insuranceService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Insurance deleted", null));
    }
}
