package com.mail.thymeleaf.model;

import java.io.Serializable;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EmailResponse implements Serializable{/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private Status status;

}
