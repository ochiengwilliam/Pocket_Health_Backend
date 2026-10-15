package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.request.LoginRequest;
import com.Pocket_Health.Pocket_Health.dto.request.RegisterRequest;
import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.dto.response.AuthResponse;
import com.Pocket_Health.Pocket_Health.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest req) {
        AuthResponse response = authService.register(req);
        return ResponseEntity.ok(ApiResponse.ok("User registered successfully", response));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest req) {
        AuthResponse response = authService.login(req);
        return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
    }
}
