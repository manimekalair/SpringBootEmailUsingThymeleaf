package com.task.management.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.task.management.entity.Task;

@Service
public interface ITaskService {
	Task saveTask(Task task);
	Task getTaskById(Long id);
	List<Task> findAllTasks();
}
