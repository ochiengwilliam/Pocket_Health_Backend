package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.HealthTopic;
import com.Pocket_Health.Pocket_Health.repository.HealthTopicRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HealthTopicService {

    private final HealthTopicRepository healthTopicRepository;

    public List<HealthTopic> getActiveByModule(String moduleKey) {
        return healthTopicRepository.findByModuleKeyAndIsActiveTrueOrderBySortOrderAsc(moduleKey);
    }
}
