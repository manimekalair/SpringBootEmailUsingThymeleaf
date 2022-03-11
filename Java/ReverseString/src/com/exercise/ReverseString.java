package com.exercise;

public class ReverseString {
	public static void main(String[] args) {
		
		String name="Manimekalai";
		String str = "";
		char ch;
		System.out.print("Before Reverse String:   ");
		System.out.println(name);
		
		for(int i=0;i<name.length();i++) {
			ch=name.charAt(i);
			str=ch+str;
		}
		System.out.println(" ");
		System.out.print("After Reverse String:    ");
		System.out.println(str);
		
	}
}
