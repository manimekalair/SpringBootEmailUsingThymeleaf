package com.exercise;

public class Human {

	public static void main(String[] args) {
		
		Student student=new Student();
		student.setName("kalai");
		student.setAge(20);
		student.setMobileNo("9025037207");
		student.setEmailId("rmmekalai.205@gmail.com");
		student.setAddress("Thiruvaiayaru");
		System.out.println(student);
	}
}
	class Student extends Human{
		 
		String name;
		Integer age;
		String mobileNo;
		String emailId;
		String address;
		public void setName(String name) {
			this.name = name;
		}
		public void setAge(Integer age) {
			this.age = age;
		}
		public void setMobileNo(String mobileNo) {
			this.mobileNo = mobileNo;
		}
		public void setEmailId(String emailId) {
			this.emailId = emailId;
		}
		public void setAddress(String address) {
			this.address = address;
		}
		@Override
		public String toString() {
			return "Student [name=" + name + ", age=" + age + ", mobileNo=" + mobileNo + ", emailId=" + emailId
					+ ", address=" + address + "]";
		}
		
		
	}
	

