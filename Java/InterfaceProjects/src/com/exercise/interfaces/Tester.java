package com.exercise.interfaces;

public class Tester implements IEmployee {

	String userName;
	String password;
	String testerName;
	String testerAge;
	String testSalary;
	String testerDesignation;
	
	public void setUserName(String userName) {
		this.userName = userName;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public void setTesterName(String testerName) {
		this.testerName = testerName;
	}

	public void setTesterAge(String testerAge) {
		this.testerAge = testerAge;
	}

	public void setTestSalary(String testSalary) {
		this.testSalary = testSalary;
	}

	public void setTesterDesignation(String testerDesignation) {
		this.testerDesignation = testerDesignation;
	}

	@Override
	public void login() {
		setUserName("Mazhilini");
		setPassword("54321");
		System.out.println( "Enter UserName:"+ userName);
		System.out.println( "Enter UserPassword:"+ password);
		System.out.println("Tester Login Successfully..........!");
		}

	@Override
	public void work() {
		System.out.println("Tester Working..........!");
		setTesterDesignation("Manual Testing");
}

	@Override
	public String report() {
		return "Tester Reporting....!";
	}

	public static void main(String[] args) {
		
	    System.out.println("...............Tester Details...............!");
	    Tester tester=new Tester();
	    tester.setTesterName("Magzhlini");
	    tester.setTesterAge("25");
	    tester.setTestSalary("10000");
	    System.out.println("Enter the Tester Name:" +tester.testerName);
	    System.out.println("Enter the Tester Age:" +tester.testerAge);
	    System.out.println("Enter the Tester Salary:" +tester.testSalary);
	    tester.login();
	    tester.work();
	    System.out.println("Tester Role:" + tester.testerDesignation);
	    
		}
}
