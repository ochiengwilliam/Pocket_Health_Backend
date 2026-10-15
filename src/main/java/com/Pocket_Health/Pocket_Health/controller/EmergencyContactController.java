package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.EmergencyContact;
import com.Pocket_Health.Pocket_Health.service.EmergencyContactService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/emergency-contacts")
@RequiredArgsConstructor
public class EmergencyContactController {

    private final EmergencyContactService emergencyContactService;

    @PostMapping
    public ResponseEntity<ApiResponse<EmergencyContact>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Emergency contact created", emergencyContactService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<EmergencyContact>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Contacts fetched", emergencyContactService.getByProfile(profileId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EmergencyContact>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Contact fetched", emergencyContactService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<EmergencyContact>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Contact updated", emergencyContactService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        emergencyContactService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Contact deleted", null));
    }
}
