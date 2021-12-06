package com.call.service.service;

import org.springframework.stereotype.Service;

import com.call.service.model.TestOne;

@Service
public interface TestService {
	
	TestOne saveOne(TestOne one);

}
