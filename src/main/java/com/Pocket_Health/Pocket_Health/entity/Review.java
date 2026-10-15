package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "review")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "review_id", updatable = false, nullable = false)
    private UUID reviewId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewer_profile_id", nullable = false)
    private Profile reviewerProfile;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private Provider provider;

    @Column(name = "rating_quality")
    private Short ratingQuality;

    @Column(name = "rating_helpful")
    private Short ratingHelpful;

    @Column(name = "rating_timely")
    private Short ratingTimely;

    @Column(name = "rating_care")
    private Short ratingCare;

    @Column(name = "review_text", columnDefinition = "TEXT")
    private String reviewText;
}
