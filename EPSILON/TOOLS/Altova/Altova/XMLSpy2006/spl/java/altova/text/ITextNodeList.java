[call GenerateFileHeader("ITextNodeList.java")]
package com.altova.text;

public interface ITextNodeList {
	void add(ITextNode rhs);

	int size();

	ITextNode getAt(int index);

	TextNodeListIterator iterator();

	boolean contains(ITextNode rhs);

	TextNodeList filterByName(String name);

	void insertAt(ITextNode rhs, int index);

	void removeAt(int index);
	
	public ITextNode getFirstNodeByName(String name);
}