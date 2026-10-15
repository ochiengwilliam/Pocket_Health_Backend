package com.Pocket_Health.Pocket_Health.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import java.util.UUID;

@Data @Builder @AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private UUID userId;
    private String email;
    private String userCategory;
    private String status;
}
