package com.send.email.controller;

import javax.mail.MessagingException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.send.email.model.Email;
import com.send.email.serviceimpl.EmailServiceImpl;

@RestController
@RequestMapping("/email")
public class EmailController {
	
	@Autowired
	EmailServiceImpl service;
	
	@PostMapping("/send")
	public Boolean sendMail() {
		return true;
	}
	
	@PostMapping("mail")
	public String sendMail(@RequestBody Email email) throws MessagingException {
		
		service.sendMail(email);
		return "Email sent Successfully";
	}
	

}
