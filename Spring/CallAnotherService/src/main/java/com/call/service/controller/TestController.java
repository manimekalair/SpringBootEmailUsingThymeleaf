package com.call.service.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.call.service.model.TestOne;
import com.call.service.model.TestTwo;
import com.call.service.service.TestService;

@RestController
@RequestMapping("/test")
public class TestController {
	
	@Autowired
	TestService service;
	

	@PostMapping("/one")
	public Boolean createOne(@RequestBody TestOne one) {
		
		System.out.println("loading");
		System.out.println("sent to test two");
		System.out.println(one);
		if (one.getId()!=null) {
			return true;
		}else {
			return false;
		}
	}

	
	@PostMapping("/two")
	public TestTwo createTwo(@RequestBody TestOne one) {
		
		String url="http://localhost:1992/test/one";
		RestTemplate restTemplate=new RestTemplate();
		TestTwo two=restTemplate.postForObject(url, one, TestTwo.class);
		return two;
	}

}
