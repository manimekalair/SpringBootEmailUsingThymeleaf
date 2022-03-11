package com.reset.password.controller;

import javax.mail.MessagingException;
import javax.transaction.SystemException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reset.password.entity.PasswordReset;
import com.reset.password.service.IPasswordResetService;

@RestController
@RequestMapping("/password")
public class PasswordResetController {
	@Autowired
	private IPasswordResetService resetService;
	
	@PostMapping("/sendmail")
	public String send(@RequestBody PasswordReset mailRequest,Model model) throws MessagingException, SystemException {
		
		resetService.sendEmail(mailRequest);
		model.addAttribute("mail", new PasswordReset());
		return "Email Sent Successfully";
	}

	@PostMapping("/forgot")
	public String forgotPassword(@RequestParam String email) {

		String response = resetService.forgotPassword(email);

		if (!response.startsWith("Invalid")) {
			response = "http://localhost:2014/reset?token=" + response;
		}
		return response;
	}

	@PutMapping("/reset")
	public String resetPassword(@RequestParam String token,
			@RequestParam String password) {

		return resetService.resetPassword(token, password);
	}
}
