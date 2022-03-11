[call GenerateFileHeader("AlwaysEmptyTextNodeList.java")]
package com.altova.text;

public class AlwaysEmptyTextNodeList extends TextNodeList {
	public AlwaysEmptyTextNodeList() {
		super(null);
	}

	public void add(ITextNode rhs) {
	} // no-op

	public void insertAt(ITextNode rhs, int index) {
	} // no-op

}
