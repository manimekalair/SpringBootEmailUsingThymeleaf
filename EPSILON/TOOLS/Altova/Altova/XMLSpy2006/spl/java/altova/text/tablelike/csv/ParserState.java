[call GenerateFileHeader("ParserState.java")]
package com.altova.text.tablelike.csv;

abstract class ParserState {
    private Parser m_Owner = null;

    private ParserStateFactory m_States = null;

    protected Parser getOwner() {
        return m_Owner;
    }

    protected ParserStateFactory getStates() {
        return m_States;
    }

    protected ParserState(Parser owner, ParserStateFactory states) {
        m_Owner = owner;
        m_States = states;
    }

    public abstract ParserState process(char current);

    public abstract ParserState processFieldDelimiter(char current);

    public abstract ParserState processRecordDelimiter(char current)
            throws BadFormatException;

    public abstract ParserState processQuoteCharacter(char current)
            throws BadFormatException;
}