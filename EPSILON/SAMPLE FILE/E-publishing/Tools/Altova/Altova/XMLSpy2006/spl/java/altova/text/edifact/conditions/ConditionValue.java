[call GenerateFileHeader("ConditionValue.java")]
package com.altova.text.edifact.conditions;

import com.altova.text.edifact.TextDocument;

public class ConditionValue implements ICondition {
    private String m_Value;
	private boolean m_Negate;

    public ConditionValue(String value) {
        m_Value = value;
		m_Negate = false;
    }

    public ConditionValue(String value, boolean negate) {
        m_Value = value;
		m_Negate = negate;
    }

    public boolean evaluate(TextDocument doc) {
		boolean result = (m_Value == doc.getScanner().getToken());
		if( m_Negate ) result = !result;
        return result;
    }
}