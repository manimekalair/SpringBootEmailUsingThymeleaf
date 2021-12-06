package com.service.task.service;

import org.springframework.stereotype.Service;

import com.service.task.model.Task;

@Service
public interface ITaskService {
	
	Task saveTask(Task task);

}
