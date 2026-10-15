package com.Pocket_Health.Pocket_Health.security;

import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.exception.ProfileAccessDeniedException;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class ProfileAccessGuard {

    private final ProfileRepository profileRepository;

    public UUID currentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new ProfileAccessDeniedException("Not authenticated");
        }
        return UUID.fromString(auth.getName());
    }

    public Profile requireOwnedProfile(UUID profileId) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        if (!profile.getUser().getUserId().equals(currentUserId())) {
            throw new ProfileAccessDeniedException("Profile does not belong to the authenticated account");
        }
        return profile;
    }

    public void requireOwnedUser(UUID userId) {
        if (!userId.equals(currentUserId())) {
            throw new ProfileAccessDeniedException("Account does not belong to the authenticated user");
        }
    }
}
