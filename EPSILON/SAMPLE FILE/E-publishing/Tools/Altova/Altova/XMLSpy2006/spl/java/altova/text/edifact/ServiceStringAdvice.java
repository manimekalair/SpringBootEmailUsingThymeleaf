[call GenerateFileHeader("ServiceStringAdvice.java")]
package com.altova.text.edifact;

import java.io.IOException;
import java.io.Writer;

public class ServiceStringAdvice {
	private char m_ComponentSeparator = ':';

	private char m_DataElementSeparator = '+';

	private char m_SegmentTerminator = '\\'';

	private char m_ReleaseCharacter = '?';

	private char m_DecimalSeparator = '.';

	public char getComponentSeparator() {
		return m_ComponentSeparator;
	}

	public void setComponentSeparator(char componentSeparator) {
		m_ComponentSeparator = componentSeparator;
	}

	public char getDataElementSeparator() {
		return m_DataElementSeparator;
	}

	public void setDataElementSeparator(char dataElementSeparator) {
		m_DataElementSeparator = dataElementSeparator;
	}

	public char getDecimalSeparator() {
		return m_DecimalSeparator;
	}

	public void setDecimalSeparator(char decimalSeparator) {
		m_DecimalSeparator = decimalSeparator;
	}

	public char getReleaseCharacter() {
		return m_ReleaseCharacter;
	}

	public void setReleaseCharacter(char releaseCharacter) {
		m_ReleaseCharacter = releaseCharacter;
	}

	public char getSegmentTerminator() {
		return m_SegmentTerminator;
	}

	public void setSegmentTerminator(char segmentTerminator) {
		m_SegmentTerminator = segmentTerminator;
	}

	public void serialize(Writer stream) throws IOException {
		stream.write("UNA");
		stream.write(m_ComponentSeparator);
		stream.write(m_DataElementSeparator);
		stream.write(m_DecimalSeparator);
		stream.write(m_ReleaseCharacter);
		stream.write(' ');
		stream.write(m_SegmentTerminator);
	}

	public void setFromCharArray(char\[\] rhs) {
		m_ComponentSeparator = rhs\[0\];
		m_DataElementSeparator = rhs\[1\];
		m_DecimalSeparator = rhs\[2\];
		m_ReleaseCharacter = rhs\[3\];
		m_SegmentTerminator = rhs\[5\];
	}
}
