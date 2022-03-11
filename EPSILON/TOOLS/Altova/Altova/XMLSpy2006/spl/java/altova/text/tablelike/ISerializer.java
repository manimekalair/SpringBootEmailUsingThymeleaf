[call GenerateFileHeader("ISerializer.java")]
package com.altova.text.tablelike;

public interface ISerializer {
    void serialize(String filename) throws MappingException;

    void deserialize(String filename) throws MappingException;

    String getCharset();

    void setCharset(String rhs);
}