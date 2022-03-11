package com.reset.password.serviceimpl;

import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring5.SpringTemplateEngine;

import com.reset.password.entity.Employee;
import com.reset.password.entity.Utility;
import com.reset.password.repo.EmployeeRepository;
import com.reset.password.service.IEmployeeService;

@Service
public class EmployeeServiceImpl implements IEmployeeService {
	
	private static final long EXPIRE_TOKEN_AFTER_HOURS=24;
	
	@Autowired
	private JavaMailSender javaMailSender;
	@Autowired
	private SpringTemplateEngine springTemplateEngine;
	@Autowired
	private EmployeeRepository employeeRepository;

	@Override
	public void sendEmail(Employee employee, HttpServletRequest request) throws MessagingException {
		String email=employee.getEmail();
		Optional<Employee> optEmployee=employeeRepository.findByEmail(email);
		if (optEmployee.isPresent()) {
			System.out.println("EmpEmailId  " + email + "  Already Exists" );
		} else {
			employee.setToken(generateToken());
			employee.setTokenCreationDate(LocalDateTime.now());
			String link=Utility.getSiteURL(request) + "/resetpassword?token=" + employee.getToken();
			employeeRepository.save(employee);
			
			MimeMessage mimeMessage = javaMailSender.createMimeMessage();
	        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage);
			Context context=new Context();
			context.setVariable("mail", link);
			String html=springTemplateEngine.process("PasswordReset", context);
			helper.setText(html,true);
			helper.setTo(employee.getEmail());
			helper.setText("To reset your password, click the link below:\n" + link);
			javaMailSender.send(mimeMessage);
		}
	}
	@Override
	public boolean isTokenExpired(LocalDateTime tokenCreationDate) {
		LocalDateTime now = LocalDateTime.now();
		Duration diff = Duration.between(tokenCreationDate, now);
		return diff.toHours()>= EXPIRE_TOKEN_AFTER_HOURS;
	}
	@Override
	public String generateToken() {
		StringBuilder token = new StringBuilder();

		return token.append(UUID.randomUUID().toString())
				.append(UUID.randomUUID().toString()).toString();
	}
	@Override
	public String resetPassword(String token, String password) {
		Optional<Employee> optEmployee=employeeRepository.findByToken(token);
		if (!optEmployee.isPresent()) {
			return "Invalid Token";
		}
		LocalDateTime tokenCreationDate=optEmployee.get().getTokenCreationDate();
		if (isTokenExpired(tokenCreationDate)) {
			return "Token Expired";
		}
		Employee employee=optEmployee.get();
		employee.setPassword(password);
		employee.setToken(token);
		employee.setTokenCreationDate(tokenCreationDate);
		
		employeeRepository.save(employee);
		return "Successfully Updated";
	}
}
