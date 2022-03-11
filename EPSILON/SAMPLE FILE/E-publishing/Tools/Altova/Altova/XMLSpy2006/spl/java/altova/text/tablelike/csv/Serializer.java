[call GenerateFileHeader("Serializer.java")]
package com.altova.text.tablelike.csv;

import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;

import com.altova.AltovaException;
import com.altova.text.tablelike.IRecordBasedParserObserver;
import com.altova.text.tablelike.ISerializer;
import com.altova.text.tablelike.MappingException;
import com.altova.text.tablelike.Record;
import com.altova.text.tablelike.RecordBasedParser;
import com.altova.text.tablelike.Table;

public class Serializer extends com.altova.text.tablelike.Serializer {
    private Format m_Format = new Format();

    private boolean m_WaitingForHeader = false;

    private void writeFieldEnd() throws IOException {
        super.getStream().write(m_Format.getFieldDelimiter());
    }

    private void writeRecordEnd() throws IOException {
        super.getStream().write(m_Format.getRecordDelimiters());
    }

    private boolean doesContainQuoteNeedingCharacters(String rhs) {
        final char\[\] lookfor = m_Format.getQuoteNeedingCharacters();
        for (int i = 0; i < lookfor.length; ++i)
            if (0 <= rhs.indexOf(lookfor\[i\]))
                return true;
        return false;
    }

    private boolean doesStartOrEndWithWhiteSpace(String rhs) {
        return (!rhs.equals(rhs.trim()));
    }

    private String assureCorrectFieldFormat(String rhs) {
        String result = rhs;
        if (null == result)
            result = "";
        if ((this.doesStartOrEndWithWhiteSpace(result))
                || (this.doesContainQuoteNeedingCharacters(result)))
            result = m_Format.quoteString(result);
        return result;
    }

    private void writeHeaders() throws IOException {
        int maximalindex = super.getTable().getHeader().size();
        for (int i = 0; i < maximalindex; ++i) {
            String name = super.getTable().getHeader().getAt(i).getName();
            name = this.assureCorrectFieldFormat(name);
            super.getStream().write(name);
            if (i < maximalindex - 1)
                this.writeFieldEnd();
        }
        this.writeRecordEnd();
    }

    private void writeRecord(Record record) throws IOException {
        int maximalindex = super.getTable().getHeader().size();
        for (int i = 0; i < maximalindex; ++i) {
            String value = record.getAt(i);
            value = this.assureCorrectFieldFormat(value);
            super.getStream().write(value);
            if (i < maximalindex - 1)
                this.writeFieldEnd();
        }
        this.writeRecordEnd();
    }

    public Format getFormat() {
        return m_Format;
    }

    public Serializer(Table table) {
        super(table);
    }

    protected void doSerialize() throws IOException {
        if (m_Format.doAssumeFirstRowAsHeaders())
            this.writeHeaders();
        for (int i = 0; i < super.getTable().size(); ++i)
            this.writeRecord(super.getTable().getAt(i));
    }

    protected RecordBasedParser createParser() {
        m_WaitingForHeader = m_Format.doAssumeFirstRowAsHeaders();
        return new Parser(m_Format);
    }

    protected boolean doStoreRecord(Record record) {
        if (m_WaitingForHeader) {
            m_WaitingForHeader = false;
            return false;
        } else
            return true;
    }

}
