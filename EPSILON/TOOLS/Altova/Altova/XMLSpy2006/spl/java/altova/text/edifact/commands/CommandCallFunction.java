[call GenerateFileHeader("CommandCallFunction.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.Function;
import com.altova.text.edifact.TextDocument;

public class CommandCallFunction extends Command {
    private String m_Name;

    public CommandCallFunction(String name) {
        m_Name = name;
    }

    protected boolean doExecute(TextDocument doc) {
        Function function = doc.getFunctions().get(m_Name);
        if (null != function)
            return function.execute(doc);
        return true;
    }
}