[call GenerateFileHeader("DocumentWriter.java")]
package com.altova.text.flex;

import com.altova.text.*;

public class DocumentWriter implements Appender {
	private ITextNode current;
	private StringBuffer content;
	
	public DocumentWriter(ITextNode tree, StringBuffer buff) {
		this.content = buff;
		this.current = tree;
	}
	
	public ITextNode getCurrentNode() {
		return current;
	}
	
	public void appendText(String text) {
		content.append(text);
	}
	
	public void appendText(StringBuffer text) {
		content.append(text.toString());
	}
}
