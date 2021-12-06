package com.host.thymeleaf.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;

import com.host.thymeleaf.service.IEmployeeService;

@Controller
public class EmployeeController {
	
	@Autowired
	IEmployeeService service;
	
	@Autowired
	RestTemplate restTemplate;
	
	@RequestMapping("/view")
	public String index(Model model) {
		
		String url="http://localhost:1992/email/save";
		String result=restTemplate.getForObject(url, String.class);
		model.addAttribute("listEmployees", service.listAll());
		
		return "emailnotification.html";
	}

}
