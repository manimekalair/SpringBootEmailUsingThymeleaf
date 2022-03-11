package com.reset.password.serviceimpl;

import java.time.*;
import java.util.*;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import javax.transaction.SystemException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring5.SpringTemplateEngine;

import com.reset.password.entity.PasswordReset;
import com.reset.password.repo.PasswordResetRepository;
import com.reset.password.service.IPasswordResetService;
@Service
public class PasswordResetServiceImpl implements IPasswordResetService {
	
	private static final long EXPIRE_TOKEN_AFTER_MINUTES = 30;
	
	@Autowired
	private PasswordResetRepository resetRepository;
	
	@Autowired
	private JavaMailSender javaMailSender;
	
	@Autowired
    private SpringTemplateEngine templateEngine;

	@Override
	public void sendEmail(PasswordReset mailRequest) throws MessagingException, SystemException {
		String email = mailRequest.getEmail();
		Optional<PasswordReset> passwordOptional = Optional
				.ofNullable(resetRepository.findByEmail(email));
		if (passwordOptional.isPresent()) {
			passwordOptional.get();
			System.out.println("EmpEmailId  " + email + "  Already Exists" );
			}
		else {
				resetRepository.save(mailRequest);
				MimeMessage mimeMessage = javaMailSender.createMimeMessage();
		        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage);
				Context context=new Context();
				context.setVariable("mail", mailRequest);
				String html=templateEngine.process("PasswordReset", context);
				//helper.setSubject(mailRequest.getSubject());
				helper.setText(html,true);
				helper.setTo(mailRequest.getEmail());
				javaMailSender.send(mimeMessage);
		}
	}
	@Override
	public String forgotPassword(String email) {

		Optional<PasswordReset> passwordOptional = Optional
				.ofNullable(resetRepository.findByEmail(email));

		if (!passwordOptional.isPresent()) {
			return "Invalid email id.";
		}

		PasswordReset reset = passwordOptional.get();
		reset.setToken(generateToken());
		reset.setTokenCreationDate(LocalDateTime.now());

		reset = resetRepository.save(reset);

		return reset.getToken();
	}

	@Override
	public String resetPassword(String token, String password) {
		Optional<PasswordReset> passwordOptional = Optional
				.ofNullable(resetRepository.findByToken(token));

		if (!passwordOptional.isPresent()) {
			return "Invalid token.";
		}

		LocalDateTime tokenCreationDate = passwordOptional.get().getTokenCreationDate();

		if (isTokenExpired(tokenCreationDate)) {
			return "Token expired.";

		}

		PasswordReset reset = passwordOptional.get();

		reset.setPassword(password);
		reset.setToken(null);
		reset.setTokenCreationDate(null);

		resetRepository.save(reset);

		return "Your password successfully updated.";
	}

	@Override
	public String generateToken() {
		StringBuilder token = new StringBuilder();

		return token.append(UUID.randomUUID().toString())
				.append(UUID.randomUUID().toString()).toString();
	}

	@Override
	public boolean isTokenExpired(LocalDateTime tokenCreationDate) {
		LocalDateTime now = LocalDateTime.now();
		Duration diff = Duration.between(tokenCreationDate, now);

		return diff.toMinutes() >= EXPIRE_TOKEN_AFTER_MINUTES;
	}
}
