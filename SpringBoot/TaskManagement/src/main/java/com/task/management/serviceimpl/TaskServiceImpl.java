package com.task.management.serviceimpl;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.task.management.entity.Task;
import com.task.management.repository.TaskRepository;
import com.task.management.service.ITaskService;

@Service
public class TaskServiceImpl implements ITaskService {

	@Autowired
	private TaskRepository taskRepo;
	
	@Override
	public Task saveTask(Task task) {
		return taskRepo.save(task);
	}

	@Override
	public Task getTaskById(Long id) {
		Optional<Task> optTask=taskRepo.findById(id);
		return optTask.get();
	}

	@Override
	public List<Task> findAllTasks() {
		return taskRepo.findAll();
	}
}