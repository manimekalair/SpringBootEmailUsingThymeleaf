[call GenerateFileHeader("Format.java")]
package com.altova.text.tablelike.flf;

public class Format {
    private boolean m_AssumeRecordDelimitersPresent = false;

    private char m_FillCharacter = ' ';

    private char\[\] m_RecordDelimiters = new char\[\] { '\\n', '\\r' };

    public boolean getAssumeRecordDelimitersPresent() {
        return m_AssumeRecordDelimitersPresent;
    }

    public void setAssumeRecordDelimitersPresent(boolean rhs) {
        m_AssumeRecordDelimitersPresent = rhs;
    }

    public char getFillCharacter() {
        return m_FillCharacter;
    }

    public void setFillCharacter(char rhs) {
        m_FillCharacter = rhs;
    }

    public boolean IsRecordDelimiter(char rhs) {
        for (int i = 0; i < m_RecordDelimiters.length; ++i)
            if (m_RecordDelimiters\[i\] == rhs)
                return true;
        return false;
    }
}