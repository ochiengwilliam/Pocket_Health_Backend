#!/bin/bash
# ================================================================
#  PocketHealth — Controllers & Services Setup
#  Run from project root:
#  chmod +x controllers_setup.sh && ./controllers_setup.sh
# ================================================================

BASE="src/main/java/com/Pocket_Health/Pocket_Health"

# ================================================================
# PROFILE SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/ProfileService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;

    public Profile create(Map<String, Object> body) {
        UUID userId = UUID.fromString((String) body.get("userId"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Profile profile = Profile.builder()
                .user(user)
                .surname((String) body.get("surname"))
                .otherNames((String) body.get("otherNames"))
                .dateOfBirth(body.get("dateOfBirth") != null ? LocalDate.parse((String) body.get("dateOfBirth")) : null)
                .gender((String) body.get("gender"))
                .phone1((String) body.get("phone1"))
                .residence((String) body.get("residence"))
                .region((String) body.get("region"))
                .relation((String) body.get("relation"))
                .isPrimary(body.get("isPrimary") != null && (Boolean) body.get("isPrimary"))
                .build();
        return profileRepository.save(profile);
    }

    public List<Profile> getAll() { return profileRepository.findAll(); }

    public Profile getById(UUID id) {
        return profileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
    }

    public List<Profile> getByUserId(UUID userId) {
        return profileRepository.findByUser_UserId(userId);
    }

    public Profile update(UUID id, Map<String, Object> body) {
        Profile profile = getById(id);
        if (body.containsKey("surname"))    profile.setSurname((String) body.get("surname"));
        if (body.containsKey("otherNames")) profile.setOtherNames((String) body.get("otherNames"));
        if (body.containsKey("phone1"))     profile.setPhone1((String) body.get("phone1"));
        if (body.containsKey("residence"))  profile.setResidence((String) body.get("residence"));
        if (body.containsKey("region"))     profile.setRegion((String) body.get("region"));
        if (body.containsKey("gender"))     profile.setGender((String) body.get("gender"));
        return profileRepository.save(profile);
    }

    public void delete(UUID id) { profileRepository.deleteById(id); }
}
EOF

cat > $BASE/controller/ProfileController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/profiles")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @PostMapping
    public ResponseEntity<ApiResponse<Profile>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Profile created", profileService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Profile>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Profiles fetched", profileService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Profile>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Profile fetched", profileService.getById(id)));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<Profile>>> getByUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Profiles fetched", profileService.getByUserId(userId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Profile>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Profile updated", profileService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        profileService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Profile deleted", null));
    }
}
EOF

# ================================================================
# HEALTH INFO SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/HealthInfoService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.HealthInfo;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.HealthInfoRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class HealthInfoService {

    private final HealthInfoRepository healthInfoRepository;
    private final ProfileRepository profileRepository;

    public HealthInfo create(Map<String, Object> body) {
        UUID profileId = UUID.fromString((String) body.get("profileId"));
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        HealthInfo info = HealthInfo.builder()
                .profile(profile)
                .identifier((String) body.get("identifier"))
                .bloodGroup((String) body.get("bloodGroup"))
                .allergies((String) body.get("allergies"))
                .chronicConditions((String) body.get("chronicConditions"))
                .mentalConditions((String) body.get("mentalConditions"))
                .longTermMeds((String) body.get("longTermMeds"))
                .familyHistory((String) body.get("familyHistory"))
                .drugUse((String) body.get("drugUse"))
                .build();
        return healthInfoRepository.save(info);
    }

    public HealthInfo getByProfileId(UUID profileId) {
        return healthInfoRepository.findByProfile_ProfileId(profileId)
                .orElseThrow(() -> new RuntimeException("Health info not found"));
    }

    public HealthInfo update(UUID id, Map<String, Object> body) {
        HealthInfo info = healthInfoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Health info not found"));
        if (body.containsKey("bloodGroup"))        info.setBloodGroup((String) body.get("bloodGroup"));
        if (body.containsKey("allergies"))         info.setAllergies((String) body.get("allergies"));
        if (body.containsKey("chronicConditions")) info.setChronicConditions((String) body.get("chronicConditions"));
        if (body.containsKey("mentalConditions"))  info.setMentalConditions((String) body.get("mentalConditions"));
        if (body.containsKey("longTermMeds"))      info.setLongTermMeds((String) body.get("longTermMeds"));
        if (body.containsKey("familyHistory"))     info.setFamilyHistory((String) body.get("familyHistory"));
        if (body.containsKey("drugUse"))           info.setDrugUse((String) body.get("drugUse"));
        return healthInfoRepository.save(info);
    }
}
EOF

