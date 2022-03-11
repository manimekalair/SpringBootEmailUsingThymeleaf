[call GenerateFileHeader("SplitAtDelimiter.java")]
package com.altova.text.flex;

public class SplitAtDelimiter implements Splitter {
	protected String delimiter;
	protected boolean reverse;
	
	public SplitAtDelimiter(String delimiter, boolean reverse) {
		this.delimiter = delimiter;
		this.reverse = reverse;
	}

	public SplitAtDelimiter(String delimiter) {
		this(delimiter, false);
	}
	
	public Range split(Range range) {
		Range result = new Range(range);
		
		if (delimiter.length() == 0) {
			range.start = range.end;
			return result;
		}
		
		result.end = range.start;

		int pos;
		if (reverse) {
			pos = range.toString().lastIndexOf(delimiter);
		}
		else {
			pos = range.toString().indexOf(delimiter);
		}
		if (pos != -1) {
			result.end = range.start + pos;
			range.start = result.end + delimiter.length();
		} else {
			result.end = range.end;
			range.start = result.end;
		}
		return result;
	}
	
	public void appendDelimiter(Appender output) {
		output.appendText(delimiter);
	}
}
