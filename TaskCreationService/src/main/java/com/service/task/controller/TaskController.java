package com.service.task.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.service.task.model.Task;
import com.service.task.service.ITaskService;

@RestController
@RequestMapping("/task")
public class TaskController {
	
	@Autowired
	ITaskService service;
	
	@PostMapping("/save")
	public Task createTask(@RequestBody Task task) {
		
		return service.saveTask(task);
	}

}
