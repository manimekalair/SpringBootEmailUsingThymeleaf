[call GenerateFileHeader("EDISettings.java")]
package com.altova.text.edifact;

public class EDISettings {
	private ServiceStringAdvice m_ServiceStringAdvice = new ServiceStringAdvice();

	private boolean m_TerminateSegmentsWithLinefeed = false;

	private boolean m_AutoCompleteData = true;

	public ServiceStringAdvice getServiceStringAdvice() {
		return m_ServiceStringAdvice;
	}

	public boolean getTerminateSegmentsWithLinefeed() {
		return m_TerminateSegmentsWithLinefeed;
	}

	public boolean getAutoCompleteData() {
		return m_AutoCompleteData;
	}

	public void setTerminateSegmentsWithLinefeed(boolean rhs) {
		m_TerminateSegmentsWithLinefeed = rhs;
	}

	public void setAutoCompleteData(boolean rhs) {
		m_AutoCompleteData = rhs;
	}
}
