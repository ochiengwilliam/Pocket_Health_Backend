package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "next_of_kin")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NextOfKin {

    @Id
    @GeneratedValue
    @Column(name = "next_of_kin_id")
    private UUID nextOfKinId;

    @ManyToOne
    @JoinColumn(name = "profile_id", nullable = false)
    private Profile profile;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false)
    private String relationship;

    @Column(nullable = false)
    private String phone1;

    private String phone2;

    private String email;

    private String address;

    @Column(insertable = false, updatable = false)
    private OffsetDateTime createdAt;
}