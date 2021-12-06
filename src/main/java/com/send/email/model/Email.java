package com.send.email.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Email {
	
	private Long id;
	private String sender;
	private String taskName;
	private String taskDescription;
	private String emailId;
}
