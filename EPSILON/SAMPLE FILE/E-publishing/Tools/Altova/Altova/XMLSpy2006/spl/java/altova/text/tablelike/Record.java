[call GenerateFileHeader("Record.java")]
package com.altova.text.tablelike;

import java.util.Arrays;

public class Record {
    private String\[\] m_Fields = null;

    Record(String\[\] fields) {
        m_Fields = new String\[fields.length\];
        for (int i = 0; i < fields.length; ++i)
            m_Fields\[i\] = fields\[i\];
    }

    Record(StringList fields) {
        m_Fields = new String\[fields.size()\];
        fields.toArray(m_Fields);
    }

    public Record(int fieldcount) {
        m_Fields = new String\[fieldcount\];
    }

    public Record(Record rhs) {
        m_Fields = new String\[rhs.m_Fields.length\];
        for (int i = 0; i < m_Fields.length; ++i)
            m_Fields\[i\] = rhs.m_Fields\[i\];
    }

    public int size() {
        return m_Fields.length;
    }

    public String getAt(int index) {
        if (index >= m_Fields.length)
            return null;
        return m_Fields\[index\];
    }

    public void setAt(int index, String rhs) {
        m_Fields\[index\] = rhs;
    }
}
