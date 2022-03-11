package com.demo.spring.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.demo.spring.model.User;
import com.demo.spring.model.User1;

@RestController
public class MySpringController {
	@RequestMapping("/hello")
	public User hello() {
		return new User("Kalai", 28, "Female");
	}
	
	@GetMapping("/user1")
	public User1 user1() {
		return new User1("Manimekalai", 29, "Female");
	}

}
