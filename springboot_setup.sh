#!/bin/bash
# ================================================================
#  PocketHealth — Spring Boot Full Setup Script
#  Run from project root:
#  chmod +x springboot_setup.sh && ./springboot_setup.sh
# ================================================================

BASE="src/main/java/com/Pocket_Health/Pocket_Health"
mkdir -p $BASE/entity $BASE/repository $BASE/service $BASE/controller \
         $BASE/security $BASE/config $BASE/dto/request $BASE/dto/response

# ================================================================
# ENTITIES
# ================================================================

# ── User ─────────────────────────────────────────────────────────
cat > $BASE/entity/User.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "\"user\"")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "user_id", updatable = false, nullable = false)
    private UUID userId;

    @Column(name = "log_number", unique = true)
    private String logNumber;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "pin_hash", nullable = false)
    private String pinHash;

    @Column(name = "user_category", nullable = false)
    private String userCategory;

    @Column(nullable = false)
    private String status = "active";

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
EOF

# ── Profile ──────────────────────────────────────────────────────
cat > $BASE/entity/Profile.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "profile")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Profile {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "profile_id", updatable = false, nullable = false)
    private UUID profileId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String surname;

    @Column(name = "other_names")
    private String otherNames;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    private String gender;

    @Column(name = "phone_1")
    private String phone1;

    private String residence;
    private String region;
    private String relation;

    @Column(name = "is_primary", nullable = false)
    private Boolean isPrimary = false;
}
EOF

# ── HealthInfo ───────────────────────────────────────────────────
cat > $BASE/entity/HealthInfo.java << 'EOF'
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
EOF

# ── Provider ─────────────────────────────────────────────────────
cat > $BASE/entity/Provider.java << 'EOF'
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
EOF

# ── EmergencyContact ─────────────────────────────────────────────
cat > $BASE/entity/EmergencyContact.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "emergency_contact")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class EmergencyContact {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "contact_id", updatable = false, nullable = false)
    private UUID contactId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    private Profile profile;

    @Column(nullable = false)
    private String name;

    @Column(name = "phone_1", nullable = false)
    private String phone1;

    @Column(name = "phone_2")
    private String phone2;

    private Short priority = 1;

    @Column(name = "emergency_type")
    private String emergencyType;
}
EOF

# ── Insurance ────────────────────────────────────────────────────
cat > $BASE/entity/Insurance.java << 'EOF'
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
}
EOF

# ── Wallet ───────────────────────────────────────────────────────
cat > $BASE/entity/Wallet.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "wallet")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "wallet_id", updatable = false, nullable = false)
    private UUID walletId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "balance_kes", nullable = false, precision = 14, scale = 2)
    private BigDecimal balanceKes = BigDecimal.ZERO;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;
}
EOF

# ── Transaction ──────────────────────────────────────────────────
cat > $BASE/entity/Transaction.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "transaction")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "transaction_id", updatable = false, nullable = false)
    private UUID transactionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false)
    private String type;

    @Column(name = "payment_method")
    private String paymentMethod;

    @Column(name = "mpesa_reference")
    private String mpesaReference;

    @Column(nullable = false)
    private String status = "pending";

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
EOF

# ── Consultation ─────────────────────────────────────────────────
cat > $BASE/entity/Consultation.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "consultation")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Consultation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "consultation_id", updatable = false, nullable = false)
    private UUID consultationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_profile_id", nullable = false)
    private Profile patientProfile;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private Provider provider;

    @Column(name = "call_type")
    private String callType;

    @Column(name = "started_at")
    private OffsetDateTime startedAt;

    @Column(name = "ended_at")
    private OffsetDateTime endedAt;

    @Column(name = "amount_charged", precision = 12, scale = 2)
    private BigDecimal amountCharged;

    @Column(nullable = false)
    private String status = "scheduled";
}
EOF

# ── Appointment ──────────────────────────────────────────────────
cat > $BASE/entity/Appointment.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "appointment")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "appointment_id", updatable = false, nullable = false)
    private UUID appointmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_profile_id", nullable = false)
    private Profile patientProfile;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private Provider provider;

    @Column(name = "scheduled_at", nullable = false)
    private OffsetDateTime scheduledAt;

    @Column(name = "duration_slot")
    private Integer durationSlot;

    @Column(nullable = false)
    private String status = "pending";

    @Column(nullable = false)
    private Boolean attended = false;
}
EOF

# ── Review ───────────────────────────────────────────────────────
cat > $BASE/entity/Review.java << 'EOF'
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
EOF

# ── Document ─────────────────────────────────────────────────────
cat > $BASE/entity/Document.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "document")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Document {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "document_id", updatable = false, nullable = false)
    private UUID documentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_profile_id", nullable = false)
    private Profile ownerProfile;

    @Column(name = "doc_type")
    private String docType;

    @Column(name = "file_url", nullable = false, columnDefinition = "TEXT")
    private String fileUrl;

    @Column(name = "file_name")
    private String fileName;

    @Column(name = "shared_with", columnDefinition = "TEXT")
    private String sharedWith;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
