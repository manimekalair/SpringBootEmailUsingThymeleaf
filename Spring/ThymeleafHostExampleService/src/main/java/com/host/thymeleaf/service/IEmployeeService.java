package com.host.thymeleaf.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.host.thymeleaf.model.Employee;


@Service
public interface IEmployeeService {
	
	public List<Employee> listAll();

}
