[call GenerateFileHeader("IRecordBasedParserObserver.java")]
package com.altova.text.tablelike;

public interface IRecordBasedParserObserver {
    void notifyAboutRecordFound(Record record);
}