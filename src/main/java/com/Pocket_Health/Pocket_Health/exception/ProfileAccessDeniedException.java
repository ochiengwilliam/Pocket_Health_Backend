package com.Pocket_Health.Pocket_Health.exception;

public class ProfileAccessDeniedException extends RuntimeException {
    public ProfileAccessDeniedException(String message) {
        super(message);
    }
}
