package com.exercise.interfaces;

public class Developer implements IEmployee {

	String userName;
	String password;
	String devName;
	String devAge;
	String devSalary;
	String devDesignation;
	
	public void setUserName(String userName) {
		this.userName = userName;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public void setDevName(String devName) {
		this.devName = devName;
	}

	public void setDevAge(String devAge) {
		this.devAge = devAge;
	}

	public void setDevSalary(String devSalary) {
		this.devSalary = devSalary;
	}

	public void setDevDesignation(String devDesignation) {
		this.devDesignation = devDesignation;
	}

	@Override
	public void login() {
		
		setUserName("Kalai");
		setPassword("12345");
		System.out.println( "Enter UserName:"+ userName);
		System.out.println( "Enter UserPassword:"+ password);
		System.out.println("Developer Login Successfully..........!");
	}

	@Override
	public void work() {
		System.out.println("Developer Working..........!");
		setDevDesignation("BackEndDeveloper");
	}

	@Override
	public String report() {
		
		return "Developer Reporting....!";
	}
	
	public static void main(String[] args) {
		
		System.out.println("...............Developer Details...............");
	    Developer developer=new Developer();
		developer.setDevName("Manimekalai");
		developer.setDevAge("20");
		developer.setDevSalary("2000");
	    System.out.println("Enter the Name:" +developer.devName);
	    System.out.println("Enter the Age:" +developer.devAge);
	    System.out.println("Enter the Salary:" +developer.devSalary);
	    developer.login();
	    developer.work();
	    System.out.println("Developer Role:" + developer.devDesignation);
	    }
}

