[call GenerateFileHeader("CommandList.java")]
package com.altova.text.edifact.commands;

import java.util.ArrayList;
import java.util.Iterator;

import com.altova.text.edifact.TextDocument;

public class CommandList implements ICommand {
    private ArrayList m_Commands = new ArrayList();

    public boolean execute(TextDocument doc) {
        Iterator it = m_Commands.iterator();
        while ((it.hasNext()) && (!doc.getScanner().isEndOfText())) {
            ICommand command = (ICommand) (it.next());
            command.execute(doc);
        }
        return true;
    }

    public void addCommand(ICommand command) {
        m_Commands.add(command);
    }

    public int size() {
        return m_Commands.size();
    }
}