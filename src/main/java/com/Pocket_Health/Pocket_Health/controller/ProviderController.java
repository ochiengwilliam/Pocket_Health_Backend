package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.service.ProviderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/providers")
@RequiredArgsConstructor
public class ProviderController {

    private final ProviderService providerService;

    @PostMapping
    public ResponseEntity<ApiResponse<Provider>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Provider created", providerService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Provider>>> getAll(
            @RequestParam(required = false) String region,
            @RequestParam(required = false) Boolean available) {
        List<Provider> providers = region != null ? providerService.getByRegion(region)
                : available != null && available ? providerService.getAvailable()
                : providerService.getAll();
        return ResponseEntity.ok(ApiResponse.ok("Providers fetched", providers));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<Provider>>> search(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String specialty,
            @RequestParam(required = false) String region,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Boolean available) {
        return ResponseEntity.ok(ApiResponse.ok("Providers fetched",
                providerService.search(query, specialty, region, category, available)));
    }

    @GetMapping("/specialties")
    public ResponseEntity<ApiResponse<List<String>>> getSpecialties() {
        return ResponseEntity.ok(ApiResponse.ok("Specialties fetched", providerService.getSpecialties()));
    }

    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<String>>> getCategories() {
        return ResponseEntity.ok(ApiResponse.ok("Categories fetched", providerService.getCategories()));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Provider>> getByUserId(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Provider fetched", providerService.getByUserId(userId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Provider>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Provider fetched", providerService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Provider>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Provider updated", providerService.update(id, body)));
    }
}
