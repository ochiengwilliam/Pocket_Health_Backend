package com.Pocket_Health.Pocket_Health.controller;

import com.Pocket_Health.Pocket_Health.dto.response.ApiResponse;
import com.Pocket_Health.Pocket_Health.entity.NextOfKin;
//import com.Pocket_Health.Pocket_Health.payload.ApiResponse;
import com.Pocket_Health.Pocket_Health.service.NextOfKinService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/next-of-kin")
@RequiredArgsConstructor
public class NextOfKinController {

    private final NextOfKinService nextOfKinService;

    @PostMapping
    public ResponseEntity<ApiResponse<NextOfKin>> create(@RequestBody Map<String,Object> body){
        return ResponseEntity.ok(
                ApiResponse.ok("Next of kin created",
                        nextOfKinService.create(body))
        );
    }

    @GetMapping("/profile/{profileId}")
    public ResponseEntity<ApiResponse<List<NextOfKin>>> getByProfile(@PathVariable UUID profileId){
        return ResponseEntity.ok(
                ApiResponse.ok("Next of kin fetched",
                        nextOfKinService.getByProfile(profileId))
        );
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<NextOfKin>> update(
            @PathVariable UUID id,
            @RequestBody Map<String,Object> body){

        return ResponseEntity.ok(
                ApiResponse.ok("Next of kin updated",
                        nextOfKinService.update(id, body))
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable UUID id){
        nextOfKinService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok("Deleted", null));
    }
}