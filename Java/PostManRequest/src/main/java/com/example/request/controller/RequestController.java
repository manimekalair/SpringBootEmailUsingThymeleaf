package com.example.request.controller;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/request/api/v1")
public class RequestController {

	@PostMapping("/data")
	public String postData() {
		return "User Data Send";
	}
	@GetMapping("/data")
	public String getData() {
		return "User Data View";
	}
	@PutMapping("/data")
	public String putData() {
		return "User Data Updated";
	}
	@DeleteMapping("/data")
	public String deleteData() {
		return "User Data Deleted";
	}
}
