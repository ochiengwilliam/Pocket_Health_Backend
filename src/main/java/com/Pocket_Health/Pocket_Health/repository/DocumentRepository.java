package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface DocumentRepository extends JpaRepository<Document, UUID> {
    List<Document> findByOwnerProfile_ProfileId(UUID profileId);
    List<Document> findByOwnerProfile_ProfileIdAndDocType(UUID profileId, String docType);
}
