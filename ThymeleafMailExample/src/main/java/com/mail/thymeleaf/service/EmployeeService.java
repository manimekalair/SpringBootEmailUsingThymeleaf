package com.mail.thymeleaf.service;

import org.springframework.stereotype.Service;

import com.mail.thymeleaf.model.EmployeeRequest;
import com.mail.thymeleaf.model.EmployeeResponse;

@Service
public interface EmployeeService {
	
	EmployeeResponse sendEmployeeEmail(EmployeeRequest request);

}