cat > $BASE/controller/HealthInfoController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.HealthInfo;
import com.Pocket_Health.Pocket_Health.service.HealthInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/health-info")
@RequiredArgsConstructor
public class HealthInfoController {

    private final HealthInfoService healthInfoService;

    @PostMapping
    public ResponseEntity<ApiResponse<HealthInfo>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Health info created", healthInfoService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<HealthInfo>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Health info fetched", healthInfoService.getByProfileId(profileId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<HealthInfo>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Health info updated", healthInfoService.update(id, body)));
    }
}
EOF

# ================================================================
# PROVIDER SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/ProviderService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProviderService {

    private final ProviderRepository providerRepository;
    private final UserRepository userRepository;

    public Provider create(Map<String, Object> body) {
        UUID userId = UUID.fromString((String) body.get("userId"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Provider provider = Provider.builder()
                .user(user)
                .providerName((String) body.get("providerName"))
                .category((String) body.get("category"))
                .specialty((String) body.get("specialty"))
                .location((String) body.get("location"))
                .region((String) body.get("region"))
                .isVerified(body.get("isVerified") != null && (Boolean) body.get("isVerified"))
                .isAvailable(body.get("isAvailable") == null || (Boolean) body.get("isAvailable"))
                .rates(body.get("rates") != null ? new BigDecimal(body.get("rates").toString()) : null)
                .build();
        return providerRepository.save(provider);
    }

    public List<Provider> getAll() { return providerRepository.findAll(); }

    public List<Provider> getAvailable() { return providerRepository.findByIsAvailableTrue(); }

    public List<Provider> getByRegion(String region) { return providerRepository.findByRegion(region); }

    public Provider getById(UUID id) {
        return providerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Provider not found"));
    }

    public Provider update(UUID id, Map<String, Object> body) {
        Provider provider = getById(id);
        if (body.containsKey("providerName")) provider.setProviderName((String) body.get("providerName"));
        if (body.containsKey("specialty"))    provider.setSpecialty((String) body.get("specialty"));
        if (body.containsKey("location"))     provider.setLocation((String) body.get("location"));
        if (body.containsKey("isAvailable"))  provider.setIsAvailable((Boolean) body.get("isAvailable"));
        if (body.containsKey("isVerified"))   provider.setIsVerified((Boolean) body.get("isVerified"));
        if (body.containsKey("rates"))        provider.setRates(new BigDecimal(body.get("rates").toString()));
        return providerRepository.save(provider);
    }
}
EOF

cat > $BASE/controller/ProviderController.java << 'EOF'
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

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Provider>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Provider fetched", providerService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Provider>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Provider updated", providerService.update(id, body)));
    }
}
EOF

# ================================================================
# WALLET SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/WalletService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.entity.Wallet;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import com.Pocket_Health.Pocket_Health.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class WalletService {

    private final WalletRepository walletRepository;
    private final UserRepository userRepository;

    public Wallet create(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (walletRepository.findByUser_UserId(userId).isPresent()) {
            throw new RuntimeException("Wallet already exists for this user");
        }
        return walletRepository.save(Wallet.builder().user(user).balanceKes(BigDecimal.ZERO).build());
    }

    public Wallet getByUserId(UUID userId) {
        return walletRepository.findByUser_UserId(userId)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
    }

    public Wallet topUp(UUID walletId, BigDecimal amount) {
        Wallet wallet = walletRepository.findById(walletId)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
        wallet.setBalanceKes(wallet.getBalanceKes().add(amount));
        return walletRepository.save(wallet);
    }

    public Wallet debit(UUID walletId, BigDecimal amount) {
        Wallet wallet = walletRepository.findById(walletId)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
        if (wallet.getBalanceKes().compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient wallet balance");
        }
        wallet.setBalanceKes(wallet.getBalanceKes().subtract(amount));
        return walletRepository.save(wallet);
    }
}
EOF

cat > $BASE/controller/WalletController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Wallet;
import com.Pocket_Health.Pocket_Health.service.WalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/wallets")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @PostMapping
    public ResponseEntity<ApiResponse<Wallet>> create(@RequestBody Map<String, Object> body) {
        UUID userId = UUID.fromString((String) body.get("userId"));
        return ResponseEntity.ok(ApiResponse.ok("Wallet created", walletService.create(userId)));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Wallet>> getByUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Wallet fetched", walletService.getByUserId(userId)));
    }

    @PatchMapping("/{walletId}/topup")
    public ResponseEntity<ApiResponse<Wallet>> topUp(@PathVariable UUID walletId, @RequestBody Map<String, Object> body) {
        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        return ResponseEntity.ok(ApiResponse.ok("Wallet topped up", walletService.topUp(walletId, amount)));
    }

    @PatchMapping("/{walletId}/debit")
    public ResponseEntity<ApiResponse<Wallet>> debit(@PathVariable UUID walletId, @RequestBody Map<String, Object> body) {
        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        return ResponseEntity.ok(ApiResponse.ok("Wallet debited", walletService.debit(walletId, amount)));
    }
}
EOF

