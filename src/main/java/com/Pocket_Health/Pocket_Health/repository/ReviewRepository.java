package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.UUID;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    List<Review> findByProvider_ProviderId(UUID providerId);

    @Query("SELECT AVG(r.ratingQuality + r.ratingHelpful + r.ratingTimely + r.ratingCare) / 4.0 FROM Review r WHERE r.provider.providerId = :providerId")
    Double findAverageRatingByProviderId(UUID providerId);
}
