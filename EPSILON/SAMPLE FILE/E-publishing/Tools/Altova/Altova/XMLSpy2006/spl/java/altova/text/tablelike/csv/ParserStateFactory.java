[call GenerateFileHeader("ParserStateFactory.java")]
package com.altova.text.tablelike.csv;

class ParserStateFactory {
    ParserStateWaitingForField m_WaitingForFieldState = null;

    ParserStateInsideField m_InsideFieldState = null;

    ParserStateInsideQuotedField m_InsideQuotedFieldState = null;

    public ParserStateFactory(Parser owner) {
        m_WaitingForFieldState = new ParserStateWaitingForField(owner, this);
        m_InsideFieldState = new ParserStateInsideField(owner, this);
        m_InsideQuotedFieldState = new ParserStateInsideQuotedField(owner, this);
    }

    public ParserStateWaitingForField getWaitingForField() {
        return m_WaitingForFieldState;
    }

    public ParserStateInsideField getInsideField() {
        return m_InsideFieldState;
    }

    public ParserStateInsideQuotedField getInsideQuotedField() {
        return m_InsideQuotedFieldState;
    }

}