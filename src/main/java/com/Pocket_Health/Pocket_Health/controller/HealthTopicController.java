package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.HealthTopic;
import com.Pocket_Health.Pocket_Health.service.HealthTopicService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/health-topics")
@RequiredArgsConstructor
public class HealthTopicController {

    private final HealthTopicService healthTopicService;

    @GetMapping("/module/{moduleKey}")
    public ResponseEntity<ApiResponse<List<HealthTopic>>> getByModule(@PathVariable String moduleKey) {
        return ResponseEntity.ok(ApiResponse.ok("Topics fetched", healthTopicService.getActiveByModule(moduleKey)));
    }
}
