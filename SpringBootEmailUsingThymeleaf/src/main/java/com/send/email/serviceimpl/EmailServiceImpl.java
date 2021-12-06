package com.send.email.serviceimpl;

import java.nio.charset.StandardCharsets;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring5.SpringTemplateEngine;

import com.send.email.model.Email;
import com.send.email.service.IEmailService;

@Service
public class EmailServiceImpl implements IEmailService {

	@Autowired
	private SpringTemplateEngine templateEngine;
	
	@Autowired
	JavaMailSender javaMailSender;
	
	 public String sendMail(Email email) throws MessagingException {
		 
		 System.out.println("Loading");
		 
		 MimeMessage message = javaMailSender.createMimeMessage();
	        MimeMessageHelper helper = new MimeMessageHelper(message,
	                MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED,
	                StandardCharsets.UTF_8.name());

	        Context context = new Context();  
	        context.setVariable("taskName",email.getTaskName());
	        context.setVariable("taskDesc",email.getTaskDescription());
	        String html = templateEngine.process("tasknotification", context);

	        helper.setTo(email.getEmailId());
	        helper.setText(html, true);
	        helper.setSubject(email.getTaskDescription());
	        helper.setFrom(email.getSender());

	        javaMailSender.send(message);
	        System.out.println("Sending.....");
	        System.out.println("sent");
			return "Send";
			
	    }

	@Override
	public void doTask() {
		
		String url="http://localhost:1991/task/save";
		RestTemplate restTemplate=new RestTemplate();
		ResponseEntity<String> result=restTemplate.postForEntity(url, restTemplate, String.class);
		if (result!=null) {
			
			System.out.println(result);
		}

	}

}
