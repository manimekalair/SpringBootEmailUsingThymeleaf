package com.demo.spring.model;

public class User {
	
	public String name;
	public int age;
	public String gender;
	public User(String name, int age, String gender) {
		this.name = name;
		this.age = age;
		this.gender = gender;
	}
	@Override
	public String toString() {
		return "{\"name\": \""+this.name+"\",\"age\": \""+this.age+"\",\"gender\": \""+this.gender+"\"}";
	}
	
}
