package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.entity.Review;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import com.Pocket_Health.Pocket_Health.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final ProfileRepository profileRepository;
    private final ProviderRepository providerRepository;

    public Review create(Map<String, Object> body) {
        Profile profile = profileRepository
                .findById(UUID.fromString((String) body.get("reviewerProfileId")))
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        Provider provider = providerRepository
                .findById(UUID.fromString((String) body.get("providerId")))
                .orElseThrow(() -> new RuntimeException("Provider not found"));

        Review review = Review.builder()
                .reviewerProfile(profile)
                .provider(provider)
                .ratingQuality(body.get("ratingQuality") != null ? Short.valueOf(body.get("ratingQuality").toString()) : null)
                .ratingHelpful(body.get("ratingHelpful") != null ? Short.valueOf(body.get("ratingHelpful").toString()) : null)
                .ratingTimely(body.get("ratingTimely") != null ? Short.valueOf(body.get("ratingTimely").toString()) : null)
                .ratingCare(body.get("ratingCare") != null ? Short.valueOf(body.get("ratingCare").toString()) : null)
                .reviewText((String) body.get("reviewText"))
                .build();
        return reviewRepository.save(review);
    }

    public List<Review> getByProvider(UUID providerId) {
        return reviewRepository.findByProvider_ProviderId(providerId);
    }

    public Map<String, Object> getProviderRating(UUID providerId) {
        Double avg = reviewRepository.findAverageRatingByProviderId(providerId);
        return Map.of(
                "providerId", providerId,
                "totalReviews", reviewRepository.findByProvider_ProviderId(providerId).size(),
                "averageRating", avg != null ? Math.round(avg * 10.0) / 10.0 : 0.0
        );
    }

    public Review getById(UUID id) {
        return reviewRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Review not found"));
    }

    public void delete(UUID id) { reviewRepository.deleteById(id); }
}
