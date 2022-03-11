[call GenerateFileHeader("Generator.java")]
package com.altova.text;

import java.io.FileWriter;
import java.io.Writer;

import com.altova.AltovaException;

public class Generator {
	private ITextNode m_Current = NullTextNode.getInstance();

	private void switchToParent() {
		ITextNode parent = m_Current.getParent();
		if (!parent.isNull())
			m_Current = parent;
	}

	public void init() {
		m_Current = NullTextNode.getInstance();
	}

	public void saveAsSimpleXML(String filename) {
		try {
			Writer writer = new FileWriter(filename);
			TextNodeXMLSerializer xmlSerializer = new TextNodeXMLSerializer(
					writer);
			xmlSerializer.serialize(m_Current.getRoot());
		} catch (Exception e) {
			throw new AltovaException(e.getMessage());
		}
	}

	public void resetToRoot() {
		m_Current = m_Current.getRoot();
	}

	public void enterElement(String name, byte nodeClass) {
		TextNode node = new TextNode(m_Current, name, nodeClass);
		if (m_Current.isNull())
			node = new RootTextNode(node);
		m_Current = node;
	}

	public void leaveElement(String name) {
		if (0 == name.length())
			switchToParent();
		else {
			ITextNode namednode = m_Current.findNodeUpwardsByName(name);
			if (!namednode.isNull()) {
				m_Current = namednode;
				this.switchToParent();
			}
		}
	}

	public void insertElement(String name, String value, byte nodeClass) {
		TextNode node = new TextNode(m_Current, name, nodeClass);
		node.setValue(value);
	}

	public boolean doesNameEqual(String name) {
		return (name == m_Current.getName());
	}

	public boolean doesNamedChildExist(String name) {
		return (0 < m_Current.getChildren().filterByName(name).size());
	}

	public RootTextNode getRootNode() {
		if (m_Current.isNull())
			return null;
		return (RootTextNode) m_Current.getRoot();
	}

	public void setRootNode(ITextNode rhs) {
		m_Current = new RootTextNode(rhs);
	}

	public ITextNode getCurrentNode() {
		return m_Current;
	}
}
