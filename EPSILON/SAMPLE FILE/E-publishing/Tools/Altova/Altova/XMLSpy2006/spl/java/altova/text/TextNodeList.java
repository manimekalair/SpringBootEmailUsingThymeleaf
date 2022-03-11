[call GenerateFileHeader("TextNodeList.java")]
package com.altova.text;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import com.altova.text.TextNodeListIterator;

public class TextNodeList implements ITextNodeList {
	private List m_List = new ArrayList();

	private Hashtable m_NamesToNodes = new Hashtable();

	private TextNode m_Owner = null;

	private void addToTable(ITextNode rhs) {
		
		String name = rhs.getNativeName();
		if (name.length() == 0)
			name = rhs.getName();
		
		if (!m_NamesToNodes.containsKey(name))
			m_NamesToNodes.put(name, new ArrayList());
		ArrayList list = (ArrayList) m_NamesToNodes.get(name);
		list.add(rhs);
	}

	private void removeFromTable(ITextNode rhs) {
		String name = rhs.getNativeName();
		if (name.length() == 0)
			name = rhs.getName();
			
		ArrayList list = (ArrayList) m_NamesToNodes.get(name);
		list.remove(rhs);
	}

	public TextNodeList(TextNode owner) {
		m_Owner = owner;
	}

	public void add(ITextNode rhs) {
		if (null == rhs)
			return;
		m_List.add(rhs);
		addToTable(rhs);
		rhs.setParent(m_Owner);
	}

	public void insertAt(ITextNode rhs, int index) {
		m_List.add(index, rhs);
		addToTable(rhs);
		rhs.setParent(m_Owner);
	}

	public void removeAt(int index) {
		removeFromTable((ITextNode) m_List.get(index));
		m_List.remove(index);
	}

	public int size() {
		return m_List.size();
	}

	public ITextNode getAt(int index) {
		if ((0 > index) || (index >= m_List.size()))
			return NullTextNode.getInstance();
		return (TextNode) m_List.get(index);
	}

	public TextNodeListIterator iterator() {
		return new TextNodeListIterator(m_List.iterator());
	}

	public boolean contains(ITextNode rhs) {
		for (int i = 0; i < m_List.size(); ++i) {
			ITextNode kid = this.getAt(i);
			if (kid == rhs)
				return true;
			if (kid.getChildren().contains(rhs))
				return true;
		}
		return false;
	}

	public TextNodeList filterByName(String name) {
		TextNodeList result = new TextNodeList(m_Owner);
		if (!m_NamesToNodes.containsKey(name))
			return result;
		ArrayList list = (ArrayList) m_NamesToNodes.get(name);
		result.m_List.addAll(list);
		return result;
	}
	
	public ITextNode getFirstNodeByName(String name)
	{
		if (!m_NamesToNodes.containsKey(name))
			return null;
		
		TextNodeList children = filterByName(name);
		if (children.size() == 0)
			return null;
		
		return children.getAt(0);
	}
}
