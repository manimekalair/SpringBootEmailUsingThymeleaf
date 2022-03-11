package com.reset.password.service;

import java.time.LocalDateTime;

import javax.mail.MessagingException;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Service;

import com.reset.password.entity.Employee;

@Service
public interface IEmployeeService {
	
	String generateToken();
	String resetPassword(String token,String password);
	boolean isTokenExpired(LocalDateTime tokenCreationDate);
	void sendEmail(Employee employee, HttpServletRequest request) throws MessagingException;

}
