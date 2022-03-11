package com.exercise.duplicatestring;

public class Duplicate {
	public static void main(String[] args) {
	String name="manimekalai";
	char[] duplicate=name.toCharArray();
	System.out.println("Original Name:" + name);
	System.out.println("Duplicate Strings are:");
	for(int i=0;i<name.length();i++) {
		//System.out.print("\n i value is " + duplicate[i]);
		for(int j=i+1;j<name.length();j++) {
			//System.out.print(" \n j value is" + duplicate[j]);
			if (duplicate[i]==duplicate[j]) {
				System.out.println(duplicate[j]);
				break;
			}
		}
	}
	
  }
}
