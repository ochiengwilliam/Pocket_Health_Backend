package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.NextOfKin;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.NextOfKinRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NextOfKinService {

    private final NextOfKinRepository nextOfKinRepository;
    private final ProfileRepository profileRepository;
    private final ProfileAccessGuard profileAccessGuard;

    public NextOfKin create(Map<String, Object> body) {

        UUID profileId = UUID.fromString((String) body.get("profileId"));

        Profile profile = profileAccessGuard.requireOwnedProfile(profileId);

        NextOfKin kin = NextOfKin.builder()
                .profile(profile)
                .fullName((String) body.get("fullName"))
                .relationship((String) body.get("relationship"))
                .phone1((String) body.get("phone1"))
                .phone2((String) body.get("phone2"))
                .email((String) body.get("email"))
                .address((String) body.get("address"))
                .build();

        return nextOfKinRepository.save(kin);
    }

    public List<NextOfKin> getByProfile(UUID profileId) {
        profileAccessGuard.requireOwnedProfile(profileId);
        return nextOfKinRepository.findByProfile_ProfileId(profileId);
    }

    public NextOfKin update(UUID id, Map<String,Object> body){

        NextOfKin kin = nextOfKinRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Next of kin not found"));

        if(body.containsKey("fullName"))
            kin.setFullName((String) body.get("fullName"));

        if(body.containsKey("relationship"))
            kin.setRelationship((String) body.get("relationship"));

        if(body.containsKey("phone1"))
            kin.setPhone1((String) body.get("phone1"));

        if(body.containsKey("phone2"))
            kin.setPhone2((String) body.get("phone2"));

        if(body.containsKey("email"))
            kin.setEmail((String) body.get("email"));

        if(body.containsKey("address"))
            kin.setAddress((String) body.get("address"));

        return nextOfKinRepository.save(kin);
    }

    public void delete(UUID id){
        nextOfKinRepository.deleteById(id);
    }
}