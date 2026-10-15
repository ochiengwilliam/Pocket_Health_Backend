package com.Pocket_Health.Pocket_Health.service;

import com.Pocket_Health.Pocket_Health.dto.request.LoginRequest;
import com.Pocket_Health.Pocket_Health.dto.request.RegisterRequest;
import com.Pocket_Health.Pocket_Health.dto.response.AuthResponse;
import com.Pocket_Health.Pocket_Health.entity.User;
import com.Pocket_Health.Pocket_Health.repository.UserRepository;
import com.Pocket_Health.Pocket_Health.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new RuntimeException("Email already registered");
        }
        User user = User.builder()
                .email(req.getEmail())
                .pinHash(passwordEncoder.encode(req.getPin()))
                .userCategory(req.getUserCategory())
                .status("active")
                .build();
        userRepository.save(user);
        return buildResponse(user);
    }

    public AuthResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(req.getPin(), user.getPinHash())) {
            throw new RuntimeException("Invalid credentials");
        }
        return buildResponse(user);
    }

    private AuthResponse buildResponse(User user) {
        String token = jwtService.generateToken(
                user.getUserId().toString(),
                user.getEmail(),
                user.getUserCategory()
        );
        return AuthResponse.builder()
                .accessToken(token)
                .userId(user.getUserId())
                .email(user.getEmail())
                .userCategory(user.getUserCategory())
                .status(user.getStatus())
                .build();
    }
}
