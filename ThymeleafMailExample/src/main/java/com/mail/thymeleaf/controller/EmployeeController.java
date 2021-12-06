package com.mail.thymeleaf.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.mail.thymeleaf.model.BadRequestException;
import com.mail.thymeleaf.model.EmailRequest;
import com.mail.thymeleaf.model.EmployeeRequest;
import com.mail.thymeleaf.model.EmployeeResponse;
import com.mail.thymeleaf.model.EmployeeValidator;
import com.mail.thymeleaf.service.EmployeeService;
import com.mail.thymeleaf.service.IEmployeeService;
import org.apache.log4j.Logger;

@RestController
@RequestMapping("/email")
public class EmployeeController {
	
	private final String EMPLOYEE_ENDPOINTS_RUNNING = "Employee Email Service endpoints are running";

	final static Logger logger = Logger.getLogger(EmployeeController.class);
	
	@Autowired
	IEmployeeService service;
	
	@Autowired
	EmployeeService employeeService;
	
	@PostMapping("/save")
	public Boolean getEmployee(@RequestBody EmployeeRequest employee) {
		
		service.saveEmployee(employee);
		if(employee.getEmpId()!=null) {
			return true;
		}else {
			return false;
		}
	}
	
	@RequestMapping("/view")
	public String index(Model model) {
		model.addAttribute("listEmployees", service.listAll());
		return "emailnotification.html";
	}
	
	
	@GetMapping("/mail")
	public String plainRequest() {
		return EMPLOYEE_ENDPOINTS_RUNNING;
	}
	
	
	/**
	 * Send Email
	 * @throws BadRequestException 
	 *
	 */
	@PostMapping("/send")
	public @ResponseBody EmployeeResponse sendEmpEmail(
			@RequestBody EmailRequest emailRequest) throws BadRequestException {
		
		EmployeeValidator.validateSendEmployeeRequest(null);
				return employeeService.sendEmployeeEmail(null);
		
		

	}

}
