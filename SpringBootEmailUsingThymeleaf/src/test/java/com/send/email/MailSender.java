package com.send.email;

import static org.junit.jupiter.api.Assertions.*;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
 
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.MimeMessageHelper;

import com.send.email.model.Email;
import com.send.email.service.IEmailService;
import com.send.email.serviceimpl.EmailServiceImpl;

class MailSender { 
	

	@Test
	void test() throws MessagingException {
		EmailServiceImpl service=new EmailServiceImpl();
		Email email=Email.builder()
		.taskName("Login Page")
		.taskDescription("Creating a Login Page")
		.emailId("dhamodaran@gmail.com")
		.id(1L)
		.build();
		service.sendMail(email);
		//assertEquals("Email sent Successfully", service.sendMail(email)); 
		;
		 
	}

}
