[call GenerateFileHeader("CommandIgnoreValue.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.Scanner;
import com.altova.text.edifact.TextDocument;

public class CommandIgnoreValue extends Command {
    protected boolean doExecute(TextDocument doc) {
        Scanner scanner = doc.getScanner();
        scanner.scanExpression();
        return true;
    }
}