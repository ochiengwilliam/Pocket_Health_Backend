package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Appointment;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.repository.AppointmentRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
import com.Pocket_Health.Pocket_Health.service.ProviderAvailabilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final ProfileRepository profileRepository;
    private final ProviderRepository providerRepository;
    private final ProviderAvailabilityService providerAvailabilityService;
    private final ProfileAccessGuard profileAccessGuard;

    public Appointment create(Map<String, Object> body) {
        Profile profile = profileAccessGuard.requireOwnedProfile(UUID.fromString((String) body.get("patientProfileId")));
        Provider provider = providerRepository.findById(UUID.fromString((String) body.get("providerId")))
                .orElseThrow(() -> new RuntimeException("Provider not found"));

        OffsetDateTime scheduledAt = OffsetDateTime.parse((String) body.get("scheduledAt"));
        int durationSlot = body.get("durationSlot") != null ? Integer.valueOf(body.get("durationSlot").toString()) : 30;

        if (!providerAvailabilityService.isWithinAvailability(provider.getProviderId(), scheduledAt, durationSlot)) {
            throw new RuntimeException("Selected slot is outside the provider's availability");
        }
        if (hasConflict(provider.getProviderId(), scheduledAt, durationSlot, null)) {
            throw new RuntimeException("Selected slot is no longer available");
        }

        Appointment appointment = Appointment.builder()
                .patientProfile(profile)
                .provider(provider)
                .scheduledAt(scheduledAt)
                .durationSlot(durationSlot)
                .status("pending")
                .attended(false)
                .build();
        return appointmentRepository.save(appointment);
    }

    private boolean hasConflict(UUID providerId, OffsetDateTime scheduledAt, int durationSlot, UUID excludeAppointmentId) {
        OffsetDateTime newEnd = scheduledAt.plusMinutes(durationSlot);
        return appointmentRepository.findByProvider_ProviderId(providerId).stream()
                .filter(a -> !"cancelled".equalsIgnoreCase(a.getStatus()))
                .filter(a -> excludeAppointmentId == null || !a.getAppointmentId().equals(excludeAppointmentId))
                .anyMatch(a -> {
                    OffsetDateTime existingStart = a.getScheduledAt();
                    OffsetDateTime existingEnd = existingStart.plusMinutes(a.getDurationSlot() != null ? a.getDurationSlot() : 30);
                    return scheduledAt.isBefore(existingEnd) && existingStart.isBefore(newEnd);
                });
    }

    public List<Appointment> getAll() { return appointmentRepository.findAll(); }

    public Appointment getById(UUID id) {
        return appointmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));
    }

    public List<Appointment> getByProfile(UUID profileId) {
        profileAccessGuard.requireOwnedProfile(profileId);
        return appointmentRepository.findByPatientProfile_ProfileId(profileId);
    }

    public List<Appointment> getByProvider(UUID providerId) {
        return appointmentRepository.findByProvider_ProviderId(providerId);
    }

    public Appointment update(UUID id, Map<String, Object> body) {
        Appointment a = getById(id);
        if (body.containsKey("status"))   a.setStatus((String) body.get("status"));
        if (body.containsKey("attended")) a.setAttended((Boolean) body.get("attended"));
        return appointmentRepository.save(a);
    }

    public void cancel(UUID id) {
        Appointment a = getById(id);
        a.setStatus("cancelled");
        appointmentRepository.save(a);
    }
}
