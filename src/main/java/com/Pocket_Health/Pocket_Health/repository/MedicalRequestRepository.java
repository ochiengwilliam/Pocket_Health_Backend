package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.MedicalRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface MedicalRequestRepository extends JpaRepository<MedicalRequest, UUID> {
    List<MedicalRequest> findByConsultation_ConsultationId(UUID consultationId);
    List<MedicalRequest> findByRequestType(String requestType);
}
