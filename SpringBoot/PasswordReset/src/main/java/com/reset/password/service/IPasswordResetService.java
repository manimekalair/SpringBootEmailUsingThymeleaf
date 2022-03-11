package com.reset.password.service;

import org.springframework.stereotype.Service;

import com.reset.password.entity.PasswordReset;

@Service
public interface IPasswordResetService {
	public String sendRequest(PasswordReset reset);
	}
