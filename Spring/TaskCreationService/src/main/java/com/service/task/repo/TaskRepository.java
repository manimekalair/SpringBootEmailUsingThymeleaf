package com.service.task.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.service.task.model.Task;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

}
