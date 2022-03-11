package com.user.detail.entity;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.Data;

@Data
@Entity
@Table
public class User {
	
	@Id()
	private Long id;
	private String firstName;
	private String lastName;
	private String password;
	private String email;
	private String phoneNo;
}
