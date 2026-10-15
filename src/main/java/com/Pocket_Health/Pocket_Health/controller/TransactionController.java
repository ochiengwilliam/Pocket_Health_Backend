package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Transaction;
import com.Pocket_Health.Pocket_Health.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping
    public ResponseEntity<ApiResponse<Transaction>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Transaction recorded", transactionService.create(body)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Transaction>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok("Transactions fetched", transactionService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Transaction>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Transaction fetched", transactionService.getById(id)));
    }

    @GetMapping("/wallet/{walletId}")
    public ResponseEntity<ApiResponse<List<Transaction>>> getByWallet(@PathVariable UUID walletId) {
        return ResponseEntity.ok(ApiResponse.ok("Wallet transactions fetched", transactionService.getByWallet(walletId)));
    }
}
