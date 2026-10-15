package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/profiles")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @PostMapping
    public ResponseEntity<ApiResponse<Profile>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Profile created", profileService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Profile>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Profiles fetched", profileService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Profile>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Profile fetched", profileService.getById(id)));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<Profile>>> getByUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Profiles fetched", profileService.getByUserId(userId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Profile>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Profile updated", profileService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        profileService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Profile deleted", null));
    }
}
