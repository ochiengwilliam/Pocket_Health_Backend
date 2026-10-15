package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Document;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.DocumentRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.security.ProfileAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DocumentService {

    private final DocumentRepository documentRepository;
    private final ProfileRepository profileRepository;
    private final ProfileAccessGuard profileAccessGuard;

    public Document create(Map<String, Object> body) {
        Profile profile = profileAccessGuard.requireOwnedProfile(UUID.fromString((String) body.get("ownerProfileId")));
        Document doc = Document.builder()
                .ownerProfile(profile)
                .docType((String) body.get("docType"))
                .fileUrl((String) body.get("fileUrl"))
                .fileName((String) body.get("fileName"))
                .sharedWith((String) body.get("sharedWith"))
                .build();
        return documentRepository.save(doc);
    }

    public List<Document> getByProfile(UUID profileId) {
        profileAccessGuard.requireOwnedProfile(profileId);
        return documentRepository.findByOwnerProfile_ProfileId(profileId);
    }

    public List<Document> getByProfileAndType(UUID profileId, String docType) {
        profileAccessGuard.requireOwnedProfile(profileId);
        return documentRepository.findByOwnerProfile_ProfileIdAndDocType(profileId, docType);
    }

    public Document getById(UUID id) {
        return documentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Document not found"));
    }

    public Document update(UUID id, Map<String, Object> body) {
        Document doc = getById(id);
        if (body.containsKey("sharedWith")) doc.setSharedWith((String) body.get("sharedWith"));
        if (body.containsKey("fileName"))   doc.setFileName((String) body.get("fileName"));
        if (body.containsKey("docType"))    doc.setDocType((String) body.get("docType"));
        return documentRepository.save(doc);
    }

    public void delete(UUID id) { documentRepository.deleteById(id); }
}