# ================================================================
# CONSULTATION SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/ConsultationService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Consultation;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.repository.ConsultationRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ConsultationService {

    private final ConsultationRepository consultationRepository;
    private final ProfileRepository profileRepository;
    private final ProviderRepository providerRepository;

    public Consultation create(Map<String, Object> body) {
        Profile profile = profileRepository.findById(UUID.fromString((String) body.get("patientProfileId")))
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        Provider provider = providerRepository.findById(UUID.fromString((String) body.get("providerId")))
                .orElseThrow(() -> new RuntimeException("Provider not found"));

        Consultation consultation = Consultation.builder()
                .patientProfile(profile)
                .provider(provider)
                .callType((String) body.get("callType"))
                .startedAt(body.get("startedAt") != null ? OffsetDateTime.parse((String) body.get("startedAt")) : null)
                .endedAt(body.get("endedAt") != null ? OffsetDateTime.parse((String) body.get("endedAt")) : null)
                .amountCharged(body.get("amountCharged") != null ? new BigDecimal(body.get("amountCharged").toString()) : null)
                .status(body.get("status") != null ? (String) body.get("status") : "scheduled")
                .build();
        return consultationRepository.save(consultation);
    }

    public List<Consultation> getAll() { return consultationRepository.findAll(); }

    public Consultation getById(UUID id) {
        return consultationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Consultation not found"));
    }

    public List<Consultation> getByProfile(UUID profileId) {
        return consultationRepository.findByPatientProfile_ProfileId(profileId);
    }

    public List<Consultation> getByProvider(UUID providerId) {
        return consultationRepository.findByProvider_ProviderId(providerId);
    }

    public Consultation update(UUID id, Map<String, Object> body) {
        Consultation c = getById(id);
        if (body.containsKey("status"))    c.setStatus((String) body.get("status"));
        if (body.containsKey("endedAt"))   c.setEndedAt(OffsetDateTime.parse((String) body.get("endedAt")));
        if (body.containsKey("amountCharged")) c.setAmountCharged(new BigDecimal(body.get("amountCharged").toString()));
        return consultationRepository.save(c);
    }
}
EOF

cat > $BASE/controller/ConsultationController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Consultation;
import com.Pocket_Health.Pocket_Health.service.ConsultationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/consultations")
@RequiredArgsConstructor
public class ConsultationController {

    private final ConsultationService consultationService;

    @PostMapping
    public ResponseEntity<ApiResponse<Consultation>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Consultation created", consultationService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Consultation>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Consultations fetched", consultationService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Consultation>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Consultation fetched", consultationService.getById(id)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<Consultation>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Consultations fetched", consultationService.getByProfile(profileId)));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<ApiResponse<List<Consultation>>> getByProvider(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Consultations fetched", consultationService.getByProvider(providerId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Consultation>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Consultation updated", consultationService.update(id, body)));
    }
}
EOF

# ================================================================
# APPOINTMENT SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/AppointmentService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Appointment;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.repository.AppointmentRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final ProfileRepository profileRepository;
    private final ProviderRepository providerRepository;

    public Appointment create(Map<String, Object> body) {
        Profile profile = profileRepository.findById(UUID.fromString((String) body.get("patientProfileId")))
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        Provider provider = providerRepository.findById(UUID.fromString((String) body.get("providerId")))
                .orElseThrow(() -> new RuntimeException("Provider not found"));

        Appointment appointment = Appointment.builder()
                .patientProfile(profile)
                .provider(provider)
                .scheduledAt(OffsetDateTime.parse((String) body.get("scheduledAt")))
                .durationSlot(body.get("durationSlot") != null ? Integer.valueOf(body.get("durationSlot").toString()) : 30)
                .status("pending")
                .attended(false)
                .build();
        return appointmentRepository.save(appointment);
    }

    public List<Appointment> getAll() { return appointmentRepository.findAll(); }

    public Appointment getById(UUID id) {
        return appointmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));
    }

    public List<Appointment> getByProfile(UUID profileId) {
        return appointmentRepository.findByPatientProfile_ProfileId(profileId);
    }

    public List<Appointment> getByProvider(UUID providerId) {
        return appointmentRepository.findByProvider_ProviderId(providerId);
    }

    public Appointment update(UUID id, Map<String, Object> body) {
        Appointment a = getById(id);
        if (body.containsKey("status"))   a.setStatus((String) body.get("status"));
        if (body.containsKey("attended")) a.setAttended((Boolean) body.get("attended"));
        return appointmentRepository.save(a);
    }

    public void cancel(UUID id) {
        Appointment a = getById(id);
        a.setStatus("cancelled");
        appointmentRepository.save(a);
    }
}
EOF

