package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Review;
import com.Pocket_Health.Pocket_Health.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    public ResponseEntity<ApiResponse<Review>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Review submitted", reviewService.create(body)));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<ApiResponse<List<Review>>> getByProvider(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Reviews fetched", reviewService.getByProvider(providerId)));
    }

    @GetMapping("/provider/{providerId}/rating")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getRating(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Rating fetched", reviewService.getProviderRating(providerId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Review>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Review fetched", reviewService.getById(id)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        reviewService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Review deleted", null));
    }
}
