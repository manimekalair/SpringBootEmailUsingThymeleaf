[call GenerateFileHeader("ColumnDelimited.java")]
package com.altova.text.flex;

public class ColumnDelimited {
	public Command next;
	public String name;

	public ColumnDelimited(Command next, String name) {
		this.next = next;
		this.name = name;
	}
}
