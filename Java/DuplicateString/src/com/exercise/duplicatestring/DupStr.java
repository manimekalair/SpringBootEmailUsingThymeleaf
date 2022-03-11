package com.exercise.duplicatestring;

public class DupStr {
	public static void main(String[] args) {
	String str="manimekalai";
    String duplicates = "";

    for (int i = 0; i < str.length() - 1; i++) {
        for (int j = i + 1; j < str.length(); j++)

        {
            if (str.charAt(i) == str.charAt(j)) {

                if (!duplicates.contains(String.valueOf(str.charAt(j)))) {
                    duplicates += str.charAt(j);
                    break;
                }

            }
        }
    
    }
    System.out.println(duplicates);
	} 
}
