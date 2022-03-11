package com.mail.thymeleaf.serviceimpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.apache.log4j.Logger;

import com.mail.thymeleaf.model.EmailRequest;
import com.mail.thymeleaf.model.EmailResponse;
import com.mail.thymeleaf.model.EmployeeRequest;
import com.mail.thymeleaf.model.EmployeeResponse;
import com.mail.thymeleaf.model.Status;
import com.mail.thymeleaf.service.EmailService;
import com.mail.thymeleaf.service.EmailTemplateService;
import com.mail.thymeleaf.service.EmployeeService;

@Service
public class EmployeeServiceIm implements EmployeeService {

	
	@Autowired
	private EmailTemplateService mailTemplateService;

	@Autowired
	private EmailService emailService;

	final static Logger logger = Logger.getLogger(EmployeeServiceImpl.class);

	@Value("${employee.id.detail.email.subject}")
	private String employeeIdDetailsSubject;
	
	@Override
	public EmployeeResponse sendEmployeeEmail(EmployeeRequest request) {
		
		EmployeeResponse response=new EmployeeResponse();
		
		try {

			String bodyContent = mailTemplateService
					.getEmployeeBodyTemplate(request.getEmpId());
			EmailRequest emailRequest = new EmailRequest();
			// Set To email address. You can set multiple email addresses using comma
			// separated string.
			emailRequest.setTo(request.getEmpName() + ",");
			// Set email subject title.
			emailRequest.setSubject(employeeIdDetailsSubject);
			// Set body content using mail template service.
			emailRequest.setBodyContent(bodyContent);

			EmailResponse rs = emailService.sendEmail(emailRequest);
			response.setStatus(rs.getStatus());

		} catch (Exception e) {

			Status status = new Status();
			status.setStatusCode("ERROR");
			status.setStatusDescription("ERROR while sending email " + e.getMessage());
		}

		return response;
	}

}