cat > $BASE/controller/AppointmentController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Appointment;
import com.Pocket_Health.Pocket_Health.service.AppointmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/appointments")
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentService appointmentService;

    @PostMapping
    public ResponseEntity<ApiResponse<Appointment>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Appointment booked", appointmentService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Appointment>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Appointments fetched", appointmentService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Appointment>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Appointment fetched", appointmentService.getById(id)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<Appointment>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Appointments fetched", appointmentService.getByProfile(profileId)));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<ApiResponse<List<Appointment>>> getByProvider(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Appointments fetched", appointmentService.getByProvider(providerId)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Appointment>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Appointment updated", appointmentService.update(id, body)));
    }

    @DeleteMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancel(@PathVariable UUID id) {
        appointmentService.cancel(id);
        return ResponseEntity.ok(ApiResponse.ok("Appointment cancelled", null));
    }
}
EOF

# ================================================================
# NOTIFICATION SERVICE + CONTROLLER
# ================================================================

cat > $BASE/service/NotificationService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Notification;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.NotificationRepository;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public Notification create(Map<String, Object> body) {
        User user = userRepository.findById(UUID.fromString((String) body.get("userId")))
                .orElseThrow(() -> new RuntimeException("User not found"));

        Notification n = Notification.builder()
                .user(user)
                .title((String) body.get("title"))
                .body((String) body.get("body"))
                .notifType((String) body.get("notifType"))
                .isRead(false)
                .build();
        return notificationRepository.save(n);
    }

    public List<Notification> getByUser(UUID userId) {
        return notificationRepository.findByUser_UserIdOrderByCreatedAtDesc(userId);
    }

    public List<Notification> getUnread(UUID userId) {
        return notificationRepository.findByUser_UserIdAndIsReadFalse(userId);
    }

    public long countUnread(UUID userId) {
        return notificationRepository.countByUser_UserIdAndIsReadFalse(userId);
    }

    public Notification markRead(UUID id) {
        Notification n = notificationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        n.setIsRead(true);
        return notificationRepository.save(n);
    }

    public void markAllRead(UUID userId) {
        List<Notification> unread = notificationRepository.findByUser_UserIdAndIsReadFalse(userId);
        unread.forEach(n -> n.setIsRead(true));
        notificationRepository.saveAll(unread);
    }
}
EOF

cat > $BASE/controller/NotificationController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Notification;
import com.Pocket_Health.Pocket_Health.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping
    public ResponseEntity<ApiResponse<Notification>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Notification created", notificationService.create(body)));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<Notification>>> getByUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Notifications fetched", notificationService.getByUser(userId)));
    }

    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<ApiResponse<List<Notification>>> getUnread(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Unread notifications", notificationService.getUnread(userId)));
    }

    @GetMapping("/user/{userId}/unread/count")
    public ResponseEntity<ApiResponse<Long>> countUnread(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Unread count", notificationService.countUnread(userId)));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Notification>> markRead(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Notification marked read", notificationService.markRead(id)));
    }

    @PatchMapping("/user/{userId}/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllRead(@PathVariable UUID userId) {
        notificationService.markAllRead(userId);
        return ResponseEntity.ok(ApiResponse.ok("All notifications marked read", null));
    }
}
EOF

echo ""
echo "✅ All controllers and services created!"
echo ""
echo "Endpoints available:"
echo "  POST   /api/v1/auth/register"
echo "  POST   /api/v1/auth/login"
echo "  GET    /api/v1/profiles"
echo "  POST   /api/v1/profiles"
echo "  GET    /api/v1/profiles/{id}"
echo "  GET    /api/v1/profiles/user/{userId}"
echo "  POST   /api/v1/health-info"
echo "  GET    /api/v1/health-info/profile/{profileId}"
echo "  GET    /api/v1/providers"
echo "  POST   /api/v1/providers"
echo "  GET    /api/v1/wallets/user/{userId}"
echo "  POST   /api/v1/wallets"
echo "  PATCH  /api/v1/wallets/{id}/topup"
echo "  GET    /api/v1/consultations"
echo "  POST   /api/v1/consultations"
echo "  GET    /api/v1/appointments"
echo "  POST   /api/v1/appointments"
echo "  GET    /api/v1/notifications/user/{userId}"
echo "  PATCH  /api/v1/notifications/{id}/read"
