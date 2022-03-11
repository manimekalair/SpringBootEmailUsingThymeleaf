[call GenerateFileHeader("SplitAtDelimiterLineBasedMultiple.java")]
package com.altova.text.flex;

public class SplitAtDelimiterLineBasedMultiple extends SplitAtDelimiterLineBased {
	public SplitAtDelimiterLineBasedMultiple(String delimiter) {
		super(delimiter, false);
	}
	
	public Range split(Range range) {
		SplitLines splitAtFirstLine = new SplitLines(1);
		Range firstLine = splitAtFirstLine.split(range);
		Range result = super.split(range);
		result.start = firstLine.start;
		return result;
	}
	
	public void appendDelimiter(Appender output) {}
}
