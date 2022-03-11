package com.mail.thymeleaf.serviceimpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.mail.thymeleaf.model.EmployeeRequest;
import com.mail.thymeleaf.repository.EmployeeRepository;
import com.mail.thymeleaf.service.IEmployeeService;

@Service
public class EmployeeServiceImpl implements IEmployeeService {

	@Autowired
	EmployeeRepository repo;
	
	@Override
	public EmployeeRequest saveEmployee(EmployeeRequest employee) {
		
		System.out.print(employee);
		return repo.save(employee);
	}

	@Override
	public List<EmployeeRequest> listAll() {
		
		return repo.findAll();
	}

}
