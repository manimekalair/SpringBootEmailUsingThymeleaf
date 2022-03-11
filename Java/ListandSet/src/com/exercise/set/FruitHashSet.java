package com.exercise.set;

import java.util.HashSet;

public class FruitHashSet {
	public static void main(String[] args) {
		HashSet<String> fruits=new HashSet<String>();
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
		System.out.println("Fruit HashSet");
		System.out.println("-----------------------------");
		for (String fruit : fruits) {
			System.out.println(fruit);
		}
	}
}
