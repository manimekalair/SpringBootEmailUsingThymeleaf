package com.user.detail.service;

import org.springframework.stereotype.Service;

import com.user.detail.entity.User;

@Service
public interface IUserService {

	User saveUser(User user);
	User getUser(Long id);
}
