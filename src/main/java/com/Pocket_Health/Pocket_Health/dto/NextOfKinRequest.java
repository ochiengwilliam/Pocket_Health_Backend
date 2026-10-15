package com.Pocket_Health.Pocket_Health.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class NextOfKinRequest {

    private UUID profileId;

    private String fullName;

    private String relationship;

    private String phone1;

    private String phone2;

    private String email;

    private String address;

}