package com.exercise.duplicatestring;

public class DuplicateString {

	public static void main(String[] args) {
		String name="manimekalai";
		int count;
		char ch[]=name.toCharArray();
		System.out.println("Original Name:" + name);
		System.out.println("Duplicate Strings are:");
		for(int i=0;i<name.length(); i++) {
			count=1;
			for(int j=i+1;j<name.length();j++) {
				if(ch[i] == ch[j] && ch[i] != ' ') 
                {  
                    count++;  
                    ch[j] = '0';  
                }  
            }  
            if(count > 1 && ch[i] != '0')  
                System.out.println(ch[i]);  
        }  
	}
}
