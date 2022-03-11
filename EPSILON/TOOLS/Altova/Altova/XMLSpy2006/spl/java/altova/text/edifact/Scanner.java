[call GenerateFileHeader("Scanner.java")]
package com.altova.text.edifact;

import java.util.ArrayList;
import java.util.Iterator;
import java.lang.StringBuffer;

public class Scanner {
	public class SeparatorToSymbolicNameMap {
		private class SeparatorSymbolicNamePair {
			char m_Separator = 0;

			String m_SymbolicName = "";

			public SeparatorSymbolicNamePair(char separator, String symbolicname) {
				m_Separator = separator;
				m_SymbolicName = symbolicname;
			}

			public char getSeparator() {
				return m_Separator;
			}

			public String getSymbolicName() {
				return m_SymbolicName;
			}
		}

		ArrayList m_List = new ArrayList();

		boolean isValueContained(String symbolicname) {
			for (int i = 0; i < m_List.size(); ++i) {
				SeparatorSymbolicNamePair entry = (SeparatorSymbolicNamePair) m_List
						.get(i);
				if (symbolicname == entry.getSymbolicName())
					return true;
			}
			return false;
		}

		void removeAllEntriesWithValue(String symbolicname) {
			Iterator it = m_List.iterator();
			while (it.hasNext()) {
				SeparatorSymbolicNamePair entry = (SeparatorSymbolicNamePair) it
						.next();
				if (symbolicname == entry.getSymbolicName())
					it.remove();
			}
		}

		public void add(char separator, String symbolicname) {
			if (this.isValueContained(symbolicname))
				this.removeAllEntriesWithValue(symbolicname);
			SeparatorSymbolicNamePair entry = new SeparatorSymbolicNamePair(
					separator, symbolicname);
			m_List.add(entry);
		}

		public String getSymbolicNameForSeparator(char separator) {
			for (int i = 0; i < m_List.size(); ++i) {
				SeparatorSymbolicNamePair entry = (SeparatorSymbolicNamePair) m_List
						.get(i);
				if (separator == entry.getSeparator())
					return entry.getSymbolicName();
			}
			return null;
		}

		public char getSeparatorForSymbolicName(String name) {
			for (int i = 0; i < m_List.size(); ++i) {
				SeparatorSymbolicNamePair entry = (SeparatorSymbolicNamePair) m_List
						.get(i);
				if (name == entry.getSymbolicName())
					return entry.getSeparator();
			}
			return 0;
		}

		public boolean isContained(char separator) {
			return (null != this.getSymbolicNameForSeparator(separator));
		}
	}

	private String m_Current;

	private int m_Position;

	private String m_Token;

	private String m_SeparatorToken;

	private char m_EscapeChar;

	private char m_DecimalSeparator;

	private SeparatorToSymbolicNameMap m_SeparatorMap = new SeparatorToSymbolicNameMap();

	private StringBuffer m_TokenBuffer = new StringBuffer();

	private void moveNext() {
		++m_Position;
	}

	private void moveBack() {
		--m_Position;
	}

	private boolean isDelimiter() {
		return m_SeparatorMap.isContained(this.getCurrentCharacter());
	}

	private boolean isInsideExpression() {
		if (this.isEndOfText())
			return false;

		if (m_EscapeChar == this.getCurrentCharacter()) {
			this.moveNext();
			return true;
		}

		return !this.isDelimiter();
	}

	private short getScannerReturnCode(boolean checktoken) {
		if (this.isEndOfText())
			return END;
		else {
			if ((checktoken) && (0 == m_Token.length()))
				return EMPTY;
			else
				return VALUE;
		}
	}

	final public static short VALUE = 0;

	final public static short EMPTY = 1;

	final public static short END = 2;

	public Scanner() {
		m_SeparatorMap.add('\\0', "terminate");
		m_SeparatorMap.add('\\r', "return");
		m_SeparatorMap.add('\\n', "linefeed");
		m_EscapeChar = '\\0';
	}

	public void init(String buffer) {
		m_Current = buffer;
		m_Position = 0;
	}

	public String getToken() {
		return m_Token;
	}

	public short scanExpression() {
		if (this.isEndOfText())
			return END;

		m_TokenBuffer.delete(0, m_TokenBuffer.length());

		if (this.isInsideExpression())
			m_TokenBuffer.append(getCurrentCharacter());

		this.moveNext();
		while (this.isInsideExpression()) {
			m_TokenBuffer.append(getCurrentCharacter());
			this.moveNext();
		}

		m_Token = m_TokenBuffer.toString();

		// store the current separator token so that we can depend on it in a rule.
		m_SeparatorToken = m_SeparatorMap.getSymbolicNameForSeparator(getCurrentCharacter());

		return this.getScannerReturnCode(true);
	}

	public short scanOneCharacter() {
		this.moveNext();
		m_Token = "";
		m_Token += this.getCurrentCharacter();
		return this.getScannerReturnCode(false);
	}

	public short moveBackOneCharacter() {
		moveBack();
		m_Token = "";
		m_Token += this.getCurrentCharacter();
		return this.getScannerReturnCode(false);
	}

	public char getCurrentCharacter() {
		if (m_Position >= m_Current.length())
			return '\\0';
		return m_Current.charAt(m_Position);
	}

	public SeparatorToSymbolicNameMap getSeparatorMap() {
		return m_SeparatorMap;
	}

	public String getSeparatorToken() {
		return m_SeparatorToken;
	}

	public boolean isEndOfText() {
		return (0 == getCurrentCharacter());
	}

	public void setEscapeChar(char rhs) {
		m_EscapeChar = rhs;
	}

	public char getDecimalSeparator() {
		return m_DecimalSeparator;
	}

	public void setDecimalSeparator(char rhs) {
		m_DecimalSeparator = rhs;
	}
}
