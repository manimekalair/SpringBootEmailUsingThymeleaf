[call GenerateFileHeader("RootTextNode.java")]
package com.altova.text;

public class RootTextNode extends TextNode {
	private char m_DecimalSeparator = '.';

	private ITextNode m_InnerNode = NullTextNode.getInstance();

	public char getDecimalSeparator() {
		return m_DecimalSeparator;
	}

	public void setDecimalSeparator(char rhs) {
		m_DecimalSeparator = rhs;
	}

	public String getValueOfNodeAsDecimalString(ITextNode node) {
		return node.getValue().replace(m_DecimalSeparator, '.');
	}

	public RootTextNode(ITextNode innernode) {
		super(NullTextNode.getInstance(), innernode.getName());
		m_InnerNode = innernode;
		m_InnerNode.setParent(this);
	}

	public ITextNode getRoot() {
		return this;
	}

	public ITextNode getParent() {
		return null;
	}

	public void setParent(ITextNode rhs) {
	}

	public String getName() {
		return m_InnerNode.getName();
	}

	public String getValue() {
		return m_InnerNode.getValue();
	}

	public void setName(String rhs) {
		m_InnerNode.setName(rhs);
	}

	public void setValue(String rhs) {
		m_InnerNode.setValue(rhs);
	}

	public ITextNodeList getChildren() {
		return m_InnerNode.getChildren();
	}

}
