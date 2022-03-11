package com.exercise.moneytransfer;

public class Person {

	PaymentGateway paymentGateway;
	public Double amount=5000.89;
	
	public static void main(String[] args) {
	
		Person person=new Person();
		
		System.out.println("PayPal Loading........................!");
		person.paymentGateway=new PayPal();
		person.paymentGateway.connect();
		person.paymentGateway.verify();
		person.paymentGateway.transfer(person.amount);
		person.paymentGateway.receive(person.amount);
		
		System.out.println("Western Union Loading........................!");
		person.paymentGateway=new WesternUnion();
		person.paymentGateway.connect();
		person.paymentGateway.verify();
		person.paymentGateway.transfer(person.amount);
		person.paymentGateway.receive(person.amount);
	}
}
