[call GenerateFileHeader("Splitter.java")]
package com.altova.text.flex;

public interface Splitter
{
	public static final char CR = '\\r';
	public static final char LF = '\\n';
	
	public Range split(Range r);
	public void appendDelimiter(Appender output);
}
