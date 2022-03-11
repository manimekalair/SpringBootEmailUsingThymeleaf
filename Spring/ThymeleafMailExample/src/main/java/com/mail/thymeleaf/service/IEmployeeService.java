package com.mail.thymeleaf.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.mail.thymeleaf.model.EmployeeRequest;

@Service
public interface IEmployeeService {

	EmployeeRequest saveEmployee(EmployeeRequest employee);
	
	public List<EmployeeRequest> listAll();
	
	
}
