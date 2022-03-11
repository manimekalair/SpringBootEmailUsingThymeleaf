[call GenerateFileHeader("ParserStateInsideField.java")]
package com.altova.text.tablelike.csv;

class ParserStateInsideField extends ParserState {
    public ParserStateInsideField(Parser owner, ParserStateFactory states) {
        super(owner, states);
    }

    public ParserState process(char current) {
        super.getOwner().appendCharacterToToken(current);
        super.getOwner().moveNext();
        return this;
    }

    public ParserState processFieldDelimiter(char current) {
        super.getOwner().notifyAboutTokenComplete();
        super.getOwner().moveNext();
        return super.getStates().getWaitingForField();
    }

    public ParserState processRecordDelimiter(char current)
            throws BadFormatException {
        super.getOwner().notifyAboutTokenComplete();
        super.getOwner().notifyAboutEndOfRecord();
        super.getOwner().moveNext();
        return super.getStates().getWaitingForField();
    }

    public ParserState processQuoteCharacter(char current) {
        return this.process(current);
    }

}