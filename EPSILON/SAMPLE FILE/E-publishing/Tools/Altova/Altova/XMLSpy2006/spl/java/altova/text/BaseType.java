[call GenerateFileHeader("BaseType.java")]
package com.altova.text;

public class BaseType {
	protected ITextNode m_Node = NullTextNode.getInstance();

	public ITextNode getNode() {
		return m_Node;
	}

	public BaseType(ITextNode node) {
		m_Node = node;
	}

	public static String MakeDecimal(ITextNode node) {
		RootTextNode root = (RootTextNode) node.getRoot();
		return root.getValueOfNodeAsDecimalString(node);
	}
}