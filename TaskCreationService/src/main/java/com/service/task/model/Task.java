package com.service.task.model;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table
@Entity(name="task")
public class Task {
	
	@Id()
	private Long id;
	private String taskName;
	private String taskDescription;
	private String emailId;

}
