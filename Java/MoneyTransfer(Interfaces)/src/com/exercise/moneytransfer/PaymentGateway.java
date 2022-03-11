package com.exercise.moneytransfer;

public interface PaymentGateway {

	public void connect();
	public void verify();
	public void transfer(Double amount);
	public void receive(Double amount);
}
