package com.send.email;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.thymeleaf.ThymeleafAutoConfiguration;

@SpringBootApplication(exclude = {ThymeleafAutoConfiguration.class})
public class SpringBootEmailUsingThymeleafApplication {

	public static void main(String[] args) {
		SpringApplication.run(SpringBootEmailUsingThymeleafApplication.class, args);
	}

}
