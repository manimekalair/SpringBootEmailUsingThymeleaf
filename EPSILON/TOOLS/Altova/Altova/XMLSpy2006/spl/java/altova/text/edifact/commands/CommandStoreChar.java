[call GenerateFileHeader("CommandStoreChar.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.Scanner;
import com.altova.text.edifact.TextDocument;
import com.altova.text.ITextNode;

public class CommandStoreChar extends Command {
    private String m_Name;

    public CommandStoreChar(String name) {
        m_Name = name;
    }

    protected boolean doExecute(TextDocument doc) {
        Scanner scanner = doc.getScanner();
        scanner.scanOneCharacter();
		doc.getGenerator().insertElement(m_Name, scanner.getToken(),
										 ITextNode.DataElement);
        return true;
    }
}
