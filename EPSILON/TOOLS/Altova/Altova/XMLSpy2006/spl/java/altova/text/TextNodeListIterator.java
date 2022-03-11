[call GenerateFileHeader("TextNodeListIterator.java")]
package com.altova.text;

import java.util.Iterator;

public class TextNodeListIterator implements Iterator {
	private Iterator m_InnerIterator = null;

	public boolean hasNext() {
		return m_InnerIterator.hasNext();
	}

	public Object next() {
		return m_InnerIterator.next();
	}

	public void remove() {
		m_InnerIterator.remove();
	}

	public TextNodeListIterator(Iterator inneriterator) {
		m_InnerIterator = inneriterator;
	}

	public TextNode nextTextNode() {
		return (TextNode) this.next();
	}
}
