package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.ProviderAvailability;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ProviderAvailabilityRepository extends JpaRepository<ProviderAvailability, UUID> {
    List<ProviderAvailability> findByProvider_ProviderId(UUID providerId);
    List<ProviderAvailability> findByProvider_ProviderIdAndDayOfWeekAndIsActiveTrue(UUID providerId, Short dayOfWeek);
}
