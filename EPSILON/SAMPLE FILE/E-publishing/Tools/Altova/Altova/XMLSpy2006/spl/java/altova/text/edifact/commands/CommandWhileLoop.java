[call GenerateFileHeader("CommandWhileLoop.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.TextDocument;

public class CommandWhileLoop extends Command {
    private int m_Count = -1;

    private CommandList m_Commands = new CommandList();

    private void executeWhileLoop(TextDocument doc) {
        boolean iseof = true;
        boolean docontinue = true;
        while (docontinue && iseof) {
            docontinue = m_Commands.execute(doc);
            iseof = !doc.getScanner().isEndOfText();
        }
    }

    private void executeCountedLoop(TextDocument doc) {
        for (int i = 0; i < m_Count; ++i)
            m_Commands.execute(doc);
    }

    public void addCommand(ICommand command) {
        m_Commands.addCommand(command);
    }

    protected boolean doExecute(TextDocument doc) {
        if (0 > m_Count)
            this.executeWhileLoop(doc);
        else
            this.executeCountedLoop(doc);
        return true;
    }

}