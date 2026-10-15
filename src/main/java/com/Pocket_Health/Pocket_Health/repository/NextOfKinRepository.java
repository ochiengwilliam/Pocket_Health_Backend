package com.Pocket_Health.Pocket_Health.repository;

import com.Pocket_Health.Pocket_Health.entity.NextOfKin;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NextOfKinRepository extends JpaRepository<NextOfKin, UUID> {

    List<NextOfKin> findByProfile_ProfileId(UUID profileId);

}