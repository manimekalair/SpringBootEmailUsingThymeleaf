[call GenerateFileHeader("ConditionCurrentContext.java")]
package com.altova.text.edifact.conditions;

import com.altova.text.edifact.TextDocument;

public class ConditionCurrentContext implements ICondition {
    private String m_Name;
	private boolean m_Negate;

    public ConditionCurrentContext(String name) {
        m_Name = name;
		m_Negate = false;
    }

    public ConditionCurrentContext(String name, boolean negate) {
        m_Name = name;
		m_Negate = negate;
    }

    public boolean evaluate(TextDocument doc) {
		boolean result = doc.getGenerator().doesNameEqual(m_Name);
		if( m_Negate ) result = !result;
        return result;
    }
}