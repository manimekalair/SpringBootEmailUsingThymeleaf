package com.call.service.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.call.service.model.TestOne;

@Repository
public interface TestRepository extends JpaRepository<TestOne, Long> {

}
