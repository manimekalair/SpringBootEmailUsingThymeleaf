[call GenerateFileHeader("SplitLines.java")]
package com.altova.text.flex;

public class SplitLines implements Splitter {
	private int nLines;
	private boolean removeDelimiter;
	
	public SplitLines(int nLines, boolean removeDelimiter) {
		this.nLines = nLines;
		this.removeDelimiter = removeDelimiter;
	}
	public SplitLines(int nLines) {
		this(nLines,  false);
	}
	
	public Range split(Range range) {
		String content = range.getContent();
		Range result = new Range(content, range.start, range.start);
		int p = 0;
		
		if (nLines >= 0) {
			// count from top
			p = result.end;
			for (int nLinesLeft = nLines; nLinesLeft > 0 && p != range.end; ++p) {
				if (content.charAt(p) == CR || content.charAt(p) == LF) {
					if (content.charAt(p) == CR && p != range.end-1 && content.charAt(p+1) == LF)
						++p;
					--nLinesLeft;
				}
			}
		} else {
			// count from bottom
			result.end = range.end;
			p = result.end;
			int nLinesLeft = -nLines;
			if (result.isValid() && (content.charAt(p-1) == CR || content.charAt(p-1) == LF))
				nLinesLeft++;

			for (; p > range.start; --p)
			{
				if (content.charAt(p-1) == CR || content.charAt(p-1) == LF)
				{
					if (--nLinesLeft == 0)
						break;
					if (nLinesLeft > 0 && content.charAt(p-1) == LF && p > range.start+1 && content.charAt(p-2) == CR)
						--p;
				}
			}
		}
		result.end = p;
		range.start = result.end;
		if (removeDelimiter) {
			if (result.endsWith(LF))
				--result.end;
			if (result.endsWith(CR))
				--result.end;
		}
		return result;
	}
	
	public void appendDelimiter(Appender output) {
		if (removeDelimiter)
			output.appendText("\\r\\n");
	}
}
