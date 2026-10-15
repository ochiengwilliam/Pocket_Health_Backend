#!/bin/bash
# ================================================================
#  PocketHealth — Remaining 6 Controllers & Services
#  Emergency Contact, Insurance, Transaction, Review, Document, Medical Request
#  Run from project root:
#  chmod +x remaining_controllers.sh && ./remaining_controllers.sh
# ================================================================

BASE="src/main/java/com/Pocket_Health/Pocket_Health"

# ── Emergency Contact Service ────────────────────────────────────
cat > $BASE/service/EmergencyContactService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.EmergencyContact;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.EmergencyContactRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EmergencyContactService {

    private final EmergencyContactRepository emergencyContactRepository;
    private final ProfileRepository profileRepository;

    public EmergencyContact create(Map<String, Object> body) {
        Profile profile = profileRepository
                .findById(UUID.fromString((String) body.get("profileId")))
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        EmergencyContact contact = EmergencyContact.builder()
                .profile(profile)
                .name((String) body.get("name"))
                .phone1((String) body.get("phone1"))
                .phone2((String) body.get("phone2"))
                .priority(body.get("priority") != null ? Short.valueOf(body.get("priority").toString()) : (short) 1)
                .emergencyType((String) body.get("emergencyType"))
                .build();
        return emergencyContactRepository.save(contact);
    }

    public List<EmergencyContact> getByProfile(UUID profileId) {
        return emergencyContactRepository.findByProfile_ProfileIdOrderByPriorityAsc(profileId);
    }

    public EmergencyContact getById(UUID id) {
        return emergencyContactRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Emergency contact not found"));
    }

    public EmergencyContact update(UUID id, Map<String, Object> body) {
        EmergencyContact c = getById(id);
        if (body.containsKey("name"))          c.setName((String) body.get("name"));
        if (body.containsKey("phone1"))        c.setPhone1((String) body.get("phone1"));
        if (body.containsKey("phone2"))        c.setPhone2((String) body.get("phone2"));
        if (body.containsKey("priority"))      c.setPriority(Short.valueOf(body.get("priority").toString()));
        if (body.containsKey("emergencyType")) c.setEmergencyType((String) body.get("emergencyType"));
        return emergencyContactRepository.save(c);
    }

    public void delete(UUID id) { emergencyContactRepository.deleteById(id); }
}
EOF

# ── Emergency Contact Controller ─────────────────────────────────
cat > $BASE/controller/EmergencyContactController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.EmergencyContact;
import com.Pocket_Health.Pocket_Health.service.EmergencyContactService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/emergency-contacts")
@RequiredArgsConstructor
public class EmergencyContactController {

    private final EmergencyContactService emergencyContactService;

    @PostMapping
    public ResponseEntity<ApiResponse<EmergencyContact>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Emergency contact created", emergencyContactService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<EmergencyContact>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Contacts fetched", emergencyContactService.getByProfile(profileId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EmergencyContact>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Contact fetched", emergencyContactService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<EmergencyContact>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Contact updated", emergencyContactService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        emergencyContactService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Contact deleted", null));
    }
}
EOF

# ── Insurance Service ─────────────────────────────────────────────
cat > $BASE/service/InsuranceService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Insurance;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.InsuranceRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class InsuranceService {

    private final InsuranceRepository insuranceRepository;
    private final ProfileRepository profileRepository;

    public Insurance create(Map<String, Object> body) {
        Profile profile = profileRepository
                .findById(UUID.fromString((String) body.get("profileId")))
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        Insurance insurance = Insurance.builder()
                .profile(profile)
                .insurerName((String) body.get("insurerName"))
                .policyNumber((String) body.get("policyNumber"))
                .phone1((String) body.get("phone1"))
                .phone2((String) body.get("phone2"))
                .build();
        return insuranceRepository.save(insurance);
    }

    public List<Insurance> getByProfile(UUID profileId) {
        return insuranceRepository.findByProfile_ProfileId(profileId);
    }

    public Insurance getById(UUID id) {
        return insuranceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Insurance not found"));
    }

    public Insurance update(UUID id, Map<String, Object> body) {
        Insurance i = getById(id);
        if (body.containsKey("insurerName"))  i.setInsurerName((String) body.get("insurerName"));
        if (body.containsKey("policyNumber")) i.setPolicyNumber((String) body.get("policyNumber"));
        if (body.containsKey("phone1"))       i.setPhone1((String) body.get("phone1"));
        if (body.containsKey("phone2"))       i.setPhone2((String) body.get("phone2"));
        return insuranceRepository.save(i);
    }

    public void delete(UUID id) { insuranceRepository.deleteById(id); }
}
EOF

