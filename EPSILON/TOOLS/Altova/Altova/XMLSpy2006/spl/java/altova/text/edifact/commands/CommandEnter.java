[call GenerateFileHeader("CommandEnter.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.TextDocument;

public class CommandEnter extends Command {
    private String m_Name;
	private byte m_Class;

    public CommandEnter(String name, byte nodeClass) {
        m_Name = name;
		m_Class = nodeClass;
    }

    protected boolean doExecute(TextDocument doc) {
        doc.getGenerator().enterElement(m_Name, m_Class);
        return true;
    }
}
