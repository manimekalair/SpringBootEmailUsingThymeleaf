package com.mail.thymeleaf;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication(exclude = {SecurityAutoConfiguration.class})
@ComponentScan(basePackages = {"com.mail"})
public class ThymeleafMailExampleApplication {

	public static void main(String[] args) {
		SpringApplication.run(ThymeleafMailExampleApplication.class, args);
	}

}
