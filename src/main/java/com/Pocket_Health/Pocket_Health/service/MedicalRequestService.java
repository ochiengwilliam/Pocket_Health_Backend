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
