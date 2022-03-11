package com.reset.password.service;

import java.time.LocalDateTime;

import javax.mail.MessagingException;
import javax.transaction.SystemException;

import org.springframework.stereotype.Service;

import com.reset.password.entity.PasswordReset;

@Service
public interface IPasswordResetService {
	void sendEmail(PasswordReset mailRequest) throws MessagingException, SystemException;
	String forgotPassword(String email);
	String resetPassword(String token, String password);
	String generateToken();
	boolean isTokenExpired(final LocalDateTime tokenCreationDate);
}
