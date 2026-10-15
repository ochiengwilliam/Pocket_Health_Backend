package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "provider")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Provider {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "provider_id", updatable = false, nullable = false)
    private UUID providerId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "provider_name", nullable = false)
    private String providerName;

    private String category;
    private String specialty;
    private String location;
    private String region;

    @Column(name = "is_verified", nullable = false)
    private Boolean isVerified = false;

    @Column(name = "is_available", nullable = false)
    private Boolean isAvailable = true;

    @Column(precision = 12, scale = 2)
    private BigDecimal rates;
}
