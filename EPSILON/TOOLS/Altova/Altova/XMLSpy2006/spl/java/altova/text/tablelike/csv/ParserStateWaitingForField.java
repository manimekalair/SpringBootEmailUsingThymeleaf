[call GenerateFileHeader("ParserStateWaitingForField.java")]
package com.altova.text.tablelike.csv;

class ParserStateWaitingForField extends ParserState {
    public ParserStateWaitingForField(Parser owner, ParserStateFactory states) {
        super(owner, states);
    }

    public ParserState process(char current) {
        return super.getStates().getInsideField();
    }

    public ParserState processFieldDelimiter(char current) {
        if (!super.getOwner().wasLastCharacterQuote())
            super.getOwner().notifyAboutTokenComplete();
        super.getOwner().moveNext();
        return this;
    }

    public ParserState processRecordDelimiter(char current)
            throws BadFormatException {
        if (super.getOwner().wasLastCharacterFieldDelimiter())
            super.getOwner().notifyAboutTokenComplete();
        super.getOwner().notifyAboutEndOfRecord();
        super.getOwner().moveNext();
        return this;
    }

    public ParserState processQuoteCharacter(char current) {
        super.getOwner().moveNext();
        return super.getStates().getInsideQuotedField();
    }

}