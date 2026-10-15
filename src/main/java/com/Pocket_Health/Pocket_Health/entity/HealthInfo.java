package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "health_info")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class HealthInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "health_info_id", updatable = false, nullable = false)
    private UUID healthInfoId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false, unique = true)
    private Profile profile;

    private String identifier;

    @Column(name = "blood_group")
    private String bloodGroup;

    @Column(columnDefinition = "TEXT")
    private String allergies;

    @Column(name = "chronic_conditions", columnDefinition = "TEXT")
    private String chronicConditions;

    @Column(name = "mental_conditions", columnDefinition = "TEXT")
    private String mentalConditions;

    @Column(name = "long_term_meds", columnDefinition = "TEXT")
    private String longTermMeds;

    @Column(name = "family_history", columnDefinition = "TEXT")
    private String familyHistory;

    @Column(name = "drug_use", columnDefinition = "TEXT")
    private String drugUse;
}
