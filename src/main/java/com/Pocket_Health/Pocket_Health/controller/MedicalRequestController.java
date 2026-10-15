package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.MedicalRequest;
import com.Pocket_Health.Pocket_Health.service.MedicalRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/medical-requests")
@RequiredArgsConstructor
public class MedicalRequestController {

    private final MedicalRequestService medicalRequestService;

    @PostMapping
    public ResponseEntity<ApiResponse<MedicalRequest>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Medical request created", medicalRequestService.create(body)));
    }

    @GetMapping("/consultation/{consultationId}")
    public ResponseEntity<ApiResponse<List<MedicalRequest>>> getByConsultation(@PathVariable UUID consultationId) {
        return ResponseEntity.ok(ApiResponse.ok("Requests fetched", medicalRequestService.getByConsultation(consultationId)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MedicalRequest>>> getByType(
            @RequestParam(required = false, defaultValue = "prescription") String type) {
        return ResponseEntity.ok(ApiResponse.ok("Requests fetched", medicalRequestService.getByType(type)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<MedicalRequest>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Request fetched", medicalRequestService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<MedicalRequest>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Request updated", medicalRequestService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        medicalRequestService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Request deleted", null));
    }
}