EOF

# ── MedicalRequest ───────────────────────────────────────────────
cat > $BASE/entity/MedicalRequest.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "medical_request")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MedicalRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "request_id", updatable = false, nullable = false)
    private UUID requestId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "consultation_id", nullable = false)
    private Consultation consultation;

    @Column(name = "request_type")
    private String requestType;

    @Column(columnDefinition = "TEXT")
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sent_to_provider_id")
    private Provider sentToProvider;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
EOF

# ── Notification ─────────────────────────────────────────────────
cat > $BASE/entity/Notification.java << 'EOF'
package com.Pocket_Health.Pocket_Health.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "notification")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "notification_id", updatable = false, nullable = false)
    private UUID notificationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String body;

    @Column(name = "notif_type")
    private String notifType;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
EOF

# ================================================================
# REPOSITORIES
# ================================================================

cat > $BASE/repository/UserRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
EOF

cat > $BASE/repository/ProfileRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {
    List<Profile> findByUser_UserId(UUID userId);
    List<Profile> findByUser_UserIdAndIsPrimaryTrue(UUID userId);
}
EOF

cat > $BASE/repository/HealthInfoRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.HealthInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface HealthInfoRepository extends JpaRepository<HealthInfo, UUID> {
    Optional<HealthInfo> findByProfile_ProfileId(UUID profileId);
}
EOF

cat > $BASE/repository/ProviderRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Provider;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProviderRepository extends JpaRepository<Provider, UUID> {
    List<Provider> findByRegion(String region);
    List<Provider> findByIsAvailableTrue();
    List<Provider> findByCategoryAndRegion(String category, String region);
    Optional<Provider> findByUser_UserId(UUID userId);
}
EOF

cat > $BASE/repository/EmergencyContactRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.EmergencyContact;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface EmergencyContactRepository extends JpaRepository<EmergencyContact, UUID> {
    List<EmergencyContact> findByProfile_ProfileIdOrderByPriorityAsc(UUID profileId);
}
EOF

cat > $BASE/repository/InsuranceRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Insurance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface InsuranceRepository extends JpaRepository<Insurance, UUID> {
    List<Insurance> findByProfile_ProfileId(UUID profileId);
}
EOF

cat > $BASE/repository/WalletRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Wallet;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface WalletRepository extends JpaRepository<Wallet, UUID> {
    Optional<Wallet> findByUser_UserId(UUID userId);
}
EOF

cat > $BASE/repository/TransactionRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface TransactionRepository extends JpaRepository<Transaction, UUID> {
    List<Transaction> findByWallet_WalletIdOrderByCreatedAtDesc(UUID walletId);
}
EOF

cat > $BASE/repository/ConsultationRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Consultation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ConsultationRepository extends JpaRepository<Consultation, UUID> {
    List<Consultation> findByPatientProfile_ProfileId(UUID profileId);
    List<Consultation> findByProvider_ProviderId(UUID providerId);
    List<Consultation> findByStatus(String status);
}
EOF

cat > $BASE/repository/AppointmentRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface AppointmentRepository extends JpaRepository<Appointment, UUID> {
    List<Appointment> findByPatientProfile_ProfileId(UUID profileId);
    List<Appointment> findByProvider_ProviderId(UUID providerId);
    List<Appointment> findByStatus(String status);
}
EOF

cat > $BASE/repository/ReviewRepository.java << 'EOF'
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
EOF

cat > $BASE/repository/DocumentRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface DocumentRepository extends JpaRepository<Document, UUID> {
    List<Document> findByOwnerProfile_ProfileId(UUID profileId);
    List<Document> findByOwnerProfile_ProfileIdAndDocType(UUID profileId, String docType);
}
EOF

cat > $BASE/repository/MedicalRequestRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.MedicalRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface MedicalRequestRepository extends JpaRepository<MedicalRequest, UUID> {
    List<MedicalRequest> findByConsultation_ConsultationId(UUID consultationId);
    List<MedicalRequest> findByRequestType(String requestType);
}
EOF

cat > $BASE/repository/NotificationRepository.java << 'EOF'
package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByUser_UserIdOrderByCreatedAtDesc(UUID userId);
    List<Notification> findByUser_UserIdAndIsReadFalse(UUID userId);
    long countByUser_UserIdAndIsReadFalse(UUID userId);
}
EOF

# ================================================================
# SECURITY — JWT
# ================================================================

cat > $BASE/security/JwtService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;

@Service
public class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.expiration}")
    private long expiration;

    private SecretKey getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    public String generateToken(String userId, String email, String role) {
        return Jwts.builder()
                .subject(userId)
                .claim("email", email)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getKey())
                .compact();
    }

    public Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public String extractUserId(String token) {
        return extractClaims(token).getSubject();
    }

    public boolean isTokenValid(String token) {
        try {
            extractClaims(token);
            return true;
        } catch (JwtException e) {
            return false;
        }
    }
}
EOF

