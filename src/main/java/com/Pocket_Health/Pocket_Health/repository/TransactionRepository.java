package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface TransactionRepository extends JpaRepository<Transaction, UUID> {
    List<Transaction> findByWallet_WalletIdOrderByCreatedAtDesc(UUID walletId);
}
