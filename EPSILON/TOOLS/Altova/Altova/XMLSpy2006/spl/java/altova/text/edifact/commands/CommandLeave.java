[call GenerateFileHeader("CommandLeave.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.TextDocument;

public class CommandLeave extends Command {
    private String m_Name;

    public CommandLeave(String name) {
        m_Name = name;
    }

    protected boolean doExecute(TextDocument doc) {
        doc.getGenerator().leaveElement(m_Name);
        return true;
    }
}