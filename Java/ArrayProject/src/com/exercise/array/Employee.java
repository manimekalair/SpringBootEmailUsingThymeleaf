package com.exercise.array;

class Human {
	
	private String name;
	private Integer age;
	private String mobileNo;
	private String emailId;
	private String address;
	
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
		return "[name=" + name + ", age=" + age + ", mobileNo=" + mobileNo + ", emailId=" + emailId + ", address="
				+ address + "]";
	}
}
public class Employee extends Human {
	
	private Integer id;
	private Double salary;
	private String dob;
	private String designation;
	private String department;

	public void setId(Integer id) {
		this.id = id;
	}

	public void setSalary(Double salary) {
		this.salary = salary;
	}

	public void setDob(String dob) {
		this.dob = dob;
	}

	public void setDesignation(String designation) {
		this.designation = designation;
	}

	public void setDepartment(String department) {
		this.department = department;
	}
	public static void main(String[] args) {
				
		Employee[] employees=new Employee[5];
		
		
		 employees[0]=new Employee();
		 employees[0].id=101;
		 employees[0].salary=25000.30;
		 employees[0].dob="22";
		 employees[0].designation="mechanic";
		 employees[0].department="ITI";
		 employees[0].setName("Kalai");
		 employees[0].setAge(25);
		 employees[0].setMobileNo("9025037207");
		 employees[0].setEmailId("Kalai.205@gmail.com");
		 employees[0].setAddress("Thiruvaiyaru");
		 
		 employees[1]=new Employee();
		 employees[1].id=102;
		 employees[1].salary=25000.00;
		 employees[1].dob="25";
		 employees[1].designation="mechanic";
		 employees[1].department="AC";
		 employees[1].setName("Mani");
		 employees[1].setAge(20);
		 employees[1].setMobileNo("4578963212");
		 employees[1].setEmailId("mani.53@gmail.com");
		 employees[1].setAddress("Thanjavur");
		
		 employees[2]=new Employee();
		 employees[2].id=103;
		 employees[2].salary=450.30;
		 employees[2].dob="24";
		 employees[2].designation="mechanic";
		 employees[2].department="Plumber";
		 employees[2].setName("Manimekalai");
		 employees[2].setAge(29);
		 employees[2].setMobileNo("567894123");
		 employees[2].setEmailId("mekalai.30@gmail.com");
		 employees[2].setAddress("Kumbakonam");
		 
		 employees[3]=new Employee();
		 employees[3].id=104;
		 employees[3].salary=5000.80;
		 employees[3].dob="29";
		 employees[3].designation="manager";
		 employees[3].department="ITI";
		 employees[3].setName("Gopal");
		 employees[3].setAge(30);
		 employees[3].setMobileNo("8489786349");
		 employees[3].setEmailId("gopal.20@gmail.com");
		 employees[3].setAddress("Trichy");
		 
		 employees[4]=new Employee();
		 employees[4].id=105;
		 employees[4].salary=45600.3;
		 employees[4].dob="20";
		 employees[4].designation="service";
		 employees[4].department="maintanence";
		 employees[4].setName("Rajagopal");
		 employees[4].setAge(35);
		 employees[4].setMobileNo("9751731710");
		 employees[4].setEmailId("rajagopal.205@gmail.com");
		 employees[4].setAddress("Chennai");
		 
		 for(int i=0;i<employees.length;i++) {
						System.out.println("Employee" + i + employees[i]);
						
				} 
		}

	@Override
	public String toString() {
		return " [id=" + id + ", salary=" + salary + ", dob=" + dob + ", designation=" + designation
				+ ", department=" + department + ", toString=" + super.toString() + "]";
	}
}
