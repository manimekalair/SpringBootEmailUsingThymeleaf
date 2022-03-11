package com.mail.thymeleaf.service;

import org.springframework.stereotype.Service;

@Service
public interface EmailTemplateService {
	
	String getEmployeeBodyTemplate(Long id);

}
