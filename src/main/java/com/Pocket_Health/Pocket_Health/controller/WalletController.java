package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Wallet;
import com.Pocket_Health.Pocket_Health.service.WalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/wallets")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @PostMapping
    public ResponseEntity<ApiResponse<Wallet>> create(@RequestBody Map<String, Object> body) {
        UUID userId = UUID.fromString((String) body.get("userId"));
        return ResponseEntity.ok(ApiResponse.ok("Wallet created", walletService.create(userId)));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Wallet>> getByUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(ApiResponse.ok("Wallet fetched", walletService.getByUserId(userId)));
    }

    @PatchMapping("/{walletId}/topup")
    public ResponseEntity<ApiResponse<Wallet>> topUp(@PathVariable UUID walletId, @RequestBody Map<String, Object> body) {
        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        return ResponseEntity.ok(ApiResponse.ok("Wallet topped up", walletService.topUp(walletId, amount)));
    }

    @PatchMapping("/{walletId}/debit")
    public ResponseEntity<ApiResponse<Wallet>> debit(@PathVariable UUID walletId, @RequestBody Map<String, Object> body) {
        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        return ResponseEntity.ok(ApiResponse.ok("Wallet debited", walletService.debit(walletId, amount)));
    }
}
