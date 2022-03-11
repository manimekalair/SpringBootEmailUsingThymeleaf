[call GenerateFileHeader("StringList.java")]
package com.altova.text.tablelike;

import java.util.ArrayList;

public class StringList {
    private ArrayList m_List = new ArrayList();

    public void add(String rhs) {
        m_List.add(rhs);
    }

    public void addRange(String\[\] rhs) {
        for (int i = 0; i < rhs.length; ++i)
            m_List.add(rhs\[i\]);
    }

    public int size() {
        return m_List.size();
    }

    public String getAt(int index) {
        return (String) m_List.get(index);
    }

    public void clear() {
        m_List.clear();
    }

    public void toArray(String\[\] rhs) {
        m_List.toArray(rhs);
    }

    public void setFromArray(String\[\] rhs) {
        m_List.clear();
        this.addRange(rhs);
    }
}