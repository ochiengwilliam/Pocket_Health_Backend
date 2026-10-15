package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.HealthInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface HealthInfoRepository extends JpaRepository<HealthInfo, UUID> {
    Optional<HealthInfo> findByProfile_ProfileId(UUID profileId);
}
