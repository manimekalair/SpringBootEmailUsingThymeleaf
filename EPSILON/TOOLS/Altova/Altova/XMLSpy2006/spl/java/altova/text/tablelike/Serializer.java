[call GenerateFileHeader("Serializer.java")]
package com.altova.text.tablelike;

import com.altova.text.FileIO;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.Charset;

import com.altova.text.tablelike.csv.Format;

public abstract class Serializer implements ISerializer,
        IRecordBasedParserObserver {
    private Table m_Table = null;

    private Writer m_Stream = null;

    private String m_Charset = "UTF-8";

    protected abstract RecordBasedParser createParser();

    protected abstract void doSerialize() throws IOException, MappingException;

    protected abstract boolean doStoreRecord(Record record);

    protected Writer getStream() {
        return m_Stream;
    }

    protected Table getTable() {
        return m_Table;
    }

    protected Serializer(Table table) {
        m_Table = table;
    }

    public String getCharset() {
        return m_Charset;
    }

    public void setCharset(String rhs) {
        m_Charset = rhs;
    }

    public void serialize(String filename) throws MappingException {
        try {
            FileIO io = new FileIO (filename, m_Charset);
            m_Stream = io.openWriteStream();
            this.doSerialize();
            m_Stream.close();
        } catch (IOException x) {
            throw new MappingException(
                    "Could not write to '" + filename + "'.", x);
        }
    }

    public void deserialize(String filename) throws MappingException {
        try {
            m_Table.clear();
            FileIO io = new FileIO (filename, m_Charset);
            String buffer = io.readToEnd().toString();
            RecordBasedParser parser = this.createParser();
            parser.setObserver(this);
            parser.parse(buffer);
        } catch (MappingException x) {
            throw new MappingException("Could not parse '" + filename + "'.", x);
        } catch (IOException x) {
            throw new MappingException("Could not open '" + filename + "'.", x);
        }
    }

    public void notifyAboutRecordFound(Record record) {
        if (this.doStoreRecord(record))
            m_Table.add(record);
    }
}
