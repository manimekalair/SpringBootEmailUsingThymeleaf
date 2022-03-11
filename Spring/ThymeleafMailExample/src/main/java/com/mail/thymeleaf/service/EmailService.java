package com.mail.thymeleaf.service;

import org.springframework.stereotype.Service;

import com.mail.thymeleaf.model.EmailRequest;
import com.mail.thymeleaf.model.EmailResponse;



@Service
public interface EmailService {
	
	EmailResponse sendEmail(EmailRequest emailRequest);

}
