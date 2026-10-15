package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Consultation;
import com.Pocket_Health.Pocket_Health.service.ConsultationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/consultations")
@RequiredArgsConstructor
public class ConsultationController {

    private final ConsultationService consultationService;

    @PostMapping
    public ResponseEntity<ApiResponse<Consultation>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Consultation created", consultationService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Consultation>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Consultations fetched", consultationService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Consultation>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Consultation fetched", consultationService.getById(id)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<Consultation>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Consultations fetched", consultationService.getByProfile(profileId)));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<ApiResponse<List<Consultation>>> getByProvider(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Consultations fetched", consultationService.getByProvider(providerId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Consultation>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Consultation updated", consultationService.update(id, body)));
    }
}
