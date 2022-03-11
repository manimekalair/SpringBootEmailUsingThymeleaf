[call GenerateFileHeader("Table.java")]
package com.altova.text.tablelike;

import java.util.ArrayList;

import com.altova.AltovaException;

public abstract class Table {
    private ArrayList m_Records = new ArrayList();

    private Header m_Header = new Header();

    private ISerializer m_Serializer = null;

    protected abstract ISerializer createSerializer();

    protected abstract void initHeader(Header header);

    public Table() {
        this.initHeader(m_Header);
        m_Serializer = this.createSerializer();
    }

    public Header getHeader() {
        return m_Header;
    }

    public int size() {
        return m_Records.size();
    }

    public void add(Record rhs) {
        m_Records.add(rhs);
    }

    public void clear() {
        m_Records.clear();
    }

    public Record getAt(int index) {
        return (Record) m_Records.get(index);
    }

    public String getEncoding() {
        return m_Serializer.getCharset();
    }

    public void setEncoding(String rhs) {
        m_Serializer.setCharset(rhs);
    }

    public void save(String filename) {
        try {
            m_Serializer.serialize(filename);
        } catch (MappingException x) {
            throw new AltovaException(x);
        }
    }

    public void parse(String filename) {
        try {
            m_Serializer.deserialize(filename);
        } catch (MappingException x) {
            throw new AltovaException(x);
        }
    }
}
