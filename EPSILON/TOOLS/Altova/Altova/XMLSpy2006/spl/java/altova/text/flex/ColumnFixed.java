[call GenerateFileHeader("ColumnFixed.java")]
package com.altova.text.flex;

public class ColumnFixed {
	public Command next;
	public int width;
	public char fillChar;
	public int alignment;
	public String name;

	public ColumnFixed(Command next, int width, char fillChar, int alignment, String name) {
		this.next = next;
		this.width = width;
		this.fillChar = fillChar;
		this.alignment = alignment;
		this.name = name;
	}
}
