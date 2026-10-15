package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.EmergencyContact;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.EmergencyContactRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EmergencyContactService {

    private final EmergencyContactRepository emergencyContactRepository;
    private final ProfileRepository profileRepository;
    private final ProfileAccessGuard profileAccessGuard;

    private static final int MAX_CONTACTS_PER_PROFILE = 3;

    public EmergencyContact create(Map<String, Object> body) {
        Profile profile = profileAccessGuard.requireOwnedProfile(UUID.fromString((String) body.get("profileId")));

        if (emergencyContactRepository.findByProfile_ProfileIdOrderByPriorityAsc(profile.getProfileId()).size()
                >= MAX_CONTACTS_PER_PROFILE) {
            throw new RuntimeException("You can only have up to " + MAX_CONTACTS_PER_PROFILE + " emergency contacts");
        }

        EmergencyContact contact = EmergencyContact.builder()
                .profile(profile)
                .name((String) body.get("name"))
                .phone1((String) body.get("phone1"))
                .phone2((String) body.get("phone2"))
                .email((String) body.get("email"))
                .priority(body.get("priority") != null ? Short.valueOf(body.get("priority").toString()) : (short) 1)
                .emergencyType((String) body.get("emergencyType"))
                .build();
        return emergencyContactRepository.save(contact);
    }

    public List<EmergencyContact> getByProfile(UUID profileId) {
        profileAccessGuard.requireOwnedProfile(profileId);
        return emergencyContactRepository.findByProfile_ProfileIdOrderByPriorityAsc(profileId);
    }

    public EmergencyContact getById(UUID id) {
        return emergencyContactRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Emergency contact not found"));
    }

    public EmergencyContact update(UUID id, Map<String, Object> body) {
        EmergencyContact c = getById(id);
        if (body.containsKey("name"))          c.setName((String) body.get("name"));
        if (body.containsKey("phone1"))        c.setPhone1((String) body.get("phone1"));
        if (body.containsKey("phone2"))        c.setPhone2((String) body.get("phone2"));
        if (body.containsKey("email"))         c.setEmail((String) body.get("email"));
        if (body.containsKey("priority"))      c.setPriority(Short.valueOf(body.get("priority").toString()));
        if (body.containsKey("emergencyType")) c.setEmergencyType((String) body.get("emergencyType"));
        return emergencyContactRepository.save(c);
    }

    public void delete(UUID id) { emergencyContactRepository.deleteById(id); }
}
