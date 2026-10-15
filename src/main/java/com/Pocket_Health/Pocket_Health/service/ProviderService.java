package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProviderService {

    private static final Set<String> CATEGORIES = new LinkedHashSet<>(List.of(
            "doctor", "nurse", "specialist", "hospital", "pharmacy", "lab", "insurer"));

    private final ProviderRepository providerRepository;
    private final UserRepository userRepository;

    private String validateCategory(Object rawCategory) {
        if (rawCategory == null) return null;
        String category = rawCategory.toString().trim();
        if (category.isEmpty()) return null;
        String match = CATEGORIES.stream()
                .filter(c -> c.equalsIgnoreCase(category))
                .findFirst()
                .orElseThrow(() -> new RuntimeException(
                        "Unknown provider category '" + category + "'. Allowed: " + String.join(", ", CATEGORIES)));
        return match;
    }

    public List<String> getCategories() { return List.copyOf(CATEGORIES); }

    public Provider create(Map<String, Object> body) {
        UUID userId = UUID.fromString((String) body.get("userId"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Provider provider = Provider.builder()
                .user(user)
                .providerName((String) body.get("providerName"))
                .category(validateCategory(body.get("category")))
                .specialty((String) body.get("specialty"))
                .location((String) body.get("location"))
                .region((String) body.get("region"))
                .isVerified(body.get("isVerified") != null && (Boolean) body.get("isVerified"))
                .isAvailable(body.get("isAvailable") == null || (Boolean) body.get("isAvailable"))
                .rates(body.get("rates") != null ? new BigDecimal(body.get("rates").toString()) : null)
                .build();
        return providerRepository.save(provider);
    }

    public List<Provider> getAll() { return providerRepository.findAll(); }

    public List<Provider> getAvailable() { return providerRepository.findByIsAvailableTrue(); }

    public List<Provider> getByRegion(String region) { return providerRepository.findByRegion(region); }

    public Provider getById(UUID id) {
        return providerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Provider not found"));
    }

    public Provider getByUserId(UUID userId) {
        return providerRepository.findByUser_UserId(userId)
                .orElseThrow(() -> new RuntimeException("Provider not found for this user"));
    }

    public List<String> getSpecialties() { return providerRepository.findDistinctSpecialties(); }

    public List<Provider> search(String query, String specialty, String region, String category, Boolean available) {
        List<Provider> results = query != null && !query.isBlank()
                ? providerRepository.findByProviderNameContainingIgnoreCaseOrSpecialtyContainingIgnoreCase(query, query)
                : providerRepository.findAll();

        return results.stream()
                .filter(p -> specialty == null || specialty.isBlank() || specialty.equalsIgnoreCase(p.getSpecialty()))
                .filter(p -> region == null || region.isBlank() || region.equalsIgnoreCase(p.getRegion()))
                .filter(p -> category == null || category.isBlank() || category.equalsIgnoreCase(p.getCategory()))
                .filter(p -> available == null || available.equals(p.getIsAvailable()))
                .toList();
    }

    public Provider update(UUID id, Map<String, Object> body) {
        Provider provider = getById(id);
        if (body.containsKey("providerName")) provider.setProviderName((String) body.get("providerName"));
        if (body.containsKey("category"))     provider.setCategory(validateCategory(body.get("category")));
        if (body.containsKey("region"))       provider.setRegion((String) body.get("region"));
        if (body.containsKey("specialty"))    provider.setSpecialty((String) body.get("specialty"));
        if (body.containsKey("location"))     provider.setLocation((String) body.get("location"));
        if (body.containsKey("isAvailable"))  provider.setIsAvailable((Boolean) body.get("isAvailable"));
        if (body.containsKey("isVerified"))   provider.setIsVerified((Boolean) body.get("isVerified"));
        if (body.containsKey("rates"))        provider.setRates(new BigDecimal(body.get("rates").toString()));
        return providerRepository.save(provider);
    }
}
