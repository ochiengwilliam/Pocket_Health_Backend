package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.HealthTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface HealthTopicRepository extends JpaRepository<HealthTopic, UUID> {
    List<HealthTopic> findByModuleKeyAndIsActiveTrueOrderBySortOrderAsc(String moduleKey);
}
