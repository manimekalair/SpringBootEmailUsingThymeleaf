package com.reset.password.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "passwordreset")
@Entity
@NamedQuery(name = "PasswordReset.findByEmailId",
query = "select p from PasswordReset p where p.empEmailId = ?1")
public class PasswordReset {
	
	@Id()
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Long id;
	private String empEmailId;
	private Boolean send;

}
