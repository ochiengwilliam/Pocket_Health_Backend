package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Appointment;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.entity.ProviderAvailability;
import com.Pocket_Health.Pocket_Health.repository.AppointmentRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderAvailabilityRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProviderAvailabilityService {

    private final ProviderAvailabilityRepository availabilityRepository;
    private final ProviderRepository providerRepository;
    private final AppointmentRepository appointmentRepository;

    /** DB convention: 0=Sunday..6=Saturday (java.time.DayOfWeek is 1=Monday..7=Sunday). */
    public static short toDbDayOfWeek(LocalDate date) {
        return (short) (date.getDayOfWeek().getValue() % 7);
    }

    public ProviderAvailability create(Map<String, Object> body) {
        Provider provider = providerRepository.findById(UUID.fromString((String) body.get("providerId")))
                .orElseThrow(() -> new RuntimeException("Provider not found"));

        ProviderAvailability availability = ProviderAvailability.builder()
                .provider(provider)
                .dayOfWeek(Short.valueOf(body.get("dayOfWeek").toString()))
                .startTime(LocalTime.parse((String) body.get("startTime")))
                .endTime(LocalTime.parse((String) body.get("endTime")))
                .slotDurationMinutes(body.get("slotDurationMinutes") != null
                        ? Integer.valueOf(body.get("slotDurationMinutes").toString()) : 30)
                .isActive(body.get("isActive") == null || (Boolean) body.get("isActive"))
                .build();
        return availabilityRepository.save(availability);
    }

    public List<ProviderAvailability> getByProvider(UUID providerId) {
        return availabilityRepository.findByProvider_ProviderId(providerId);
    }

    public ProviderAvailability getById(UUID id) {
        return availabilityRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Availability window not found"));
    }

    public ProviderAvailability update(UUID id, Map<String, Object> body) {
        ProviderAvailability availability = getById(id);
        if (body.containsKey("dayOfWeek")) availability.setDayOfWeek(Short.valueOf(body.get("dayOfWeek").toString()));
        if (body.containsKey("startTime")) availability.setStartTime(LocalTime.parse((String) body.get("startTime")));
        if (body.containsKey("endTime")) availability.setEndTime(LocalTime.parse((String) body.get("endTime")));
        if (body.containsKey("slotDurationMinutes")) availability.setSlotDurationMinutes(Integer.valueOf(body.get("slotDurationMinutes").toString()));
        if (body.containsKey("isActive")) availability.setIsActive((Boolean) body.get("isActive"));
        return availabilityRepository.save(availability);
    }

    public void delete(UUID id) {
        availabilityRepository.delete(getById(id));
    }

    /** Computes open slot start times for a provider on a given date, excluding already-booked (non-cancelled) appointments. */
    public List<Map<String, Object>> getAvailableSlots(UUID providerId, LocalDate date) {
        short dbDayOfWeek = toDbDayOfWeek(date);
        List<ProviderAvailability> windows =
                availabilityRepository.findByProvider_ProviderIdAndDayOfWeekAndIsActiveTrue(providerId, dbDayOfWeek);

        List<Appointment> bookedOnDate = appointmentRepository.findByProvider_ProviderId(providerId).stream()
                .filter(a -> !"cancelled".equalsIgnoreCase(a.getStatus()))
                .filter(a -> a.getScheduledAt().toLocalDate().equals(date))
                .toList();

        ZoneId zone = ZoneId.systemDefault();
        List<Map<String, Object>> slots = new ArrayList<>();

        for (ProviderAvailability window : windows) {
            int durationMinutes = window.getSlotDurationMinutes();
            LocalTime cursor = window.getStartTime();
            while (!cursor.plusMinutes(durationMinutes).isAfter(window.getEndTime())) {
                OffsetDateTime slotStart = date.atTime(cursor).atZone(zone).toOffsetDateTime();
                OffsetDateTime slotEnd = slotStart.plusMinutes(durationMinutes);

                boolean overlaps = bookedOnDate.stream().anyMatch(a -> {
                    OffsetDateTime bookedStart = a.getScheduledAt();
                    OffsetDateTime bookedEnd = bookedStart.plusMinutes(a.getDurationSlot() != null ? a.getDurationSlot() : 30);
                    return slotStart.isBefore(bookedEnd) && bookedStart.isBefore(slotEnd);
                });

                if (!overlaps) {
                    Map<String, Object> slot = new HashMap<>();
                    slot.put("startTime", slotStart.toString());
                    slot.put("durationMinutes", durationMinutes);
                    slots.add(slot);
                }

                cursor = cursor.plusMinutes(durationMinutes);
            }
        }
        return slots;
    }

    /** Used by AppointmentService to confirm a requested booking time falls inside one of the provider's active windows. */
    public boolean isWithinAvailability(UUID providerId, OffsetDateTime scheduledAt, int durationMinutes) {
        short dbDayOfWeek = toDbDayOfWeek(scheduledAt.toLocalDate());
        LocalTime start = scheduledAt.toLocalTime();
        LocalTime end = start.plusMinutes(durationMinutes);

        return availabilityRepository.findByProvider_ProviderIdAndDayOfWeekAndIsActiveTrue(providerId, dbDayOfWeek).stream()
                .anyMatch(w -> !start.isBefore(w.getStartTime()) && !end.isAfter(w.getEndTime()));
    }
}
