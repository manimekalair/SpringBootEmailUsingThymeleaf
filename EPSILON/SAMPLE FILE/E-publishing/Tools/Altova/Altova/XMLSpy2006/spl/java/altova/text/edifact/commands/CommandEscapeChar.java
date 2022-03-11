[call GenerateFileHeader("CommandEscapeChar.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.Scanner;
import com.altova.text.edifact.TextDocument;

public class CommandEscapeChar extends Command {
    protected boolean doExecute(TextDocument doc) {
        Scanner scanner = doc.getScanner();
        scanner.scanOneCharacter();
        scanner.setEscapeChar(scanner.getToken().charAt(0));
        return true;
    }
}