# ── Insurance Controller ──────────────────────────────────────────
cat > $BASE/controller/InsuranceController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Insurance;
import com.Pocket_Health.Pocket_Health.service.InsuranceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/insurance")
@RequiredArgsConstructor
public class InsuranceController {

    private final InsuranceService insuranceService;

    @PostMapping
    public ResponseEntity<ApiResponse<Insurance>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance created", insuranceService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<Insurance>>> getByProfile(@PathVariable UUID profileId) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance fetched", insuranceService.getByProfile(profileId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Insurance>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance fetched", insuranceService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Insurance>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Insurance updated", insuranceService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        insuranceService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Insurance deleted", null));
    }
}
EOF

# ── Transaction Service ───────────────────────────────────────────
cat > $BASE/service/TransactionService.java << 'EOF'
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
EOF

# ── Transaction Controller ────────────────────────────────────────
cat > $BASE/controller/TransactionController.java << 'EOF'
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
EOF

# ── Review Service ────────────────────────────────────────────────
cat > $BASE/service/ReviewService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.entity.Review;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import com.Pocket_Health.Pocket_Health.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final ProfileRepository profileRepository;
    private final ProviderRepository providerRepository;

    public Review create(Map<String, Object> body) {
        Profile profile = profileRepository
                .findById(UUID.fromString((String) body.get("reviewerProfileId")))
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        Provider provider = providerRepository
                .findById(UUID.fromString((String) body.get("providerId")))
                .orElseThrow(() -> new RuntimeException("Provider not found"));

        Review review = Review.builder()
                .reviewerProfile(profile)
                .provider(provider)
                .ratingQuality(body.get("ratingQuality") != null ? Short.valueOf(body.get("ratingQuality").toString()) : null)
                .ratingHelpful(body.get("ratingHelpful") != null ? Short.valueOf(body.get("ratingHelpful").toString()) : null)
                .ratingTimely(body.get("ratingTimely") != null ? Short.valueOf(body.get("ratingTimely").toString()) : null)
                .ratingCare(body.get("ratingCare") != null ? Short.valueOf(body.get("ratingCare").toString()) : null)
                .reviewText((String) body.get("reviewText"))
                .build();
        return reviewRepository.save(review);
    }

    public List<Review> getByProvider(UUID providerId) {
        return reviewRepository.findByProvider_ProviderId(providerId);
    }

    public Map<String, Object> getProviderRating(UUID providerId) {
        Double avg = reviewRepository.findAverageRatingByProviderId(providerId);
        return Map.of(
                "providerId", providerId,
                "totalReviews", reviewRepository.findByProvider_ProviderId(providerId).size(),
                "averageRating", avg != null ? Math.round(avg * 10.0) / 10.0 : 0.0
        );
    }

    public Review getById(UUID id) {
        return reviewRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Review not found"));
    }

    public void delete(UUID id) { reviewRepository.deleteById(id); }
}
EOF

# ── Review Controller ─────────────────────────────────────────────
cat > $BASE/controller/ReviewController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Review;
import com.Pocket_Health.Pocket_Health.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    public ResponseEntity<ApiResponse<Review>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Review submitted", reviewService.create(body)));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<ApiResponse<List<Review>>> getByProvider(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Reviews fetched", reviewService.getByProvider(providerId)));
    }

    @GetMapping("/provider/{providerId}/rating")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getRating(@PathVariable UUID providerId) {
        return ResponseEntity.ok(ApiResponse.ok("Rating fetched", reviewService.getProviderRating(providerId)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Review>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Review fetched", reviewService.getById(id)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        reviewService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Review deleted", null));
    }
}
EOF

