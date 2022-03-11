[call GenerateFileHeader("CommandIgnoreChar.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.Scanner;
import com.altova.text.edifact.TextDocument;

public class CommandIgnoreChar extends Command {
    protected boolean doExecute(TextDocument doc) {
        Scanner scanner = doc.getScanner();
        scanner.scanOneCharacter();
        return true;
    }
}