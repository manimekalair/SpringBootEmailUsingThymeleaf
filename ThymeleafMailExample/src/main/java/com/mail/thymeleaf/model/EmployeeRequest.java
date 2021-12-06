package com.mail.thymeleaf.model;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name="employeetb")
public class EmployeeRequest {
	
	@Id()
	private Long empId;
	private String empName;
	private String empAddress;

}