cat > $BASE/security/JwtAuthFilter.java << 'EOF'
package com.Pocket_Health.Pocket_Health.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain)
            throws ServletException, IOException {

        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            chain.doFilter(request, response);
            return;
        }

        String token = header.substring(7);
        if (jwtService.isTokenValid(token)) {
            var claims = jwtService.extractClaims(token);
            String userId = claims.getSubject();
            String role   = claims.get("role", String.class);

            var auth = new UsernamePasswordAuthenticationToken(
                    userId, null,
                    List.of(new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
            );
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        chain.doFilter(request, response);
    }
}
EOF

# ================================================================
# SECURITY CONFIG
# ================================================================

cat > $BASE/config/SecurityConfig.java << 'EOF'
package com.Pocket_Health.Pocket_Health.config;

import com.Pocket_Health.Pocket_Health.security.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        var config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("http://localhost:5173"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
EOF

# ================================================================
# DTOs
# ================================================================

cat > $BASE/dto/request/RegisterRequest.java << 'EOF'
package com.Pocket_Health.Pocket_Health.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @Email @NotBlank
    private String email;

    @NotBlank @Size(min = 4)
    private String pin;

    @NotBlank
    private String userCategory;
}
EOF

cat > $BASE/dto/request/LoginRequest.java << 'EOF'
package com.Pocket_Health.Pocket_Health.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
    @Email @NotBlank
    private String email;

    @NotBlank
    private String pin;
}
EOF

cat > $BASE/dto/response/AuthResponse.java << 'EOF'
package com.Pocket_Health.Pocket_Health.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import java.util.UUID;

@Data @Builder @AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private UUID userId;
    private String email;
    private String userCategory;
    private String status;
}
EOF

cat > $BASE/dto/response/ApiResponse.java << 'EOF'
package com.Pocket_Health.Pocket_Health.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data @Builder @AllArgsConstructor
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;

    public static <T> ApiResponse<T> ok(String message, T data) {
        return new ApiResponse<>(true, message, data);
    }

    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, message, null);
    }
}
EOF

# ================================================================
# AUTH SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/AuthService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.dto.request.LoginRequest;
import com.Pocket_Health.Pocket_Health.dto.request.RegisterRequest;
import com.Pocket_Health.Pocket_Health.dto.response.AuthResponse;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import com.Pocket_Health.Pocket_Health.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new RuntimeException("Email already registered");
        }
        User user = User.builder()
                .email(req.getEmail())
                .pinHash(passwordEncoder.encode(req.getPin()))
                .userCategory(req.getUserCategory())
                .status("active")
                .build();
        userRepository.save(user);
        return buildResponse(user);
    }

    public AuthResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(req.getPin(), user.getPinHash())) {
            throw new RuntimeException("Invalid credentials");
        }
        return buildResponse(user);
    }

    private AuthResponse buildResponse(User user) {
        String token = jwtService.generateToken(
                user.getUserId().toString(),
                user.getEmail(),
                user.getUserCategory()
        );
        return AuthResponse.builder()
                .accessToken(token)
                .userId(user.getUserId())
                .email(user.getEmail())
                .userCategory(user.getUserCategory())
                .status(user.getStatus())
                .build();
    }
}
EOF

cat > $BASE/controller/AuthController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.request.LoginRequest;
import com.Pocket_Health.Pocket_Health.dto.request.RegisterRequest;
import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.dto.response.AuthResponse;
import com.Pocket_Health.Pocket_Health.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest req) {
        AuthResponse response = authService.register(req);
        return ResponseEntity.ok(ApiResponse.ok("User registered successfully", response));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest req) {
        AuthResponse response = authService.login(req);
        return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
    }
}
EOF

# ================================================================
# GLOBAL EXCEPTION HANDLER
# ================================================================

cat > $BASE/config/GlobalExceptionHandler.java << 'EOF'
package com.Pocket_Health.Pocket_Health.config;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiResponse<Void>> handleRuntime(RuntimeException ex) {
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException ex) {
        String errors = ex.getBindingResult().getFieldErrors()
                .stream()
                .map(e -> e.getField() + ": " + e.getDefaultMessage())
                .collect(Collectors.joining(", "));
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(errors));
    }
}
EOF

echo ""
echo "✅ PocketHealth Spring Boot setup complete!"
echo ""
echo "Files created:"
echo "  14 Entities"
echo "  14 Repositories"
echo "  JWT Security (JwtService + JwtAuthFilter)"
echo "  SecurityConfig (BCrypt + CORS)"
echo "  DTOs (RegisterRequest, LoginRequest, AuthResponse, ApiResponse)"
echo "  AuthService + AuthController"
echo "  GlobalExceptionHandler"
echo ""
echo "Next: Open IntelliJ, run the app, test /auth/register and /auth/login"
