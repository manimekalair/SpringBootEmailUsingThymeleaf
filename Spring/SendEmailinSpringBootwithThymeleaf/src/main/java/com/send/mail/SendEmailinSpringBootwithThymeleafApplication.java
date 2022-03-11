package com.send.mail;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.thymeleaf.ThymeleafAutoConfiguration;

@SpringBootApplication(exclude = {ThymeleafAutoConfiguration.class})
public class SendEmailinSpringBootwithThymeleafApplication {

	public static void main(String[] args) {
		SpringApplication.run(SendEmailinSpringBootwithThymeleafApplication.class, args);
	}

}