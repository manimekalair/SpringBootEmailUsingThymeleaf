package com.task.management.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.task.management.entity.Task;
import com.task.management.service.ITaskService;

@RestController
@RequestMapping("/api/task")
public class TaskController {
	@Autowired
	private ITaskService taskService;
	
	@PostMapping("/task")
	public Task createTask(@RequestBody Task task) {
		//return task;
		return taskService.saveTask(task);
	}
	@PutMapping("/task")
	public Task updateTask(@RequestBody Task task) {
		return taskService.saveTask(task);
	}
	@GetMapping("/task/{id}")
	public Task getTaskById(@PathVariable Long id) {
		return taskService.getTaskById(id);
	}
	@GetMapping("/task")
	public List<Task> getAllTask() {
		return taskService.findAllTasks();
	}
}