package com.Pocket_Health.Pocket_Health.dto.request;

import lombok.Data;

import java.util.List;

@Data
public class SymptomCheckRequest {
    private List<String> symptoms;
    private List<String> possibleConditions;
    /** Who the check is for: "adult" (default), "child" (under 12), "pregnant" or "lactating". */
    private String audience;
    /** Weeks pregnant, or weeks since delivery when lactating. */
    private Integer weeks;
}
