package com.reset.password;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

@SpringBootApplication(exclude= {SecurityAutoConfiguration.class})
public class PasswordResetApplication {

	public static void main(String[] args) {
		SpringApplication.run(PasswordResetApplication.class, args);
	}

}
