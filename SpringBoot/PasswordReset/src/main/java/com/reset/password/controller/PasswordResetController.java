package com.reset.password.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reset.password.entity.PasswordReset;
import com.reset.password.service.IPasswordResetService;

@RestController
@RequestMapping("/password")
public class PasswordResetController {
	
	@Autowired
	IPasswordResetService resetService;
	
	@PostMapping("/reset")
	public String save(@RequestBody PasswordReset reset) {
		resetService.sendRequest(reset);
		return "Stored";
		
	}
}
