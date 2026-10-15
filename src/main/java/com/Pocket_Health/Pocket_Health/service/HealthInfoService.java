package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.HealthInfo;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.HealthInfoRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class HealthInfoService {

    private final HealthInfoRepository healthInfoRepository;
    private final ProfileRepository profileRepository;
    private final ProfileAccessGuard profileAccessGuard;

    public HealthInfo create(Map<String, Object> body) {
        UUID profileId = UUID.fromString((String) body.get("profileId"));
        Profile profile = profileAccessGuard.requireOwnedProfile(profileId);

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
        profileAccessGuard.requireOwnedProfile(profileId);
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
