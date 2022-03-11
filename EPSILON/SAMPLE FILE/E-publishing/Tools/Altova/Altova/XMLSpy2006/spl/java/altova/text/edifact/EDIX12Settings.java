[call GenerateFileHeader("EDIX12Settings.java")]
package com.altova.text.edifact;

public class EDIX12Settings extends EDISettings {
	private char m_SubElementSeparator = '!';

	private String m_InterchangeControlVersionNumber = "05012";

	private boolean m_RequestAcknowledgement = true;

	public char getSubElementSeparator() {
		return m_SubElementSeparator;
	}

	public void setSubElementSeparator(char rhs) {
		m_SubElementSeparator = rhs;
	}

	public String getInterchangeControlVersionNumber() {
		return m_InterchangeControlVersionNumber;
	}

	public void setInterchangeControlVersionNumber(String rhs) {
		m_InterchangeControlVersionNumber = rhs;
	}

	public boolean getRequestAcknowledgement() {
		return m_RequestAcknowledgement;
	}

	public void setRequestAcknowledgement(boolean rhs) {
		m_RequestAcknowledgement = rhs;
	}
}
