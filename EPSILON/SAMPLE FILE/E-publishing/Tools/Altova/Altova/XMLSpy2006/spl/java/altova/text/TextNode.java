[call GenerateFileHeader("TextNode.java")]
package com.altova.text;

public class TextNode implements ITextNode {
	private ITextNode m_Parent = NullTextNode.getInstance();

	private TextNodeList m_Children = null;

	private String m_Name = "";

	private String m_Value = "";

	private byte m_NodeClass = ITextNode.Undefined;

	private boolean m_HasDecimalData = false;

	private int m_MaximumLength = 0;

	private String m_NativeName = "";

	private String m_PrecedingSeparators = "";

	private String m_FollowingSeparators = "";

	private int m_PositionInFather = 0;

	public TextNode(ITextNode parent, String name) {
		this(parent, name, ITextNode.Undefined);
	}

	public TextNode(ITextNode parent, String name, byte nodeClass) {
		m_Name= name;
		m_NodeClass = nodeClass;
		m_Children = new TextNodeList(this);
		m_Parent = parent;
		m_Parent.getChildren().add(this);
	}

	public ITextNode getRoot() {
		return m_Parent.getRoot();
	}

	public ITextNode getParent() {
		return m_Parent;
	}

	public void setParent(ITextNode rhs) {
		m_Parent = rhs;
	}

	public ITextNodeList getChildren() {
		return m_Children;
	}

	public ITextNode findNodeUpwardsByName(String name) {
		if (name == m_Name)
			return this;
		return m_Parent.findNodeUpwardsByName(name);
	}

	public String getName() {
		return m_Name;
	}

	public void setName(String name) {
		m_Name = name;
	}

	public String getValue() {
		return m_Value;
	}

	public void setValue(String value) {
		m_Value = value;
	}

	public boolean isNull() {
		return false;
	}

	public byte getNodeClass() {
		return m_NodeClass;
	}

	public void setNodeClass(byte rhs) {
		m_NodeClass = rhs;
	}

	public boolean hasDecimalData() {
		return m_HasDecimalData;
	}

	public void setHasDecimalData(boolean rhs) {
		m_HasDecimalData = rhs;
	}

	public int getMaximumLength() {
		return m_MaximumLength;
	}

	public void setMaximumLength(int rhs) {
		m_MaximumLength = rhs;
	}

	public String getNativeName() {
		return m_NativeName;
	}

	public void setNativeName(String rhs) {
		m_NativeName = rhs;
	}

	public String getPrecedingSeparators() {
		return m_PrecedingSeparators;
	}

	public void setPrecedingSeparators(String rhs) {
		m_PrecedingSeparators = rhs;
	}

	public String getFollowingSeparators() {
		return m_FollowingSeparators;
	}

	public void setFollowingSeparators(String rhs) {
		m_FollowingSeparators = rhs;
	}

	public int getPositionInFather() {
		return m_PositionInFather;
	}

	public void setPositionInFather(int rhs) {
		m_PositionInFather = rhs;
	}

}
