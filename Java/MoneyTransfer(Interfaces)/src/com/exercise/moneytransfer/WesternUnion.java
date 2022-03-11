package com.exercise.moneytransfer;

public class WesternUnion implements PaymentGateway {
	@Override
	public void connect() {
		System.out.println("WesternUnion is Connected");
	}

	@Override
	public void verify() {
		System.out.println("WesternUnion is Verified");
	}

	@Override
	public void transfer(Double amount) {
		System.out.println("  Amount is Transferred to Receiver.....");
	}

	@Override
	public void receive(Double amount) {
		System.out.println("  Amount Is Received from Sender....");
		
		
	}

}
