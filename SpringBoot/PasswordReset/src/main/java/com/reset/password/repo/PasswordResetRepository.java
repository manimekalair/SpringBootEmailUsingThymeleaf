package com.reset.password.repo;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.reset.password.entity.PasswordReset;

@Repository
public interface PasswordResetRepository extends JpaRepository<PasswordReset, Long> {
	@Query("select p from PasswordReset p where p.empEmailId = ?1")
	Optional<PasswordReset> findByEmailId(String empEmailId);
}
