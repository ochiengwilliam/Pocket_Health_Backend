package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
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
    private final ProfileAccessGuard profileAccessGuard;

    public Profile create(Map<String, Object> body) {
        UUID userId = UUID.fromString((String) body.get("userId"));
        profileAccessGuard.requireOwnedUser(userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Profile profile = Profile.builder()
                .user(user)
                .surname((String) body.get("surname"))
                .otherNames((String) body.get("otherNames"))
                .dateOfBirth(parseDate(body.get("dateOfBirth")))
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
        return profileAccessGuard.requireOwnedProfile(id);
    }

    public List<Profile> getByUserId(UUID userId) {
        profileAccessGuard.requireOwnedUser(userId);
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
        if (body.containsKey("dateOfBirth")) profile.setDateOfBirth(parseDate(body.get("dateOfBirth")));
        if (body.containsKey("relation"))   profile.setRelation((String) body.get("relation"));
        return profileRepository.save(profile);
    }

    public void delete(UUID id) {
        profileAccessGuard.requireOwnedProfile(id);
        profileRepository.deleteById(id);
    }

    private LocalDate parseDate(Object value) {
        if (value == null) return null;
        String raw = value.toString().trim();
        if (raw.isEmpty()) return null;
        // Accept "yyyy-MM-dd" as well as a full ISO timestamp ("yyyy-MM-ddTHH:mm:ss...").
        return LocalDate.parse(raw.length() > 10 ? raw.substring(0, 10) : raw);
    }
}
