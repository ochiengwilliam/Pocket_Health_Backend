package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.entity.Wallet;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import com.Pocket_Health.Pocket_Health.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class WalletService {

    private final WalletRepository walletRepository;
    private final UserRepository userRepository;

    public Wallet create(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (walletRepository.findByUser_UserId(userId).isPresent()) {
            throw new RuntimeException("Wallet already exists for this user");
        }
        return walletRepository.save(Wallet.builder().user(user).balanceKes(BigDecimal.ZERO).build());
    }

    public Wallet getByUserId(UUID userId) {
        return walletRepository.findByUser_UserId(userId)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
    }

    public Wallet topUp(UUID walletId, BigDecimal amount) {
        Wallet wallet = walletRepository.findById(walletId)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
        wallet.setBalanceKes(wallet.getBalanceKes().add(amount));
        return walletRepository.save(wallet);
    }

    public Wallet debit(UUID walletId, BigDecimal amount) {
        Wallet wallet = walletRepository.findById(walletId)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
        if (wallet.getBalanceKes().compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient wallet balance");
        }
        wallet.setBalanceKes(wallet.getBalanceKes().subtract(amount));
        return walletRepository.save(wallet);
    }
}
