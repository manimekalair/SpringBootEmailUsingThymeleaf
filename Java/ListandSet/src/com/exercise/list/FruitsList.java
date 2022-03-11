package com.exercise.list;

import java.util.ArrayList;
import java.util.List;

public class FruitsList {
	public static void main(String[] args) {
		List<String> fruits=new ArrayList<String>();
		fruits.add("Apple");
		fruits.add("Orange");
		fruits.add("Banana");
		fruits.add("Mango");
		fruits.add("JackFruit");
		fruits.add("Strawberry");
		fruits.add("Pineapple");
		fruits.add("Kiwi");
		fruits.add("Lemon");
		fruits.add("Pomegranate");
		System.out.println("-----------------------------");
		System.out.println("Fruit List");
		System.out.println("-----------------------------");
		for (String fruit : fruits) {
			
			System.out.println(fruit);
		}
	}
}
