[call GenerateFileHeader("ConditionFollowCharacter.java")]
package com.altova.text.edifact.conditions;

import com.altova.text.edifact.TextDocument;
import com.altova.text.edifact.Scanner;

public class ConditionFollowCharacter implements ICondition {
    private String m_Value;
	private boolean m_Negate;

    public ConditionFollowCharacter(String value) {
        m_Value = value;
		m_Negate = false;
    }

    public ConditionFollowCharacter(String value, boolean negate) {
        m_Value = value;
		m_Negate = negate;
    }

    public boolean evaluate(TextDocument doc) {
		Scanner scanner = doc.getScanner();
		short eScan = scanner.scanOneCharacter();
		char ch = scanner.getCurrentCharacter();
		Scanner.SeparatorToSymbolicNameMap mapping = scanner.getSeparatorMap();
		String sCheck = mapping.getSymbolicNameForSeparator(ch);
		if( sCheck == null ) { sCheck = new String(); sCheck += ch; }
		short eBack = scanner.moveBackOneCharacter();
		boolean result = sCheck == m_Value;
		if( m_Negate ) result = !result;
		return result;
    }
}