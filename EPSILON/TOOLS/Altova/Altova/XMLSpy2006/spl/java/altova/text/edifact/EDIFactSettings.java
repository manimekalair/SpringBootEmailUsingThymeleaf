[call GenerateFileHeader("EDIFactSettings.java")]
package com.altova.text.edifact;

public class EDIFactSettings extends EDISettings {
	private long mSyntaxVersionNumber = 2;

	private char mSyntaxLevel = 'A';

	private String mControllingAgency = "UNO";

	private boolean mWriteUNA = true;

	public long getSyntaxVersionNumber() {
		return mSyntaxVersionNumber;
	}

	public char getSyntaxLevel() {
		return mSyntaxLevel;
	}

	public String getControllingAgency() {
		return mControllingAgency;
	}

	public boolean getWriteUNA() {
		return mWriteUNA;
	}

	public void setSyntaxVersionNumber(long rhs) {
		mSyntaxVersionNumber = rhs;
	}

	public void setSyntaxLevel(char rhs) {
		mSyntaxLevel = rhs;
	}

	public void setControllingAgency(String rhs) {
		mControllingAgency = rhs;
	}

	public void setWriteUNA(boolean rhs) {
		mWriteUNA = rhs;
	}
}
