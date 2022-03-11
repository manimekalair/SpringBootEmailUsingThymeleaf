package com.call.service.serviceimpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.call.service.model.TestOne;
import com.call.service.repo.TestRepository;
import com.call.service.service.TestService;

@Service
public class TestServiceImpl implements TestService {

	@Autowired
	TestRepository repo;
	
	
	@Override
	public TestOne saveOne(TestOne one) {
		
		
		if(one.getId()!=null) {
			
			repo.save(one);
			
		}
		
		
		return one;
		
	}

}
