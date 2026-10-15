package com.Pocket_Health.Pocket_Health.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * Calls Groq's OpenAI-compatible chat completions API to turn a symptom list into a
 * plain-language explanation. Groq's LPU inference keeps replies fast (typically well
 * under a second of model time), and the free tier is generous enough for this use case.
 */
@Slf4j
@Service
public class SymptomAiService {

    private final RestTemplate restTemplate;

    @Value("${app.groq.api-key:}")
    private String apiKey;

    @Value("${app.groq.model:openai/gpt-oss-20b}")
    private String model;

    @Value("${app.groq.api-url:https://api.groq.com/openai/v1/chat/completions}")
    private String apiUrl;

    public SymptomAiService() {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(10_000);
        requestFactory.setReadTimeout(20_000);
        this.restTemplate = new RestTemplate(requestFactory);
    }

    @SuppressWarnings("unchecked")
    /**
     * Describes who the symptoms belong to. Built only from fixed wording and a bounded number so
     * nothing the client sends ends up in the prompt verbatim.
     */
    private static String describeSubject(String audience, Integer weeks) {
        String w = (weeks != null && weeks > 0 && weeks <= 104) ? String.valueOf(weeks) : null;
        if ("child".equals(audience)) return "A child under 12 years old";
        if ("pregnant".equals(audience)) {
            return w != null ? "A person who is " + w + " weeks pregnant" : "A pregnant person";
        }
        if ("lactating".equals(audience)) {
            return w != null
                    ? "A breastfeeding person who gave birth " + w + " weeks ago"
                    : "A breastfeeding person who recently gave birth";
        }
        return "A person";
    }

    public String analyzeSymptoms(List<String> symptoms, List<String> possibleConditions,
                                  String audience, Integer weeks) {
        if (symptoms == null || symptoms.isEmpty()) {
            throw new IllegalArgumentException("At least one symptom is required.");
        }
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("Symptom AI is not configured on the server.");
        }

        String conditionHint = (possibleConditions == null || possibleConditions.isEmpty())
                ? ""
                : " A reference database also flagged these as possible matches: "
                        + String.join(", ", possibleConditions) + ".";

        boolean pregnancyContext = "pregnant".equals(audience) || "lactating".equals(audience);
        String safetyHint = "child".equals(audience)
                ? " Tailor the advice to a child and mention danger signs that need urgent care."
                : pregnancyContext
                        ? " Tailor the advice to pregnancy or breastfeeding, note that medicines should only be taken"
                                + " on a clinician's advice, and mention danger signs that need urgent care."
                        : "";

        String prompt = describeSubject(audience, weeks) + " reports these symptoms: " + String.join(", ", symptoms) + "." + conditionHint
                + " In plain, reassuring language and under 120 words, explain what might be going on and what "
                + "they should consider doing next. Do not give a definite diagnosis, and recommend seeing a "
                + "doctor for anything serious." + safetyHint;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, Object> body = Map.of(
                "model", model,
                "messages", List.of(
                        Map.of("role", "system", "content",
                                "You are a cautious health assistant. You never give a definite diagnosis; you "
                                        + "explain possibilities in plain language and advise seeing a clinician "
                                        + "when appropriate."),
                        Map.of("role", "user", "content", prompt)
                ),
                "temperature", 0.4,
                "max_tokens", 300
        );

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(apiUrl, new HttpEntity<>(body, headers), Map.class);
            List<Map<String, Object>> choices = (List<Map<String, Object>>) response.getBody().get("choices");
            Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
            return ((String) message.get("content")).trim();
        } catch (Exception e) {
            log.error("Groq symptom analysis failed", e);
            throw new RuntimeException("Couldn't reach the AI service right now. Please try again shortly.");
        }
    }
}
