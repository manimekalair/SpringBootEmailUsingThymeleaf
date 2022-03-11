package com.mail.thymeleaf.model;

public class BadRequestException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	
	public BadRequestException(String statusMessage) {
		super(statusMessage);
	}
	public BadRequestException(String statusMessage, String endUserMessage) {
		// TODO Auto-generated constructor stub
	}

}
