package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Transaction;
import com.Pocket_Health.Pocket_Health.entity.Wallet;
import com.Pocket_Health.Pocket_Health.repository.TransactionRepository;
import com.Pocket_Health.Pocket_Health.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;

    @Transactional
    public Transaction create(Map<String, Object> body) {
        Wallet wallet = walletRepository
                .findById(UUID.fromString((String) body.get("walletId")))
                .orElseThrow(() -> new RuntimeException("Wallet not found"));

        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        String type = (String) body.get("type");

        switch (type) {
            case "top_up", "refund" -> wallet.setBalanceKes(wallet.getBalanceKes().add(amount));
            case "debit" -> {
                if (wallet.getBalanceKes().compareTo(amount) < 0)
                    throw new RuntimeException("Insufficient wallet balance");
                wallet.setBalanceKes(wallet.getBalanceKes().subtract(amount));
            }
        }
        walletRepository.save(wallet);

        Transaction tx = Transaction.builder()
                .wallet(wallet)
                .amount(amount)
                .type(type)
                .paymentMethod((String) body.get("paymentMethod"))
                .mpesaReference((String) body.get("mpesaReference"))
                .status(body.get("status") != null ? (String) body.get("status") : "completed")
                .build();
        return transactionRepository.save(tx);
    }

    public List<Transaction> getAll() { return transactionRepository.findAll(); }

    public Transaction getById(UUID id) {
        return transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
    }

    public List<Transaction> getByWallet(UUID walletId) {
        return transactionRepository.findByWallet_WalletIdOrderByCreatedAtDesc(walletId);
    }
}
