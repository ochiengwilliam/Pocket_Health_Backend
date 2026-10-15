package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.request.SymptomCheckRequest;
import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.service.SymptomAiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/symptom-checker")
@RequiredArgsConstructor
public class SymptomCheckerController {

    private final SymptomAiService symptomAiService;

    @PostMapping("/analyze")
    public ResponseEntity<ApiResponse<String>> analyze(@RequestBody SymptomCheckRequest request) {
        String analysis = symptomAiService.analyzeSymptoms(
                request.getSymptoms(), request.getPossibleConditions(), request.getAudience(), request.getWeeks());
        return ResponseEntity.ok(ApiResponse.ok("Analysis generated", analysis));
    }
}
