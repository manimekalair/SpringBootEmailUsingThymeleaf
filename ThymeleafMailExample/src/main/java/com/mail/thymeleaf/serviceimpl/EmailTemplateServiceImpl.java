package com.mail.thymeleaf.serviceimpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import com.mail.thymeleaf.service.EmailTemplateService;

@Service
public class EmailTemplateServiceImpl implements EmailTemplateService {

	
	@Autowired
	private TemplateEngine templateEngine;
	
	@Override
	public String getEmployeeBodyTemplate(Long id) {
		
		Context ctx=new Context();
		ctx.setVariable("empId", id);
		ctx.setVariable("empName",ctx);
		ctx.setVariable("empAddress",ctx);
		
		return templateEngine.process("emailnotification", ctx);
	}

}
