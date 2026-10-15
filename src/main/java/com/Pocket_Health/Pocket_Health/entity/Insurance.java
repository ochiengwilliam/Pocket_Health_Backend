package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "insurance")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Insurance {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "insurance_id", updatable = false, nullable = false)
    private UUID insuranceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    private Profile profile;

    @Column(name = "insurer_name", nullable = false)
    private String insurerName;

    @Column(name = "policy_number")
    private String policyNumber;

    @Column(name = "phone_1")
    private String phone1;

    @Column(name = "phone_2")
    private String phone2;

    private String email;
}
