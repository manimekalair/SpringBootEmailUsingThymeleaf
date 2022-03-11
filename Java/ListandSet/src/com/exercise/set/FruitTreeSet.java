package com.exercise.set;

import java.util.Set;
import java.util.TreeSet;

public class FruitTreeSet {
	public static void main(String[] args) {
	Set<String> fruits=new TreeSet<String>();
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
	System.out.println("Fruit TreeSet");
	System.out.println("-----------------------------");
	for (String fruit : fruits) {
		System.out.println(fruit);
	}
	}
}
