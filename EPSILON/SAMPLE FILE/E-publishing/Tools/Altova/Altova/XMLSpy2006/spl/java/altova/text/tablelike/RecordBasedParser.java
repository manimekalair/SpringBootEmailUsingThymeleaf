[call GenerateFileHeader("RecordBasedParser.java")]
package com.altova.text.tablelike;

public abstract class RecordBasedParser {
    private IRecordBasedParserObserver m_Observer = null;

    public IRecordBasedParserObserver getObserver() {
        return m_Observer;
    }

    public void setObserver(IRecordBasedParserObserver rhs) {
        m_Observer = rhs;
    }

    public abstract int parse(String buffer) throws MappingException;

    protected void notifyAboutRecordFound(String\[\] fields) {
        if (null != m_Observer)
            m_Observer.notifyAboutRecordFound(new Record(fields));
    }

    protected void notifyAboutRecordFound(StringList fields) {
        if (null != m_Observer)
            m_Observer.notifyAboutRecordFound(new Record(fields));
    }
}