[call GenerateFileHeader("ITextNode.java")]
package com.altova.text;

public interface ITextNode {
	final static byte Undefined = 0;

	final static byte DataElement = 1;

	final static byte Composite = 2;

	final static byte Segment = 3;

	final static byte Group = 4;

	ITextNode getRoot();

	ITextNode getParent();

	void setParent(ITextNode rhs);

	ITextNodeList getChildren();

	ITextNode findNodeUpwardsByName(String name);

	String getName();

	void setName(String name);

	String getValue();

	void setValue(String value);

	boolean isNull();

	byte getNodeClass();

	void setNodeClass(byte rhs);

	boolean hasDecimalData();

	void setHasDecimalData(boolean rhs);

	int getMaximumLength();

	void setMaximumLength(int rhs);

	String getNativeName();

	void setNativeName(String rhs);

	String getPrecedingSeparators();

	void setPrecedingSeparators(String rhs);

	String getFollowingSeparators();

	void setFollowingSeparators(String rhs);

	int getPositionInFather();

	void setPositionInFather(int rhs);
}