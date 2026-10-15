package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Appointment;
import com.Pocket_Health.Pocket_Health.service.AppointmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/appointments")
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentService appointmentService;

    @PostMapping
    public ResponseEntity<ApiResponse<Appointment>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Appointment booked", appointmentService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Appointment>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Appointments fetched", appointmentService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Appointment>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Appointment fetched", appointmentService.getById(id)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<Appointment>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Appointments fetched", appointmentService.getByProfile(profileId)));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<ApiResponse<List<Appointment>>> getByProvider(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Appointments fetched", appointmentService.getByProvider(providerId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Appointment>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Appointment updated", appointmentService.update(id, body)));
    }

    @DeleteMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancel(@PathVariable UUID id) {
        appointmentService.cancel(id);
        return ResponseEntity.ok(ApiResponse.ok("Appointment cancelled", null));
    }
}
