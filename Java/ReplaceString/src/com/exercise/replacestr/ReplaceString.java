package com.exercise.replacestr;

public class ReplaceString {

	public static void main(String[] args) {
		String str="Chennai around 750 km distance from Chennai";
		System.out.println("Original String: " + str);
		System.out.println(" ");
		String rs=str.replace("Chennai", "Kanyakumari");
		String rs1=rs.replaceFirst("Kanyakumari", "Chennai");
		int count=0;
		for(int i=0;i<rs1.length();i++) {
			if (rs1.charAt(i)!=' ') {
				count++;
			}
		}
		System.out.println("After Replace String: " +rs1);
		System.out.println(" ");
		System.out.println("The Count Character from after replace string: " + count);
	}

}
