package com.service.task.serviceimpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.service.task.model.Task;
import com.service.task.repo.TaskRepository;
import com.service.task.service.ITaskService;

@Service
public class TaskServiceImpl implements ITaskService {

	@Autowired
	TaskRepository repo;
	
	@Override
	public Task saveTask(Task task) {
		
		if (task.getId()!=null) {
			repo.save(task);
		}
		return task;
	}

}
