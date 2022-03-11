[call GenerateFileHeader("ParserStateInsideQuotedField.java")]
package com.altova.text.tablelike.csv;

class ParserStateInsideQuotedField extends ParserState {
    public ParserStateInsideQuotedField(Parser owner, ParserStateFactory states) {
        super(owner, states);
    }

    public ParserState process(char current) {
        super.getOwner().appendCharacterToToken(current);
        super.getOwner().moveNext();
        return this;
    }

    public ParserState processFieldDelimiter(char current) {
        super.getOwner().appendCharacterToToken(current);
        super.getOwner().moveNext();
        return this;
    }

    public ParserState processRecordDelimiter(char current) {
        super.getOwner().appendCharacterToToken(current);
        super.getOwner().moveNext();
        return this;
    }

    public ParserState processQuoteCharacter(char current) {
        ParserState result = this;

        super.getOwner().moveNext();
        if (super.getOwner().isEndOfBuffer()) {
            super.getOwner().notifyAboutTokenComplete();
            result = super.getStates().getWaitingForField();
        } else if (super.getOwner().getCurrentCharacter() == current) {
            super.getOwner().appendCharacterToToken(current);
            super.getOwner().moveNext();
        } else {
            result = super.getStates().getInsideField();
        }

        return result;
    }
}