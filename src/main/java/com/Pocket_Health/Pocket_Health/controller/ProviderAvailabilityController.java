package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.ProviderAvailability;
import com.Pocket_Health.Pocket_Health.service.ProviderAvailabilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/providers")
@RequiredArgsConstructor
public class ProviderAvailabilityController {

    private final ProviderAvailabilityService availabilityService;

    @PostMapping("/{id}/availability")
    public ResponseEntity<ApiResponse<ProviderAvailability>> create(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        body.put("providerId", id.toString());
        return ResponseEntity.ok(ApiResponse.ok("Availability window created", availabilityService.create(body)));
    }

    @GetMapping("/{id}/availability")
    public ResponseEntity<ApiResponse<List<ProviderAvailability>>> getByProvider(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Availability windows fetched", availabilityService.getByProvider(id)));
    }

    @GetMapping("/{id}/availability/slots")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getSlots(
            @PathVariable UUID id,
            @RequestParam String date) {
        return ResponseEntity.ok(ApiResponse.ok("Available slots fetched",
                availabilityService.getAvailableSlots(id, LocalDate.parse(date))));
    }

    @PatchMapping("/availability/{availabilityId}")
    public ResponseEntity<ApiResponse<ProviderAvailability>> update(
            @PathVariable UUID availabilityId, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Availability window updated", availabilityService.update(availabilityId, body)));
    }

    @DeleteMapping("/availability/{availabilityId}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID availabilityId) {
        availabilityService.delete(availabilityId);
        return ResponseEntity.ok(ApiResponse.ok("Availability window deleted", null));
    }
}
