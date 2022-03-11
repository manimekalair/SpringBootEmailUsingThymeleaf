[call GenerateFileHeader("Format.java")]
package com.altova.text.tablelike.csv;

import com.altova.text.tablelike.StringList;

public class Format {
    private char m_FieldDelimiter = ',';

    private final char\[\] m_RecordDelimiters = new char\[\] { '\\r', '\\n' };

    private char m_QuoteCharacter = '\\0';

    private char\[\] m_QuoteNeedingCharacters = new char\[4\];

    private boolean m_AssumeFirstRowAsHeaders = true;

    private boolean m_ExpectQuoteCharacters = false;

    private void updateQuoteNeedingCharacters() {
        for (int i = 0; i < 2; ++i)
            m_QuoteNeedingCharacters\[i\] = m_RecordDelimiters\[i\];
        m_QuoteNeedingCharacters\[2\] = m_FieldDelimiter;
        m_QuoteNeedingCharacters\[3\] = m_QuoteCharacter;
    }

    public Format() {
        this.updateQuoteNeedingCharacters();
    }

    public void setAssumeFirstRowAsHeaders(boolean rhs) {
        m_AssumeFirstRowAsHeaders = rhs;
    }

    public boolean doAssumeFirstRowAsHeaders() {
        return m_AssumeFirstRowAsHeaders;
    }

    public char\[\] getRecordDelimiters() {
        return m_RecordDelimiters;
    }

    public char\[\] getQuoteNeedingCharacters() {
        return m_QuoteNeedingCharacters;
    }

    public void setFieldDelimiter(char rhs) {
        m_FieldDelimiter = rhs;
        this.updateQuoteNeedingCharacters();
    }

    public char getFieldDelimiter() {
        return m_FieldDelimiter;
    }

    public void setQuoteCharacter(char rhs) {
        m_ExpectQuoteCharacters = true;
        m_QuoteCharacter = rhs;
        this.updateQuoteNeedingCharacters();
    }

    public char getQuoteCharacter() {
        return m_QuoteCharacter;
    }

    public boolean isFieldDelimiter(char rhs) {
        return (rhs == m_FieldDelimiter);
    }

    public boolean isRecordDelimiter(char rhs) {
        for (int i = 0; i < m_RecordDelimiters.length; ++i)
            if (rhs == m_RecordDelimiters\[i\])
                return true;
        return false;
    }

    public boolean isQuoteCharacter(char rhs) {
        return (m_ExpectQuoteCharacters && (rhs == m_QuoteCharacter));
    }

    public String quoteString(String rhs) {
        if (!m_ExpectQuoteCharacters)
            return rhs;
        String result = "";
        for (int i = 0; i < rhs.length(); ++i) {
            final char c = rhs.charAt(i);
            result += c;
            if (c == m_QuoteCharacter)
                result += c;
        }
        result = m_QuoteCharacter + result + m_QuoteCharacter;
        return result;
    }
}