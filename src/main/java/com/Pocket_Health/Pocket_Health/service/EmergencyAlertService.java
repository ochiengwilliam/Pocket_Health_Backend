package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Document;
import com.Pocket_Health.Pocket_Health.entity.EmergencyAlert;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.DocumentRepository;
import com.Pocket_Health.Pocket_Health.repository.EmergencyAlertRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EmergencyAlertService {

    private static final Set<String> ALERT_TYPES = Set.of("health", "life_in_danger");

    private final EmergencyAlertRepository emergencyAlertRepository;
    private final DocumentRepository documentRepository;
    private final ProfileAccessGuard profileAccessGuard;

    public EmergencyAlert create(Map<String, Object> body) {
        Profile profile = profileAccessGuard.requireOwnedProfile(UUID.fromString((String) body.get("profileId")));

        String alertType = (String) body.get("alertType");
        if (alertType == null || !ALERT_TYPES.contains(alertType.toLowerCase())) {
            throw new RuntimeException("alertType must be one of: " + String.join(", ", ALERT_TYPES));
        }

        Document recordingDocument = null;
        if (body.get("recordingDocumentId") != null) {
            recordingDocument = documentRepository.findById(UUID.fromString((String) body.get("recordingDocumentId")))
                    .orElseThrow(() -> new RuntimeException("Recording document not found"));
        }

        EmergencyAlert alert = EmergencyAlert.builder()
                .profile(profile)
                .alertType(alertType.toLowerCase())
                .status("active")
                .notes((String) body.get("notes"))
                .location((String) body.get("location"))
                .recordingDocument(recordingDocument)
                .build();
        return emergencyAlertRepository.save(alert);
    }

    public List<EmergencyAlert> getByProfile(UUID profileId) {
        profileAccessGuard.requireOwnedProfile(profileId);
        return emergencyAlertRepository.findByProfile_ProfileIdOrderByCreatedAtDesc(profileId);
    }

    public EmergencyAlert getById(UUID id) {
        return emergencyAlertRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Emergency alert not found"));
    }

    public EmergencyAlert update(UUID id, Map<String, Object> body) {
        EmergencyAlert alert = getById(id);
        profileAccessGuard.requireOwnedProfile(alert.getProfile().getProfileId());

        if (body.containsKey("notes")) alert.setNotes((String) body.get("notes"));
        if (body.containsKey("status")) {
            String status = (String) body.get("status");
            alert.setStatus(status);
            if ("resolved".equalsIgnoreCase(status) && alert.getResolvedAt() == null) {
                alert.setResolvedAt(OffsetDateTime.now());
            }
        }
        return emergencyAlertRepository.save(alert);
    }
}