# ── Document Service ──────────────────────────────────────────────
cat > $BASE/service/DocumentService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Document;
import com.Pocket_Health.Pocket_Health.entity.Profile;
import com.Pocket_Health.Pocket_Health.repository.DocumentRepository;
import com.Pocket_Health.Pocket_Health.repository.ProfileRepository;
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

    public Document create(Map<String, Object> body) {
        Profile profile = profileRepository
                .findById(UUID.fromString((String) body.get("ownerProfileId")))
                .orElseThrow(() -> new RuntimeException("Profile not found"));
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
        return documentRepository.findByOwnerProfile_ProfileId(profileId);
    }

    public List<Document> getByProfileAndType(UUID profileId, String docType) {
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
EOF

# ── Document Controller ───────────────────────────────────────────
cat > $BASE/controller/DocumentController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.Document;
import com.Pocket_Health.Pocket_Health.service.DocumentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/documents")
@RequiredArgsConstructor
public class DocumentController {

    private final DocumentService documentService;

    @PostMapping
    public ResponseEntity<ApiResponse<Document>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Document uploaded", documentService.create(body)));
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<Document>>> getByProfile(
            @PathVariable UUID profileId,
            @RequestParam(required = false) String type) {
        List<Document> docs = type != null
                ? documentService.getByProfileAndType(profileId, type)
                : documentService.getByProfile(profileId);
        return ResponseEntity.ok(ApiResponse.ok("Documents fetched", docs));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Document>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Document fetched", documentService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<Document>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Document updated", documentService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        documentService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Document deleted", null));
    }
}
EOF

# ── Medical Request Service ───────────────────────────────────────
cat > $BASE/service/MedicalRequestService.java << 'EOF'
package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.entity.Consultation;
import com.Pocket_Health.Pocket_Health.entity.MedicalRequest;
import com.Pocket_Health.Pocket_Health.entity.Provider;
import com.Pocket_Health.Pocket_Health.repository.ConsultationRepository;
import com.Pocket_Health.Pocket_Health.repository.MedicalRequestRepository;
import com.Pocket_Health.Pocket_Health.repository.ProviderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MedicalRequestService {

    private final MedicalRequestRepository medicalRequestRepository;
    private final ConsultationRepository consultationRepository;
    private final ProviderRepository providerRepository;

    public MedicalRequest create(Map<String, Object> body) {
        Consultation consultation = consultationRepository
                .findById(UUID.fromString((String) body.get("consultationId")))
                .orElseThrow(() -> new RuntimeException("Consultation not found"));
        Provider sentToProvider = null;
        if (body.get("sentToProviderId") != null) {
            sentToProvider = providerRepository
                    .findById(UUID.fromString((String) body.get("sentToProviderId")))
                    .orElseThrow(() -> new RuntimeException("Provider not found"));
        }
        MedicalRequest request = MedicalRequest.builder()
                .consultation(consultation)
                .requestType((String) body.get("requestType"))
                .content((String) body.get("content"))
                .sentToProvider(sentToProvider)
                .build();
        return medicalRequestRepository.save(request);
    }

    public List<MedicalRequest> getByConsultation(UUID consultationId) {
        return medicalRequestRepository.findByConsultation_ConsultationId(consultationId);
    }

    public List<MedicalRequest> getByType(String type) {
        return medicalRequestRepository.findByRequestType(type);
    }

    public MedicalRequest getById(UUID id) {
        return medicalRequestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Medical request not found"));
    }

    public MedicalRequest update(UUID id, Map<String, Object> body) {
        MedicalRequest r = getById(id);
        if (body.containsKey("content"))     r.setContent((String) body.get("content"));
        if (body.containsKey("requestType")) r.setRequestType((String) body.get("requestType"));
        if (body.containsKey("sentToProviderId")) {
            Provider p = providerRepository
                    .findById(UUID.fromString((String) body.get("sentToProviderId")))
                    .orElseThrow(() -> new RuntimeException("Provider not found"));
            r.setSentToProvider(p);
        }
        return medicalRequestRepository.save(r);
    }

    public void delete(UUID id) { medicalRequestRepository.deleteById(id); }
}
EOF

# ── Medical Request Controller ────────────────────────────────────
cat > $BASE/controller/MedicalRequestController.java << 'EOF'
package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.MedicalRequest;
import com.Pocket_Health.Pocket_Health.service.MedicalRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/medical-requests")
@RequiredArgsConstructor
public class MedicalRequestController {

    private final MedicalRequestService medicalRequestService;

    @PostMapping
    public ResponseEntity<ApiResponse<MedicalRequest>> create(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Medical request created", medicalRequestService.create(body)));
    }

    @GetMapping("/consultation/{consultationId}")
    public ResponseEntity<ApiResponse<List<MedicalRequest>>> getByConsultation(@PathVariable UUID consultationId) {
        return ResponseEntity.ok(ApiResponse.ok("Requests fetched", medicalRequestService.getByConsultation(consultationId)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MedicalRequest>>> getByType(
            @RequestParam(required = false, defaultValue = "prescription") String type) {
        return ResponseEntity.ok(ApiResponse.ok("Requests fetched", medicalRequestService.getByType(type)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<MedicalRequest>> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok("Request fetched", medicalRequestService.getById(id)));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<MedicalRequest>> update(@PathVariable UUID id, @RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ApiResponse.ok("Request updated", medicalRequestService.update(id, body)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id) {
        medicalRequestService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Request deleted", null));
    }
}
EOF

echo ""
echo "✅ All 6 remaining controllers and services created!"
echo "Restart IntelliJ and you are done!"
