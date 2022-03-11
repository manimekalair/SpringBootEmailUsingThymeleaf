[call GenerateFileHeader("CommandBackChar.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.TextDocument;

public class CommandBackChar extends Command {
    protected boolean doExecute(TextDocument doc) {
        doc.getScanner().moveBackOneCharacter();
        return true;
    }
}