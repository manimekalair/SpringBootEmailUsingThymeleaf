package com.example.api.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MessageController {
	
	@RequestMapping("/manimekalai")
	public String hello() {
		return "Welcome" + "         |||||||||||||||"     
				+ "Name: MANIMEKALAI R" + "        |||||||||||||||     "
				+ "Mobile No: 9025037207" + "        |||||||||||||||     "
				+ "Mail: rmmekalai.205@gmail.com" + "        |||||||||||||||     "
				+ "Address: Thiruvaiyaru";
	}

}
