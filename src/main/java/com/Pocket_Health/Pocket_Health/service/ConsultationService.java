package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Consultation;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.repository.ConsultationRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
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
    private final ProfileAccessGuard profileAccessGuard;

    public Consultation create(Map<String, Object> body) {
        Profile profile = profileAccessGuard.requireOwnedProfile(UUID.fromString((String) body.get("patientProfileId")));
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
        profileAccessGuard.requireOwnedProfile(profileId);
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
