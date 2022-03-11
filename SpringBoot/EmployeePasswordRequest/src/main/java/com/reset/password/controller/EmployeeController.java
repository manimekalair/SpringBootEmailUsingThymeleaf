package com.reset.password.controller;

import javax.mail.MessagingException;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reset.password.entity.Employee;
import com.reset.password.repo.EmployeeRepository;
import com.reset.password.service.IEmployeeService;

@RestController
@RequestMapping("/user")
public class EmployeeController {
	@Autowired
	private IEmployeeService employeeService;
	
	@PostMapping("/resetlink")
	public String sendLink(@RequestBody Employee employee,Model model,HttpServletRequest request) throws MessagingException {
		employeeService.sendEmail(employee, request);
		model.addAttribute(model);
		return "Email Sent";
	}
	
	@PutMapping("/resetpassword")
	public String resetPassword(@RequestParam String token, @RequestParam String password) {
		return employeeService.resetPassword(token, password);
	}

}
