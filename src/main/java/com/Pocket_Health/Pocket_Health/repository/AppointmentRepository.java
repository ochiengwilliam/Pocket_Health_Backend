package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface AppointmentRepository extends JpaRepository<Appointment, UUID> {
    List<Appointment> findByPatientProfile_ProfileId(UUID profileId);
    List<Appointment> findByProvider_ProviderId(UUID providerId);
    List<Appointment> findByStatus(String status);
}
