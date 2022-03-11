[call GenerateFileHeader("CommandStoreValue.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.Scanner;
import com.altova.text.edifact.TextDocument;
import com.altova.text.ITextNode;

public class CommandStoreValue extends Command {
    private String m_Name;

    public CommandStoreValue(String name) {
        m_Name = name;
    }

    protected boolean doExecute(TextDocument doc) {
        Scanner scanner = doc.getScanner();
        if (Scanner.END==scanner.scanExpression()) return false;
		doc.getGenerator().insertElement(m_Name, scanner.getToken(),
										 ITextNode.DataElement);
        return true;
    }
}
