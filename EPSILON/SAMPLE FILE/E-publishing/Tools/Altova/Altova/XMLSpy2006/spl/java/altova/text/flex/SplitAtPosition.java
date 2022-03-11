[call GenerateFileHeader("SplitAtPosition.java")]
package com.altova.text.flex;

public class SplitAtPosition implements Splitter {
	private int position;
	
	public SplitAtPosition(int pos) {
		this.position = pos;
	}
	
	public Range split(Range range) {
		Range result;
		if (position < 0) {
			// from right
			int n = Math.min(-position, range.length());
			result = new Range(range.getContent(), range.end - n, range.end);
		}
		else {
			// from left
			result = new Range(range.getContent(), range.start, range.start + Math.min(position, range.length()));
		}
		range.start = result.end;
		return result;
	}
	
	public void appendDelimiter(Appender output) {}
}
