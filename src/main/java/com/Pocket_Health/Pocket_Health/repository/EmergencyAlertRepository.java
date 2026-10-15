package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.EmergencyAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface EmergencyAlertRepository extends JpaRepository<EmergencyAlert, UUID> {
    List<EmergencyAlert> findByProfile_ProfileIdOrderByCreatedAtDesc(UUID profileId);
}
