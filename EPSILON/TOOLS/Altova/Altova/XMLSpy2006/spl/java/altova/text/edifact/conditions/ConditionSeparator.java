[call GenerateFileHeader("ConditionSeparator.java")]
package com.altova.text.edifact.conditions;

import com.altova.text.edifact.Scanner;
import com.altova.text.edifact.TextDocument;

public class ConditionSeparator implements ICondition {
    private String m_Separator;
	private boolean m_Negate;

    public ConditionSeparator(String separator) {
        m_Separator = separator;
		m_Negate = false;
    }

    public ConditionSeparator(String separator, boolean negate) {
        m_Separator = separator;
		m_Negate = negate;
    }

    public boolean evaluate(TextDocument doc) {
        Scanner scanner = doc.getScanner();
		return (m_Separator == scanner.getSeparatorToken()) ^ m_Negate;
    }
}
