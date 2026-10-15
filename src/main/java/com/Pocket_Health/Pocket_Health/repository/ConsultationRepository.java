package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Consultation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ConsultationRepository extends JpaRepository<Consultation, UUID> {
    List<Consultation> findByPatientProfile_ProfileId(UUID profileId);
    List<Consultation> findByProvider_ProviderId(UUID providerId);
    List<Consultation> findByStatus(String status);
}
