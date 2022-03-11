[call GenerateFileHeader("ParserException.java")]
package com.altova.text.tablelike.csv;

import com.altova.text.tablelike.MappingException;

public class ParserException extends MappingException {
    int m_LineNumber = 0;

    public int getLineNumber() {
        return m_LineNumber;
    }

    ParserException(BadFormatException x, int linenumber) {
        super(x.getMessage() + " at line #" + linenumber);
        m_LineNumber = linenumber;
    }
}