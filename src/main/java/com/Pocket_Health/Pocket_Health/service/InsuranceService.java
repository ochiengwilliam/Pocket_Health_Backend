package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Insurance;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.InsuranceRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class InsuranceService {

    private final InsuranceRepository insuranceRepository;
    private final ProfileRepository profileRepository;
    private final ProfileAccessGuard profileAccessGuard;

    public Insurance create(Map<String, Object> body) {
        Profile profile = profileAccessGuard.requireOwnedProfile(UUID.fromString((String) body.get("profileId")));
        Insurance insurance = Insurance.builder()
                .profile(profile)
                .insurerName((String) body.get("insurerName"))
                .policyNumber((String) body.get("policyNumber"))
                .phone1((String) body.get("phone1"))
                .phone2((String) body.get("phone2"))
                .email((String) body.get("email"))
                .build();
        return insuranceRepository.save(insurance);
    }

    public List<Insurance> getByProfile(UUID profileId) {
        profileAccessGuard.requireOwnedProfile(profileId);
        return insuranceRepository.findByProfile_ProfileId(profileId);
    }

    public Insurance getById(UUID id) {
        return insuranceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Insurance not found"));
    }

    public Insurance update(UUID id, Map<String, Object> body) {
        Insurance i = getById(id);
        if (body.containsKey("insurerName"))  i.setInsurerName((String) body.get("insurerName"));
        if (body.containsKey("policyNumber")) i.setPolicyNumber((String) body.get("policyNumber"));
        if (body.containsKey("phone1"))       i.setPhone1((String) body.get("phone1"));
        if (body.containsKey("phone2"))       i.setPhone2((String) body.get("phone2"));
        if (body.containsKey("email"))        i.setEmail((String) body.get("email"));
        return insuranceRepository.save(i);
    }

    public void delete(UUID id) { insuranceRepository.deleteById(id); }
}
