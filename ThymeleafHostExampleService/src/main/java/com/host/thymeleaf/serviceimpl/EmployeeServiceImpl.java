package com.host.thymeleaf.serviceimpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.host.thymeleaf.model.Employee;
import com.host.thymeleaf.repo.EmployeeRepository;
import com.host.thymeleaf.service.IEmployeeService;

@Service
public class EmployeeServiceImpl implements IEmployeeService {

	@Autowired
	EmployeeRepository repo;
	
	@Override
	public List<Employee> listAll() {
		
		return repo.findAll();
	}

}
