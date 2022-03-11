[call GenerateFileHeader("Header.java")]
package com.altova.text.tablelike;

import java.util.ArrayList;

public class Header {
    private ArrayList m_Columns = new ArrayList();

    public void add(ColumnSpecification rhs) {
        m_Columns.add(rhs);
    }

    public void clear() {
        m_Columns.clear();
    }

    public int size() {
        return m_Columns.size();
    }

    public ColumnSpecification getAt(int index) {
        return (ColumnSpecification) m_Columns.get(index);
    }

    public int getRecordSize() {
        int result = 0;
        for (int i = 0; i < m_Columns.size(); ++i)
            result += this.getAt(i).getLength();
        return result;
    }
}
