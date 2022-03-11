[call GenerateFileHeader("ParserException.java")]
package com.altova.text.tablelike.flf;

import com.altova.text.tablelike.MappingException;

public class ParserException extends MappingException {
    int m_Offset = -1;

    public int getOffset() {
        return m_Offset;
    }

    ParserException(String message, int offset) {
        super(message + " at offset #" + offset);
        m_Offset = offset;
    }
}