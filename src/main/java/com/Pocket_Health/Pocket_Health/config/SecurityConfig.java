package com.Pocket_Health.Pocket_Health.config;

import com.Pocket_Health.Pocket_Health.security.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http,
            CorsConfigurationSource corsConfigurationSource
    ) throws Exception {

        http
                // Configure CORS before authorization.
                .cors(cors ->
                        cors.configurationSource(corsConfigurationSource)
                )

                // Stateless REST API; authentication uses JWT.
                .csrf(AbstractHttpConfigurer::disable)

                .sessionManagement(session ->
                        session.sessionCreationPolicy(
                                SessionCreationPolicy.STATELESS
                        )
                )

                .authorizeHttpRequests(auth -> auth

                        // Allow browser preflight requests.
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                        // Public health endpoint.
                        .requestMatchers("/actuator/health").permitAll()

                        // Public authentication endpoints.
                        .requestMatchers("/auth/**").permitAll()

                        // All other endpoints require authentication.
                        .anyRequest().authenticated()
                )

                // Preserve the existing JWT authentication filter.
                .addFilterBefore(
                        jwtAuthFilter,
                        UsernamePasswordAuthenticationFilter.class
                );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {

        CorsConfiguration config = new CorsConfiguration();

        // Production frontend and local development.
        config.setAllowedOrigins(List.of(
                "https://pocket-health-frontend.vercel.app",
                "http://localhost:5173",
                "http://localhost:5174"
        ));

        config.setAllowedMethods(List.of(
                "GET",
                "POST",
                "PUT",
                "PATCH",
                "DELETE",
                "OPTIONS"
        ));

        // Allow JSON requests and Authorization headers.
        config.setAllowedHeaders(List.of("*"));

        // Preserve compatibility with cookie-based requests.
        config.setAllowCredentials(true);

        // Cache successful preflight responses for one hour.
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();

        source.registerCorsConfiguration("/**", config);

        return source;
    }
}
