[call GenerateFileHeader("ConditionSiblingContext.java")]
package com.altova.text.edifact.conditions;

import com.altova.text.edifact.TextDocument;

public class ConditionSiblingContext implements ICondition {
    private String m_Name;
	private boolean m_Negate;

    public ConditionSiblingContext(String name) {
        m_Name = name;
		m_Negate = false;
    }

    public ConditionSiblingContext(String name, boolean negate) {
        m_Name = name;
		m_Negate = negate;
    }

    public boolean evaluate(TextDocument doc) {
		boolean result = doc.getGenerator().doesNamedChildExist(m_Name);
		if( m_Negate ) result = !result;
        return result;
    }
}