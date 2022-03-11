[call GenerateFileHeader("MappingException.java")]
package com.altova.text.tablelike;

public class MappingException extends Exception {
    public MappingException(String message) {
        super(message);
    }

    public MappingException(String message, Exception innerexception) {
        super(message, innerexception);
    }
}