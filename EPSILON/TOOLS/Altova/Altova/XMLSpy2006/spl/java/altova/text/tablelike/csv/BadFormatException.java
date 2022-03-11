[call GenerateFileHeader("BadFormatException.java")]
package com.altova.text.tablelike.csv;

class BadFormatException extends Exception {
    public BadFormatException(String message) {
        super(message);
    }
}