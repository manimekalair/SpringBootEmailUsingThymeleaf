package com.call.service.model;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name="testservicecallone")
public class TestOne {
	
	@Id()
	private Long id;
	private String name;
	private String address;

}
