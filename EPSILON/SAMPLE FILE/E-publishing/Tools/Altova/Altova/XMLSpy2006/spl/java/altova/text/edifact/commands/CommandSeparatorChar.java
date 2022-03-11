[call GenerateFileHeader("CommandSeparatorChar.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.Scanner;
import com.altova.text.edifact.TextDocument;

public class CommandSeparatorChar extends Command {
    private String m_Name;

    public CommandSeparatorChar(String name) {
        m_Name = name;
    }

    protected boolean doExecute(TextDocument doc) {
        Scanner scanner = doc.getScanner();
        scanner.scanOneCharacter();
        scanner.getSeparatorMap().add(scanner.getToken().charAt(0), m_Name);
        return true;
    }
}