[call GenerateFileHeader("Command.java")]
package com.altova.text.edifact.commands;

import com.altova.text.edifact.TextDocument;
import com.altova.text.edifact.conditions.ConditionList;
import com.altova.text.edifact.conditions.ICondition;
import com.altova.text.edifact.commands.CommandList;
import com.altova.text.edifact.commands.ICommand;


public abstract class Command implements ICommand {
    private ConditionList m_Conditions = new ConditionList();
	private CommandList m_Otherwise = new CommandList();

    public boolean execute(TextDocument doc) {
        if( m_Conditions.evaluate(doc) )
            return this.doExecute(doc);

		m_Otherwise.execute(doc);
		return false;
    }

    public void addCondition(ICondition condition) {
        m_Conditions.addCondition(condition);
    }

    public ConditionList getConditions() {
        return m_Conditions;
    }
	
    public void addOtherwise(ICommand command) {
        m_Otherwise.addCommand(command);
    }

    public CommandList getOtherwise() {
        return m_Otherwise;
    }

    protected abstract boolean doExecute(TextDocument doc);
}