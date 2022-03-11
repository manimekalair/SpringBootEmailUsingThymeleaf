package com.mail.thymeleaf.model;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.util.Assert;

public class EmployeeValidator {
	
	public static final Pattern VALID_ID_ADDRESS_REGEX = Pattern.compile("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$",
			Pattern.CASE_INSENSITIVE);
	
	public static void validateSendEmployeeRequest(EmployeeRequest request) throws BadRequestException {
		
		
		
		Assert.notNull(request.getEmpName(),"Employee id address is required.");
		Boolean isValidId=validateIdAddress(request.getEmpName());
		
		if (!isValidId) {
			throw new BadRequestException("INVALID_EMAIL_FORMAT", "Found invalid email address");
		}
	}

	private static Boolean validateIdAddress(String emailStr) {
		
		Matcher matcher=VALID_ID_ADDRESS_REGEX.matcher(emailStr);
		return matcher.find();
	}

}
