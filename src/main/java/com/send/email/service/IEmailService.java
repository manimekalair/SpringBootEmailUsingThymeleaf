package com.send.email.service;

import javax.mail.MessagingException;

import org.springframework.stereotype.Service;

import com.send.email.model.Email;

@Service
public interface IEmailService {
	String sendMail(Email email) throws MessagingException; 
	void doTask();

}
